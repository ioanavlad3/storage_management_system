.data
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d\n"
    formatPrintfADD: .asciz "%d: (%d, %d)\n"
    formatPrintfGET: .asciz "(%d, %d)\n"
    formatPrintVerif: .asciz "*\n"
    v: .space 4096                         # 1024 de longuri
    nr_operatii: .space 4
    nr_fct: .space 4                        # numarul functiei de trebuie efectuata
    nr_fisiere: .space 4                    # pentru ADD efectuam pentru mai multe fisiere
    descriptor_fis: .space 4
    dimensiune: .space 4                    # dimensiunea in KB
    poz_initiala: .space 4
    poz_finala: .space 4
    dim: .space 4
    precedent: .space 4

.text
.global main

ADD:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %ebx                      # %ebx = nr_fisiere
    #pushl %edi

citire_fisiere:
    cmp $0, %ebx
    je iesire_din_fct

    pushl $descriptor_fis
    pushl $formatScanf
    call scanf
    addl $8, %esp

    pushl $dimensiune
    pushl $formatScanf
    call scanf
    addl $8, %esp

    movl dimensiune, %eax                   # in %eax se stocheaza dimensiunea in KB
    xorl %edx, %edx
    movl $8, %ecx
    divl %ecx                               
    cmp $0, %edx                           # daca in %edx nu e 0, atunci in %eax trebuie sa mai adaugam 1
    jne adauga_unu

dupa_adauga_unu:
    movl $0, %edx                           # poz_initiala = %edx
    movl $0, %ecx                           # contorul  = %ecx
    pushl %ebx                              # am neoie de un registru pt a retine spatiul liber, asa ca eliberez %ebx ul
    movl $0, %ebx

caut_loc_in_vector: 
    cmp $1025, %ecx
    je nu_este_loc1
    
    cmp %ebx, %eax
    je scot_de_pe_stiva_ebx

    pushl %eax
    movl (%edi, %ecx, 4), %eax
    cmp $0, %eax
    je am_gasit_un_spatiu

    popl %eax

    movl $0, %ebx

    addl $1, %ecx
    movl %ecx, %edx
    jmp caut_loc_in_vector

am_gasit_un_spatiu:
    popl %eax
    addl $1, %ebx
    addl $1, %ecx
    jmp caut_loc_in_vector

scot_de_pe_stiva_ebx:
    popl %ebx                               # scot de pe stiva %ebx ul
    movl %edx, %ecx                         
    addl %eax, %ecx                         # %ecx devine poz finala
    movl %edx, poz_initiala
    subl $1, %ecx
    movl %ecx, poz_finala

afisare:
    cmp $1024, %ecx
    jge nu_este_loc
    pushl %edx
    pushl poz_finala
    pushl poz_initiala
    pushl descriptor_fis
    pushl $formatPrintfADD
    call printf
    addl $16, %esp
    sub $1, %ebx
    popl %edx
    movl %esi, %edi
punere_in_vector:
    cmp poz_finala, %edx
    jg citire_fisiere
    movl descriptor_fis, %eax
    movl %eax, (%edi, %edx, 4)            # adaug un element in vector
    addl $1, %edx

    jmp punere_in_vector


iesire_din_fct:
    #popl %edi
    popl %ebp
    ret

nu_este_loc:
    pushl $0
    pushl $0
    pushl descriptor_fis
    pushl $formatPrintfADD
    call printf
    addl $16, %esp

    subl $1, %ebx

    jmp citire_fisiere


nu_este_loc1:
    pushl $0
    pushl $0
    pushl descriptor_fis
    pushl $formatPrintfADD
    call printf
    addl $16, %esp
    
    popl %ebx
    subl $1, %ebx

    jmp citire_fisiere

adauga_unu:
    addl $1, %eax
    jmp dupa_adauga_unu


GET:
    movl $0, %ecx
    movl descriptor_fis, %eax

    caut_poz_init:
        cmp $1024, %ecx
        je afisare_zero_GET                     # am parcurs tot vectorul si nu am iesit deloc din el => nu exista elementul cautat

        movl (%edi, %ecx, 4), %ebx

        cmp %eax, %ebx
        je caut_poz_finala                      # am gasit de unde incepe secventa 

        addl $1, %ecx
        jmp caut_poz_init

    caut_poz_finala:
        movl %ecx, poz_initiala

        while_caut_poz_finala:
            movl (%edi, %ecx, 4), %ebx
            cmp descriptor_fis, %ebx
            jne afisare_GET
            addl $1, %ecx
            jmp while_caut_poz_finala

    afisare_GET:
        
        subl $1, %ecx
        pushl %ecx
        pushl poz_initiala
        pushl $formatPrintfGET
        call printf
        addl $12, %esp
        ret

    afisare_zero_GET:
        movl $0, poz_initiala
        movl $0, %ecx
        pushl %ecx
        pushl poz_initiala
        pushl $formatPrintfGET
        call printf
        addl $12, %esp
        ret


DELETE:
    movl $0, %ebx                       # %ebx = contorul
    movl $0, precedent

    iterare_prin_vector:
        cmp $1024, %ebx
        je exit_DELETE


        movl (%edi, %ebx, 4), %eax              # %eax detine elementul curent

        cmp precedent, %eax
        jne verificare_ID
        #movl %eax, precedent

        label: 
            addl $1, %ebx
            jmp iterare_prin_vector
        

    verificare_ID:
        cmp $0, %eax
        je label 
        cmp descriptor_fis, %eax
        je stergere
        jmp printare

    stergere:
        movl %ebx, poz_initiala
        movl %eax, precedent

        loop_stergere:
            movl (%edi, %ebx, 4), %eax 
            cmp precedent, %eax
            jne iterare_prin_vector                 # precedentul ramane descriptor_fis 
            movl $0, (%edi, %ebx, 4)
            addl $1, %ebx
            jmp loop_stergere

    printare:
        
        movl %ebx, poz_initiala
        movl %eax, precedent

        loop_printare:
            movl (%edi, %ebx, 4), %eax 
            cmp precedent, %eax
            jne iesire_loop_printare
            addl $1, %ebx
            jmp loop_printare

        iesire_loop_printare:
            subl $1, %ebx
            movl %ebx, poz_finala
            addl $1, %ebx

            pushl %eax
            
            pushl poz_finala
            pushl poz_initiala
            pushl precedent
            pushl $formatPrintfADD
            call printf
            addl $16, %esp

            popl %eax
            jmp iterare_prin_vector

    exit_DELETE:
        ret


DEFRAGMENTATION:
    movl $0, %ebx

    while_iterare:
        cmp $1024, %ebx
        je pentru_printare_capete             
        movl (%edi, %ebx, 4), %eax
        cmp $0, %eax
        je verifica_daca_este_doar_0_dupa
        addl $1, %ebx
        jmp while_iterare

    permutare:

        movl %ebx, %ecx                     # retin ca %ebx contorul din primul while, iar %ecx din acest while

        loop_permutare:
            cmp $1023, %ecx                          # permut toate elementele pana la ultima pozitie
            je adauga_la_final
            addl $1, %ecx
            movl (%edi, %ecx, 4), %eax              #retin elementul urmator
            subl $1, %ecx
            movl %eax, (%edi, %ecx, 4)              # fac mutare: v[i] = v[i+1]
            addl $1, %ecx
            jmp loop_permutare

        adauga_la_final:
            movl $0, (%edi, %ecx, 4)                # pentru ca am permutat toate elementele spre stanga cu o pozitie
                                                    # acum adaug 0 la finalul vectorului
            jmp while_iterare
        
    # acum fac iar o iterare prin vector ca sa printez capetele elementelor
    
pentru_printare_capete:

    movl %esi, %edi
    movl $0, %ebx
    movl (%edi, %ebx, 4), %eax
    movl %eax, precedent                        # precedent = primul element din vector
    movl $0, poz_initiala


    loop_iterare:
        cmp $1025, %ebx
        je exit_DEFRAGMENTATION

        movl (%edi, %ebx, 4), %eax
        cmp precedent, %eax
        jne afisare_DEFRAGMENTATION
        cmp $0, %eax
        je exit_DEFRAGMENTATION                 # daca am gasit un 0, inseamna ca e pus la final, deci pot sa ies din while
        addl $1, %ebx
        jmp loop_iterare

    afisare_DEFRAGMENTATION:
        subl $1, %ebx
        movl %ebx, poz_finala
        addl $1, %ebx

        pushl %eax

        pushl poz_finala
        pushl poz_initiala
        pushl precedent
        pushl $formatPrintfADD
        call printf
        addl $16, %esp

        popl %eax
        movl %eax, precedent
        movl %ebx, poz_initiala
        jmp loop_iterare


    exit_DEFRAGMENTATION:
        ret

    verifica_daca_este_doar_0_dupa:
        movl %ebx, %ecx
        
        loop_verifica:
            cmp $1024, %ecx
            je pentru_printare_capete             # este doar 0, deci nu mai continui

            movl (%edi, %ecx, 4), %eax
            cmp $0, %eax
            jne permutare                       # un element nu e zero => pot continua cu permutarea
            addl $1, %ecx
            jmp loop_verifica


main:
    leal v, %edi
    lea v, %esi                      # pastrez memoria de inceput a vectorului in %esi
    movl $0, poz_initiala

    pushl $nr_operatii
    pushl $formatScanf
    call scanf
    addl $8, %esp

    movl nr_operatii, %ecx

citire_operatii: 
    cmp $0, %ecx
    je exit

    pushl %ecx

    pushl $nr_fct
    pushl $formatScanf
    call scanf
    addl $8, %esp

    popl %ecx

    movl nr_fct, %eax
    cmp $1, %eax            
    je call_ADD

    cmp $2, %eax
    je call_GET

    cmp $3, %eax
    je call_DELETE

    cmp $4, %eax
    je call_DEFRAGMENTATION


call_ADD:
    pushl %ecx

    pushl $nr_fisiere
    pushl $formatScanf
    call scanf
    addl $8, %esp

    popl %ecx
    
    pushl %edi
    pushl %ecx
    pushl nr_fisiere
    call ADD
    addl $4, %esp
    popl %ecx
    popl %edi

    jmp dupa_call_ADD


dupa_call_ADD:
    sub $1, %ecx
    jmp citire_operatii                    # folosesc loop ca sa decrementez %ecx ul


call_GET:
    movl %esi, %edi
    
    pushl %ecx
    pushl $descriptor_fis
    pushl $formatScanf
    call scanf
    addl $8, %esp
    

    call GET
    popl %ecx

    jmp dupa_call_ADD

call_DELETE:

    movl %esi, %edi

    pushl %ecx
    pushl $descriptor_fis
    pushl $formatScanf
    call scanf
    addl $8, %esp

    call DELETE
    popl %ecx

    jmp dupa_call_ADD

call_DEFRAGMENTATION:
    movl %esi, %edi
    pushl %ecx
    call DEFRAGMENTATION
    popl %ecx
    jmp dupa_call_ADD

exit:  
    pushl $0
    call fflush
    pop %ebx

    movl $1, %eax
    movl $0, %ebx
    int $0x80
    