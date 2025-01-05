.data
i: .space 4
matrice: .space 4096
linii: .long 32
coloane: .long 32
IndexLinie: .space 4
IndexColoana: .space 4
descriptor: .space 4
dimensiune: .space 4
nr_blocuri: .space 4
primul_index_zero: .space 4
coloana_prim_index: .space 4
linie_prim_index: .space 4
coloana_ultim_index: .space 4
linie_ultim_index: .space 4
opt: .long 8
x: .long 1024
formatPrintGet: .asciz "(%d, %d), (%d, %d)\n"
formatPrintfFinal: .asciz "%d: (%d, %d), (%d, %d)\n"
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
        xorl %edx, %edx
        movl %eax, nr_blocuri

        lea matrice, %ecx
        xorl %ecx, %ecx
        xorl %ebx, %ebx

        et_cauta_zero:
            movl (%edi, %ecx, 4), %eax
            cmp $0, %eax
            je et_gasit_primul_index
            incl %ecx
            jmp et_cauta_zero
        
        et_gasit_primul_index:
            movl %ecx, primul_index_zero
		    jmp et_numara_locuri
        
        et_numara_locuri:
            incl %ebx
            cmp nr_blocuri, %ebx
            je et_pune_index
            incl %ecx
            movl (%edi, %ecx, 4), %eax
            cmp $0, %eax
            jne et_cauta_zero
            xorl %eax, %eax
            xorl %edx, %edx
            movl %ecx, %eax
            divl $32
            cmp %edx, $0
            je et_cauta_zero
            jmp et_numara_locuri
        
        et_gasit_spatiu:
            movl %esi, (%edi, %ecx, 4)
            incl %ecx
            sub $1, %ebx
            cmp $0, %ebx
            je et_final_add
            jmp et_gasit_spatiu

        et_final_add:
            xorl %esi, %esi
            ret

    def_GET:
        pushl $descriptor
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx
    
        lea matrice, %edi
        xorl %ecx, %ecx

        et_cauta_primul_index:
            movl (%edi, %ecx, 4), %eax
            movl descriptor, %ebx
            cmp %ebx, %eax
            je et_gasit_prim_index
            
            incl %ecx
            jmp et_cauta_primul_index
            
        et_gasit_prim_index:
        	movl %ecx, i
            movl %ecx, %eax
            xorl %edx, %edx
            divl x
            movl %eax, linie_prim_index
            movl %edx, coloana_prim_index
            movl i, %ecx
        	jmp et_cauta_ult_index

        et_cauta_ult_index:
            incl %ecx
            movl (%edi, %ecx, 4), %eax
            movl descriptor, %ebx
            cmp %ebx, %eax
            jne et_gasit_ultim_index
            jmp et_cauta_ult_index

        et_gasit_ultim_index:
            subl $1, %ecx
            xorl %edx, %edx
            movl %ecx, %eax
            divl x
            movl %eax, linie_ultim_index
            movl %edx, coloana_ultim_index
            jmp et_final_get

    def_DELETE:
        pushl $descriptor
        pushl $formatInt
        call scanf
        pop %ebx
        pop %ebx
        xorl %ebx, %ebx

        lea m, %edi
        xorl %ecx, %ecx
        et_cauta_primul_descriptor:
            movl (%edi, %ecx, 4), %eax
            movl descriptor, %ebx
            cmp %ebx, %eax
            je et_sterge_descriptor
            incl %ecx
            jmp et_cauta_primul_descriptor

        et_sterge_descriptor:
            movl $0, (%edi, %ecx, 4)
            incl %ecx
            movl (%edi, %ecx, 4), %eax
            movl descriptor, %ebx
            cmp %ebx, %eax
            jne et_final_del
            jmp et_sterge_descriptor

        et_final_del:
            ret

    def_DELETE:
.global main
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
        je et_final_afisare
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
	    je et_final_afisare

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
        jmp et_operatie


    et_DELETE:
    movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
        call def_DELETE
    	jmp et_operatie


    et_DEFRAGMENTATION:
    movl nr_operatii, %ebx
	subl $1, %ebx
	movl %ebx, nr_operatii
        call def_DEFRAMENTATION
        jmp et_operatie

.section .note.GNU-stack,"",@progbits