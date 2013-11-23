#include <sys/syscall.h>
#include <mips/regdef.h>


#define TAM_CADENA 20
#define TAMANO_PILA 40

.text
.align 2
.globl reverse
.ent reverse
reverse:	
		subu sp , sp , 40 			#RESERVO UN LUGAR PARA LA PILA DE 40
		li t0 , 10 					# '\n' = 10, lo cargo en t0
		sb t0 , 20 (sp) 			#guardo el '\n' en la pila
		sw $fp , 32 (sp) 			#guardo el fp
		sw gp , 36 (sp) 			#guardo el gp
		sw ra , 40 (sp) 			#guardo el ra
		#sw a0 , 44 (sp)			#guardo fd_in porque a0 se va a modificar
		move s0, a0
		#sw a1 , 48 (sp) 			#guardo fd_put porque a1 se va a modificar
		move s1, a1

while:
		li t0 , 0 					#t0 es el tamano inicializado en 0
		lw a0 , 44 (sp) 			#cargo a0
		sw t0 , 24 (sp) 			#guardo el largo en la pila
		addiu a1 , sp , 24			#cargo en a1 la direccion de memoria donde se encuentra el largo en la pila, parametro de LineaLeer
		jal LineaLeer 				#llamo a la funcion
		lw , 24 (sp) 				#cargo el largo de la linea

imprime_linea:
		move a0 , a1 				#pongo en a0 la linea leida
		li v0 , SYS_write 
		#lw a0 , 48(sp)			
		move a0 , s0 				#cargo en a0 fd_out
		lw a2 , 24 (sp) 			#cargo en a2 el largo
		syscall
		blez v0 , manejo_error_escritura

		move a0 , a1 				#cargo en a0 la linea que fue leida
		jal myfree 					#llamo a myfree para liberar la linea
		blez v0, manejo_error_myfree2

imprimo_enter:
		addu a1 , sp , 20 			#cargo en a1 el puntero a la direccion del '\n' guardado en la pila
		li v0 , SYS_write
		#li a0 , 1 					#ME PARECE QUE ESTA LINEA NO HACE NADA
		li a2 , 1 		
		syscall
		blez v0 , manejo_error_escritura
		
		j while

manejo_error_myfree2:
		li v1 , 3 					#codigo de error en 3 CAMBIAR LOS CODIGOS
manejo_error_escritura:
		li v1 , 4 					#codigo de error en 4 CAMBIAR LOS CODIGOS

salida:
		li v0 , 0 					#devuelvo 0 en v0, se ejecuto sin problemas

desapilar:
		lw $fp, 32(sp)
		lw gp, 36(sp)
		lw ra, 40(sp)
		lw a0, 44(sp)
		lw a1, 48(sp)
		addiu sp, sp, 40
		jr ra	

.end reverse



.ent swap_enlinea
swap_enlinea:
		subu sp , sp, 8				#solo hay que guardar fp y gp
		sw $fp , 0(sp)	
		sw gp , 4(sp)
		#sw a0 , 12(sp) 			#CREO QUE ES AL PEDO
		#sw a1 , 16(sp)				#CREO QUE ES AL PEDO
		move t0 , a0				#t0 puntero a vector
		move t1 , a1				#t1 largo del vector
		beqz t0 , fin_swap  
		li t2 , 0 					#cargo 0 en t2
		addiu t1 , t1 , -1 #largo--

while:								#i=t2 j=t1
		bgt t2 , t1 , fin_swap		#si t1>t2 salto a fin_swap
		addu t5 , t0 , t2 			#cargo t0+t1 en t5
		lb t3 , 0 (t5) 				#cargo en t3 el el valor de vector[i]
		addu t6 , t0 , t1 			#cargo t0+t2 en t6
		lb t4 , 0 (t6) 				#cargo en t4 el valor de vector[l]
		sb t4 , 0 (t5) 				#swap1
		sb t3 , 0 (t6)				#swap2
		addiu t2 , t2 , 1			#i++
		addiu t1 , t1 , -1			#l--
		b while 					#salto a while

fin_swap:
		lw $fp , 0 (sp)	
		lw gp , 4 (sp)
		#lw a0 , 12 (sp)			#CREO QUE SON AL PEDO
		#lw a1 , 16 (sp)			#CREO QUE SON AL PEDO
		addiu sp , sp , 8			#$fp, gp
		jr ra

.end swap_enlinea




