.data
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d\n"
    formatPrintfVerif: .asciz "*\n"
    formatPrintfADD: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatPrintfGET: .asciz "((%d, %d), (%d, %d))\n"
    numar_de_fisiere: .space 4
    numar_operatii: .space 4
    operatie: .space 4
    ID: .space 4
    dimensiune: .space 4
    spatiu_liber: .space 4
    poz_initiala: .space 4
    poz_finala: .space 4
    linie: .space 4
    cautat: .space 4
    precedent: .space 4
    spatiu_de_completat: .space 4
    v: .space 4194304

.text
.global main

ADD:
    pushl $numar_de_fisiere
    pushl $formatScanf
    call scanf
    addl $8, %esp

    movl numar_de_fisiere, %ebx


    citire_fisiere:
        cmp $0, %ebx
        je exit_ADD

        pushl $ID
        pushl $formatScanf
        call scanf
        addl $8, %esp

        pushl $dimensiune
        pushl $formatScanf
        call scanf
        addl $8, %esp

        movl dimensiune, %eax
        xorl %edx, %edx
        movl $8, %ecx
        divl %ecx                               # %eax = %eax / 8
        movl %eax, dimensiune
        cmp $0, %edx                            # daca exista rest => adaug un nou bloc la %eax
        jne adauga_unu 

    label:
        movl $0, %ecx                           # contorul pe linie

        while_i:
            cmp $1024, %ecx
            je nu_se_poate_adauga

            movl $0, %edx                       # contorul pe coloana

            movl %ecx, %eax                     # %eax = poz curenta
            pushl %ebx
            movl $1024, %ebx
            mull %ebx
            popl %ebx
            addl %edx, %eax

            while_j:
                cmp $1024, %edx
                je adauga_unu_la_linie

                pushl %ebx
                movl (%edi, %eax, 4), %ebx
                cmp $0, %ebx
                je caut_loc
                popl %ebx

                addl $1, %edx
                addl $1, %eax
                jmp while_j

        caut_loc:
            /*pushl %ecx
            pushl %edx
            pushl $formatPrintf
            call printf
            addl $4, %esp
            popl %edx
            popl %ecx */

            popl %ebx
            movl $0, %esi                       # %esi = spatiul liber
            movl %edx, poz_initiala

            while_caut_loc:
                cmp dimensiune, %esi
                je afisare_ADD

                cmp $1024, %edx
                je adauga_unu_la_linie

                movl %ecx, %eax                 # %eax = poz curenta
                pushl %ebx
                movl $1024, %ebx
                pushl %edx
                xorl %edx, %edx
                mull %ebx
                popl %edx
                addl %edx, %eax
                
                movl (%edi, %eax, 4), %ebx
                cmp $0, %ebx
                jne da_pop
                popl %ebx
                addl $1, %edx
                addl $1, %esi
                jmp while_caut_loc
    

    afisare_ADD:
        subl $1, %edx
        movl %edx, poz_finala
        movl %ecx, linie

        pushl poz_finala
        pushl linie
        pushl poz_initiala
        pushl linie
        pushl ID
        pushl $formatPrintfADD
        call printf
        addl $24, %esp

        jmp adauga


    adauga:
        subl $1, %ebx
        movl dimensiune, %ecx
        movl linie, %eax
        movl $1024, %edx
        mull %edx
        addl poz_initiala, %eax

        loop_adauga:
        /*
            pushl %eax
            pushl %ecx
            pushl %edx

            pushl %ecx
            pushl $formatPrintf
            call printf
            addl $8, %esp

            popl %edx
            popl %ecx
            popl %eax*/

            cmp $0, %ecx
            je citire_fisiere
            movl ID, %edx
            movl %edx, (%edi, %eax, 4)
            addl $1, %eax
            subl $1, %ecx
            jmp loop_adauga


    adauga_unu:
        addl $1, %eax
        movl %eax, dimensiune
        jmp label

    nu_se_poate_adauga:
        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl ID
        pushl $formatPrintfADD
        call printf
        addl $24, %esp

        subl $1, %ebx
        jmp citire_fisiere

    adauga_unu_la_linie:
        addl $1, %ecx
        jmp while_i

    da_pop:
        popl %ebx
        #addl $1, %edx
        jmp while_j

    exit_ADD:
        ret



GET:
    pushl $cautat
    pushl $formatScanf
    call scanf
    addl $8, %esp
    
    /*pushl cautat
    pushl $formatPrintf
    call printf
    addl $8, %esp*/

    movl $0, %ebx                       # %ebx = contorul de linie ( i )           
    movl $0, %ecx                       # %ecx = contorul de coloana ( j )

    while_linie: 
        cmp $1024, %ebx
        je nu_exista
        movl $0, %ecx                       # %ecx = contorul de coloana ( j )

        while_coloana:
            cmp $1024, %ecx
            je adauga_1_la_linie

            xorl %edx, %edx
            movl $1024, %eax
            mull %ebx
            addl %ecx, %eax             # %eax = linie * 1024 + j

            movl cautat, %edx
            cmp %edx, (%edi, %eax, 4)
            je am_gasit

            addl $1, %ecx
            jmp while_coloana


    am_gasit:
        movl %ebx, linie
        movl %ecx, poz_initiala

        while_am_gasit:
            cmp $1025, %ecx
            je exit_GET

            xorl %edx, %edx
            movl $1024, %eax
            mull %ebx
            addl %ecx, %eax 

            movl cautat, %edx
            cmp %edx, (%edi, %eax, 4)
            jne gata_cautarea

            addl $1, %ecx
            jmp while_am_gasit


    gata_cautarea:
        subl $1, %ecx

        pushl %ecx
        pushl linie
        pushl poz_initiala
        pushl linie
        pushl $formatPrintfGET
        call printf
        addl $20, %esp

        jmp exit_GET


    nu_exista:
        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl $formatPrintfGET
        call printf
        addl $20, %esp


    exit_GET:
        ret

    adauga_1_la_linie:
        addl $1, %ebx
        jmp while_linie

DELETE:

    pushl $cautat
    pushl $formatScanf
    call scanf
    addl $8, %esp

    /*
    pushl cautat
    pushl $formatPrintf
    call printf
    addl $8, %esp*/

    movl $0, %ebx                       # %ebx = contorul de linie ( i )           
    movl $0, %ecx                       # %ecx = contorul de coloana ( j )

    while_linie1: 
        cmp $1024, %ebx
        je afisare_DELETE                    # to do merge la afisare
        movl $0, %ecx                       # %ecx = contorul de coloana ( j )

        while_coloana1:
            cmp $1024, %ecx
            je adauga_1_la_linie1

            movl $1024, %eax
            mull %ebx
            addl %ecx, %eax             # %eax = linie * 1024 + j

            movl cautat, %edx
            cmp %edx, (%edi, %eax, 4)
            je am_gasit1

            addl $1, %ecx
            jmp while_coloana1


    am_gasit1:

        while_am_gasit1:
            cmp $1025, %ecx
            je exit_DELETE  

            movl $1024, %eax
            mull %ebx
            addl %ecx, %eax 

            movl cautat, %edx
            cmp %edx, (%edi, %eax, 4)
            jne afisare_DELETE

            movl $0, (%edi, %eax, 4)

            addl $1, %ecx
            jmp while_am_gasit1

    afisare_DELETE:
        movl $0, %ebx

        while_l:
            movl $0, precedent
            movl $0, %ecx 
            cmp $1024, %ebx
            je exit_DELETE

            while_c:
                cmp $1024, %ecx
                je adauga_1_la_linie2

                movl $1024, %eax
                mull %ebx
                addl %ecx, %eax 

                movl precedent, %edx
                cmp %edx, (%edi, %eax, 4)
                jne printare                                  # am gasit un nou element 

                addl $1, %ecx
                jmp while_c

        printare:
            movl $0, %edx
            cmp %edx, (%edi, %eax, 4)
            je este_zero

            movl %ebx, linie
            movl %ecx, poz_initiala
            movl (%edi, %eax, 4), %edx
            movl %edx, precedent

            while_printare:
                movl $1024, %eax
                mull %ebx
                addl %ecx, %eax

                movl precedent, %edx
                cmp %edx, (%edi, %eax, 4)
                jne printare2
                addl $1, %ecx
                jmp while_printare

            printare2:
                subl $1, %ecx
                movl %ecx, poz_finala
                addl $1, %ecx

                pushl %ecx

                pushl poz_finala
                pushl linie
                pushl poz_initiala
                pushl linie
                pushl precedent
                pushl $formatPrintfADD
                call printf
                addl $24, %esp

                popl %ecx
                jmp while_c


    este_zero:
        movl $0, precedent
        jmp while_c

    exit_DELETE:
        ret

    adauga_1_la_linie1:
        addl $1, %ebx
        jmp while_linie1

    adauga_1_la_linie2:
        addl $1, %ebx
        jmp while_l


DEFRAGMENTATION: 
/*
    movl $0, %ecx                       # %ecx = contorul de linie
    movl $0, spatiu_liber
    movl $0, poz_initiala

    while_i_def:
        pushl %eax
            pushl %edx
            pushl %ecx
            pushl $formatPrintf
            call printf
            popl %ecx
            popl %ecx
            popl %edx
            popl %eax

        cmp $1024, %ecx
        je exit_DEFRAGMENTATION

        label_def:
            movl $0, %edx                   # %edx = contorul de coloana
            movl $1024, %eax
            mull %ecx 
            #movl poz_initiala, %edx
            addl %edx, %eax                 # %eax = pozitia curenta

        while_j_def:
            pushl %eax
            pushl %ecx
            pushl %edx
            pushl $formatPrintf
            call printf
            popl %ecx
            popl %edx
            popl %ecx
            popl %eax

            cmp $1024, %edx
            je verifica_spatiu_liber
            movl (%edi, %eax, 4), %esi                  # %esi = elementul curent

            pushl %eax
            pushl %ecx
            pushl %edx
            pushl %esi
            pushl $formatPrintf
            call printf
            popl %ecx
            popl %esi
            popl %edx
            popl %ecx
            popl %eax

            cmp $0, %esi
            je verifica_daca_este_doar_0_dupa
            addl $1, %edx
            addl $1, %eax
            jmp while_j_def

        
    verifica_daca_este_doar_0_dupa:
            pushl %eax
            pushl %ecx
            pushl %edx
            pushl $formatPrintfVerif
            call printf
            popl %ecx
            popl %edx
            popl %ecx
            popl %eax

        movl %edx, poz_initiala
        loop_verifica:
            cmp $1024, %edx
            je verifica_daca_toata_linia_e_0
            movl (%edi, %eax, 4), %esi
            cmp $0, %esi
            jne permutare                       # daca exista un element != 0 => pot face permutarea
            addl $1, %edx
            addl $1, %eax
            jmp loop_verifica

    verifica_daca_toata_linia_e_0:
        subl poz_initiala, %edx
        cmp $1024, %edx                                 # daca linia e plina de 0-uri, vreau sa scap de ea
        je permut_toate_liniile
        addl poz_initiala, %edx
        jmp verifica_spatiu_liber

    permut_toate_liniile:
        movl %ecx, linie  
        movl $-1, %ecx     

        loop_pe_coloana: 
            addl $1, %ecx 
            cmp $1024, %ecx
            je adaug_o_linie_de_0

            xorl %edx, %edx
            movl $1024, %eax                        # %eax = pozitia de inceput a liniei pe care o sterg
            mull %ecx
            loop_pe_linie:  
                cmp $1047552, %edx                  # daca se ajunge pe linia 1023, se opreste
                jge loop_pe_coloana
                addl $1024, %eax
                movl (%edi, %eax, 4), %esi
                subl $1024, %eax
                movl %esi, (%edi, %eax, 4)              # fac permutarea v[i] = v[i+1024]
                addl $1024, %eax
                addl $1024, %edx
                jmp loop_pe_linie
            

    adaug_o_linie_de_0:
        cmp $1048576, %edx
        je label2
        movl $0, (%edi, %eax, 4)
        addl $1, %edx
        addl $1, %eax
        jmp adaug_o_linie_de_0

    label2:
        movl linie, %ecx
        jmp while_i


    permutare:
        movl %ecx, linie
        movl $0, %edx                  
        movl $1024, %eax
        mull %ecx
        movl poz_initiala, %edx
        addl %edx, %eax                 # %eax = pozitia curenta              

        loop_permutare:
            cmp $1023, %edx                          # permut toate elementele pana la penultima pozitie
            je adauga_la_final
            addl $1, %edx
            addl $1, %eax
            movl (%edi, %eax, 4), %ebx              #retin elementul urmator
            subl $1, %edx
            subl $1, %eax
            movl %ebx, (%edi, %eax, 4)              # fac mutare: v[i] = v[i+1]
            addl $1, %edx
            addl $1, %eax
            jmp loop_permutare

        adauga_la_final:
            movl $0, (%edi, %eax, 4)                # pentru ca am permutat toate elementele spre stanga cu o pozitie
                                                    # acum adaug 0 la finalul vectorului
            jmp label


    verifica_spatiu_liber:                      # aici vreau sa vad daca primele elemente pot fi puse in spatiul liber ramas
        movl $0, %edx
        movl $1024, %eax
        mull %ecx
        addl %edx, %eax
        movl (%edi, %eax, 4), %esi
        movl %esi, precedent

        loop_verifica_spatiu:
            movl (%edi, %eax, 4), %esi
            cmp precedent, %esi
            jne verifica_daca_intra_in_spatiu_liber
            addl $1, %edx
            addl $1, %eax
            jmp loop_verifica_spatiu

    verifica_daca_intra_in_spatiu_liber:
        cmp spatiu_liber, %edx
        jle pune_in_spatiu_liber
        jmp update_noul_spatiu_liber_alta_linie         # altfel dau update la noul spatiu_liber pentru linia %ecx


    pune_in_spatiu_liber:
        movl %edx, spatiu_de_completat
        movl $1024, %ebx
        subl spatiu_liber, %ebx                      # %ebx = coloana de unde incep sa pun elementele
        xorl %edx, %edx
        movl linie, %eax
        movl $1024, %esi
        mull %esi
        addl %ebx, %eax                                    # %eax = pozitia unde pun valoarea

        loop_pune_in_spatiu_liber:
            cmp spatiu_de_completat, %edx
            je update_noul_spatiu_liber
            movl (%edi, %eax, 4), %esi
            movl precedent, %esi
            addl $1, %eax
            addl $1, %edx
            jmp loop_pune_in_spatiu_liber

        update_noul_spatiu_liber:
            subl $1, %edx
            addl %edx, %ebx
            cmp $1023, %ebx
            je update_noul_spatiu_liber_alta_linie
            movl $1023, %edx
            subl %ebx, %edx
            movl %edx, spatiu_liber
            addl $1, %ecx
            xorl %edx, %edx
            jmp while_i_def

    update_noul_spatiu_liber_alta_linie:
        movl %ecx, linie
        movl $1024, %eax
        mull %ecx
        xorl %edx, %edx

        loop_update_noul_spatiu_liber_alta_linie:   
            movl (%edi, %eax, 4), %esi
            cmp $0, %esi
            je noul_spatiu_liber_alta_linie
            addl $1, %eax
            addl $1, %edx
            jmp loop_update_noul_spatiu_liber_alta_linie

        noul_spatiu_liber_alta_linie:
            movl $1024, %ebx
            subl %edx, %ebx
            movl %edx, spatiu_liber
            addl $1, %ecx
            xorl %edx, %edx
            jmp while_i_def
*/

    exit_DEFRAGMENTATION:
        ret


main:
    lea v, %edi
    lea v, %esi

    pushl $numar_operatii
    pushl $formatScanf
    call scanf
    addl $8, %esp

    movl numar_operatii, %ebx

    citire_operatii:
        cmp $0, %ebx
        je exit

        movl %esi, %edi

        pushl $operatie
        pushl $formatScanf
        call scanf
        addl $8, %esp

        movl operatie, %ecx
        cmp $1, %ecx
        je call_ADD

        cmp $2, %ecx
        je call_GET

        cmp $3, %ecx
        je call_DELETE

        jmp call_DEFRAGMENTATION


    call_ADD:
        pushl %esi
        pushl %ebx
        call ADD
        popl %ebx
        popl %esi
        subl $1, %ebx
        jmp citire_operatii

    call_GET:
        pushl %esi
        pushl %ebx
        call GET
        popl %ebx
        popl %esi
        subl $1, %ebx
        jmp citire_operatii

    call_DELETE:
        pushl %esi
        pushl %ebx
        call DELETE
        popl %ebx
        popl %esi
        subl $1, %ebx
        jmp citire_operatii

    call_DEFRAGMENTATION:
        pushl %ebx
        call DEFRAGMENTATION 
        popl %ebx
        subl $1, %ebx
        jmp citire_operatii

exit:
    pushl $0
    call fflush
    pop %ebx

    movl $1, %eax
    movl $0, %ebx
    int $0x80
    