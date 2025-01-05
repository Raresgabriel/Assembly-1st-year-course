.data
nr_operatii: .space 4
operatie: .space 4
nr_descriptori: .space 4
i: .space 4
v: .space 4096
primul_index: .space 4
ultimul_index: .space 4
descriptor: .space 4
dimensiune: .space 4
opt: .long 8
nr_blocuri: .space 4
primul_index_zero: .space 4
index: .space 4
formatInt: .asciz "%d"
formatPrintfGet: .asciz "(%d, %d)\n"
formatPrintfFinal: .asciz "%d: (%d, %d)\n"
.text
    def_ADD:
    pushl $descriptor
    pushl $formatInt
    call scanf
    pop %ebx
    pop %ebx
    mov descriptor, %esi

    pushl $dimensiune
    pushl $formatInt
    call scanf
    pop %ebx
    pop %ebx

    xorl %ebx, %ebx
    xorl %edx, %edx
    movl dimensiune, %eax
    addl $7, %eax
    divl opt
    movl %eax, nr_blocuri

    lea v, %edi
    xorl %ecx, %ecx
    movl $0, primul_index
    movl $0, ultimul_index

    et_cauta_blocuri:
        cmp $1023, %ecx
        je et_imposibil_de_adaugat
        movl (%edi, %ecx, 4), %eax
        cmp $0, %eax
        jne et_resetare_cautare

        cmp $0, primul_index
        jne et_verifica_blocuri

        movl %ecx, primul_index
        movl nr_blocuri, %ebx

    et_verifica_blocuri:
        decl %ebx
        cmp $0, %ebx
        je et_gasit_blocuri
        incl %ecx
        cmp $1024, %ecx
        je et_imposibil_de_adaugat
        movl (%edi, %ecx, 4), %eax
        cmp $0, %eax
        jne et_resetare_cautare
        jmp et_verifica_blocuri

    et_gasit_blocuri:
        movl %ecx, ultimul_index
        jmp et_aloca_blocuri

    et_resetare_cautare:
        movl $0, primul_index
        incl %ecx
        jmp et_cauta_blocuri

    et_aloca_blocuri:
        movl primul_index, %ecx
        movl nr_blocuri, %ebx
    et_pune_blocuri:
        movl %esi, (%edi, %ecx, 4)
        incl %ecx
        decl %ebx
        cmp $0, %ebx
        jne et_pune_blocuri
        jmp et_afisare_interval

    et_imposibil_de_adaugat:
        movl $0, primul_index
        movl $0, ultimul_index

    et_afisare_interval:
        pushl ultimul_index
        pushl primul_index
        pushl descriptor
        pushl $formatPrintfFinal
        call printf
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx
        ret


     def_GET:
        pushl $descriptor
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx

        lea v, %edi
        xorl %ecx, %ecx
        movl $-1, primul_index
        movl $-1, ultimul_index

        et_cauta_primul_index:
            cmp $1024, %ecx
            je et_nu_exista
            movl (%edi, %ecx, 4), %eax
            cmp descriptor, %eax
            jne et_cauta_primul_index_next
            movl %ecx, primul_index
            jmp et_cauta_ult_index

        et_cauta_primul_index_next:
            incl %ecx
            jmp et_cauta_primul_index

        et_cauta_ult_index:
            incl %ecx
            cmp $1024, %ecx
            je et_seteaza_ultimul_final
            movl (%edi, %ecx, 4), %eax
            cmp descriptor, %eax
            je et_cauta_ult_index
            subl $1, %ecx
            movl %ecx, ultimul_index
            jmp et_setare_final

        et_seteaza_ultimul_final:
            movl $1023, ultimul_index
            jmp et_setare_final

        et_nu_exista:
            movl $0, primul_index
            movl $0, ultimul_index

        et_setare_final:
            cmp $-1, primul_index
            je et_afisare_eroare
            pushl ultimul_index
            pushl primul_index
            pushl $formatPrintfGet
            call printf
            pop %ebx
            pop %ebx
            pop %ebx
            xorl %ebx, %ebx
            ret

        et_afisare_eroare:
            movl $0, primul_index
            movl $0, ultimul_index
            pushl ultimul_index
            pushl primul_index
            pushl $formatPrintfGet
            call printf
            pop %ebx
            pop %ebx
            pop %ebx
            xorl %ebx, %ebx
            ret


    def_DELETE:
        pushl $descriptor
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx

        lea v, %edi
        xorl %ecx, %ecx

    et_cauta_si_sterge:
        cmp $1024, %ecx
        je et_final_del
        movl (%edi, %ecx, 4), %eax
        cmp descriptor, %eax
        jne et_cauta_urmator_bloc
        movl $0, (%edi, %ecx, 4)

    et_cauta_urmator_bloc:
        incl %ecx
        jmp et_cauta_si_sterge

    et_final_del:
        ret



    def_DEFRAMENTATION:
	    lea v, %edi
	    xorl %ecx, %ecx
	    xorl %ebx, %ebx

	et_parcurge_memoria:
	    cmp $1024, %ecx
	    je et_curatare
	    movl (%edi, %ecx, 4), %eax
	    cmp $0, %eax
	    je et_next_block

	    movl %eax, (%edi, %ebx, 4)
	    incl %ebx
	    jmp et_next_block

	et_next_block:
	    incl %ecx
	    jmp et_parcurge_memoria

	et_curatare:
	    cmp $1024, %ebx
	    je et_final_defrag
	    movl $0, (%edi, %ebx, 4)
	    incl %ebx
	    jmp et_curatare

	et_final_defrag:
	    ret

.global main

main:
    et_cate_operatii:
        pushl $nr_operatii
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx

    et_operatie:
        movl nr_operatii, %ebx
        xorl %ecx, %ecx
        cmp $0, %ebx
        je et_exit
        pushl $operatie
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx
        movl operatie, %ebx
        cmp $1, %ebx
            je et_ADD
        cmp $2, %ebx
            je et_GET
        cmp $3, %ebx
            je et_DELETE
        cmp $4, %ebx
            je et_DEFRAGMENTATION
	movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
	cmp $0, %ebx
	je et_exit
    
    et_ADD:
    movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
    	et_citire_descriptori:
    		pushl $nr_descriptori
    		pushl $formatInt
    		call scanf
    		pop %ebx
    		pop %ebx
    		xorl %ebx, %ebx
    		
    	et_adunare:
    		movl nr_descriptori, %ebx
    		cmp $0, %ebx
    		je et_operatie
    		
    		call def_ADD
    		
    		xorl %ecx, %ecx
    		movl nr_descriptori, %ebx
    		sub $1, %ebx
    		movl %ebx, nr_descriptori
    		cmp $0, %ebx
    		je et_operatie
    		jmp et_adunare
    	
    et_GET:
    movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
        call def_GET
        xorl %ecx, %ecx
        jmp et_operatie


    et_DELETE:
    movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
        call def_DELETE
        xorl %ecx, %ecx
    	jmp et_final_afisare
    
    et_DEFRAGMENTATION:
    	movl nr_operatii, %ebx
	    subl $1, %ebx
	    movl %ebx, nr_operatii
        call def_DEFRAMENTATION
        xorl %ecx, %ecx
        jmp et_final_afisare

        
        et_final_afisare:
            
            cmp $1024, %ecx
            je et_operatie
        
            cmp $0, (%edi, %ecx, 4)
            jne et_gasit_prim_index_final
            incl %ecx
            jmp et_final_afisare
        
        et_gasit_prim_index_final:
            movl (%edi, %ecx, 4), %eax
            movl %eax, descriptor
        	movl %ecx, primul_index
        	jmp et_cauta_ult_index_final

        et_cauta_ult_index_final:
            incl %ecx
            movl (%edi, %ecx, 4), %eax
            movl descriptor, %ebx
            cmp %ebx, %eax
            jne et_gasit_ultim_index_final
            jmp et_cauta_ult_index_final

        et_gasit_ultim_index_final:
            subl $1, %ecx
            movl %ecx, ultimul_index
            jmp et_final_get_final

        et_final_get_final:
            movl ultimul_index, %eax
            movl primul_index, %ebx
            movl descriptor, %ecx
            pushl %eax
            pushl %ebx
            pushl %ecx
            pushl $formatPrintfFinal
            call printf
            pop %ebx
            pop %ebx
            pop %ebx
            pop %ebx
            push $0
            call fflush
            pop %ebx
            xorl %ebx, %ebx
            movl ultimul_index, %ecx
            incl %ecx
            jmp et_final_afisare


    et_exit:
    	pushl $0
    	call fflush
    	popl %eax
        mov $1, %eax
        xorl %ebx, %ebx
        int $0x80

.section .note.GNU-stack,"",@progbits
