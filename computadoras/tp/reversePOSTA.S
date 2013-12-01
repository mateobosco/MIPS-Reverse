#include <sys/syscall.h>
#include <mips/regdef.h>


#define TAM_CADENA 100


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
		sw a0 , 44 (sp)				#guardo fd_in porque a0 se va a modificar
		#move s0 , a0
		sw a1 , 48 (sp) 			#guardo fd_put porque a1 se va a modificar
		#move s1 , a1

while:
		li t0 , 0 					#t0 es el tamano inicializado en 0
		lw a0 , 44 (sp) 			#cargo a0
		sw t0 , 24 (sp) 			#guardo el largo en la pila
		addiu a1 , sp , 24			#cargo en a1 la direccion de memoria donde se encuentra el largo en la pila, parametro de LineaLeer
		jal lineaLeer 				#llamo a la funcion
		lw t0 , 24 (sp) 			#cargo el largo de la linea

		bnez v1 , error		 		#compruebo errores
		beqz t0 , salida			#verifico que size sea mayor o igual a 0
		move a0 , v0				#paso por parametro a0 el puntero a la linea
		move a1 , t0				#paso por parametro a1 el tamano
		jal swap_enlinea			#llamo a la funcion swap_enlinea


		move a1 , a0 				#pongo en a1 la linea leida
		li v0 , SYS_write 
		lw a0 , 48(sp)			
		#move a0 , s0 				#cargo en a0 fd_out
		lw a2 , 24 (sp) 			#cargo en a2 el largo
		syscall
		blez v0 , manejo_error_escritura

		move a0 , a1 				#cargo en a0 la linea que fue leida
		jal myfree 					#llamo a myfree para liberar la linea
		bnez v0, manejo_error_myfree2


		addu a1 , sp , 20 			#cargo en a1 el puntero a la direccion del '\n' guardado en la pila
		li v0 , SYS_write
		li a0 , 1 																				#ME PARECE QUE ESTA LINEA NO HACE NADA
		li a2 , 1 		
		syscall
		blez v0 , manejo_error_escritura
		
		j while

manejo_error_myfree2:
		li v1 , 3 					#codigo de error en 3 															CAMBIAR LOS CODIGOS
		b error
manejo_error_escritura:
		li v1 , 4 					#codigo de error en 4 															CAMBIAR LOS CODIGOS

error:																					# TODO: Manejar error en v1 tengo codigo de error
	move v0,v1 						#devuelvo el codigo de error
	b desapilar

salida:
		li v0 , 0 					#devuelvo 0 en v0, se ejecuto sin problemas

desapilar:
		lw $fp , 32 (sp)
		lw gp , 36 (sp)
		lw ra , 40 (sp)
		lw a0 , 44 (sp)
		lw a1 , 48 (sp)
		addiu sp , sp , 40
		jr ra	

.end reverse


.ent swap_enlinea
swap_enlinea:
		subu sp , sp, 8				#solo hay que guardar fp y gp
		sw $fp , 0(sp)	
		sw gp , 4(sp)
		sw a0 , 12(sp) 																	#CREO QUE ES AL PEDO
		sw a1 , 16(sp)																	#CREO QUE ES AL PEDO
		move t0 , a0				#t0 puntero a vector
		move t1 , a1				#t1 largo del vector
		beqz t0 , fin_swap  
		li t2 , 0 					#cargo 0 en t2
		addiu t1 , t1 , -1 			#largo--

loop:								#i=t2 j=t1
		bgt t2 , t1 , fin_swap		#si t1>t2 salto a fin_swap
		addu t5 , t0 , t2 			#cargo t0+t1 en t5
		lb t3 , 0 (t5) 				#cargo en t3 el el valor de vector[i]
		addu t6 , t0 , t1 			#cargo t0+t2 en t6
		lb t4 , 0 (t6) 				#cargo en t4 el valor de vector[l]
		sb t4 , 0 (t5) 				#swap1
		sb t3 , 0 (t6)				#swap2
		addiu t2 , t2 , 1			#i++
		addiu t1 , t1 , -1			#l--
		b loop	 					#salto a loop

fin_swap:
		lw $fp , 0 (sp)	
		lw gp , 4 (sp)
		lw a0 , 12 (sp)																		#CREO QUE SON AL PEDO
		lw a1 , 16 (sp)																		#CREO QUE SON AL PEDO
		addiu sp , sp , 8			#$fp, gp
		jr ra

.end swap_enlinea



.globl lineaLeer
.ent lineaLeer
lineaLeer:			
		subu sp , sp , 40	
		sw $fp , 12 (sp)
		sw gp , 16 (sp)
		sw ra , 20 (sp)
		sw s0 , 24 (sp)
		sw s1 , 28 (sp)
		sw s2 , 32 (sp)
		sw s3 , 36 (sp)
		sw s4 , 40 (sp)
		sw a0 , 44 (sp)					#guardo el fd del archivo
		sw a1 , 48 (sp)					#guardo el puntero al largo del archivo
	
		move s0 , a0 					#muevo el fd al s0
		move s1 , a1					#muevo el puntero al largo a s1
		move s2 , zero					#cargo cero en i


		li a0 , TAM_CADENA				#resevo memoria para la linea
		move t7 , a0
		jal mymalloc					#llamo a mymalloc para reservar memoria para la linea
		move s3 , v0					#muevo a s3 el valor que devuelve mymalloc
		beqz s3 , manejo_error_mymalloc	#manejo de errores de mymalloc
	
		
		li a0,1							#reservo memoria para un caracter
		jal mymalloc					#llamo a mymalloc para reservar memoria para un caracter
		move s4 , v0					#muevo a s4 el valor que devuelve mymalloc
		beqz s4 , manejo_error_mymalloc	#manejo de errores de mymalloc

ciclo:	
		li v0 , SYS_read				#SYScall de read para leer un caracter
		move a0 , s0					#paso el primer parametro, fd al archivo
		move a1 , s4					#paso el segundo parametro, puntero al mymalloc
		li a2 , 1						#paso el tercer parametro, cantidad de caracteres a leer
		syscall
		bltz v0 , manejo_error_sysread
	
		lb t1 , 0 (s4)					#cargo en t1 la letra
		addu t2 , s3 , s2				#cargo en t2 el valor de linea[i]
		sb t1 , 0 (t2)					#cargo en linea[i] el valor de la letra
		addi s2 , 1						#incremento i
	
		li t2 , TAM_CADENA				#cargo en t2 el tamano inicial de la linea
		bne t2 , s2 , label				#si i es distinto que tam_cadena llamo a sin_realloc
		move a0 , s3					#pongo en a0 el valor devuelvo por mymalloc para reallocar
		sll a1 , t7 , 2					#incremento el valor tamano de la cadena
		move t7 , a1					
		jal myrealloc					#llamo a mymalloc
		beqz v0 , manejo_error_mymalloc	#manejo de error de mymalloc
		move s3 , v0					#muevo a s3 el valor que devuelve mymalloc

label:
		li t2 , 10						#cargo el t2 el valor de '\n'
		lw t1 , 0 (s4)					#cargo en 21 el valor de EOF
		beq t1 , t2 , fin_ciclo			#si la letra es un enter
		beqz t1 , fin_ciclo				#si la letra es un EOF
		b ciclo

fin_ciclo:
		addi s2 , -1					#resto 1 a i para escrbir arriba del enter o el EOF
		addu t2 , s3 , s2				#cargo en linea[i] el valor de t2
		li t1 , 0						#cargo un cero en t1
		sb t1 , 0 (t2)					#cargo en linea[i] un '\0' para indicar el final de una cadena
	
		move a0 , s4					#paso por parametro en a0 el puntero a la memoria que devuelve mymalloc
		jal myfree						#llamo a myfree para liberar memoria
		bnez v0 , manejo_error_myfree	#manejo el error de myfree
	
		bnez s2 , buen_fin				#llamo a buen_fin
		move a0 , s3					#si el largo es 0 libero memoria
		jal myfree						#llamo a myfree
		bnez v0 , manejo_error_myfree	#manejo error de myfree	
		b manejo_largo_cero				#llamo a largo_cero			

manejo_error_sysread:
		li v1 , 1						# codigo de error en 1 														CAMBIAR LOS CODIGOS
		b largo_cero
	
manejo_error_mymalloc:
		li v1 , 2						# codigo de error en 2 														CAMBIAR LOS CODIGOS
		b largo_cero
	
manejo_error_myfree:
		li v1 , 3						# codigo de error en 3 														CAMBIAR LOS CODIGOS
		b largo_cero

manejo_largo_cero:	
		li v1 , 0						# codigo de error en 0 														CAMBIAR LOS CODIGOS

largo_cero:
		move v0 , zero 
		sw zero , 0 (s1)				#paso el largo como parametro
		b fin
	
buen_fin:	
		move v0 , s3					#devuelvo el puntero a la linea
		li v1 , 0						#codigo de error en 0  														CAMBIAR LOS CODIGOS
		sw s2 , 0 (s1)					#paso el largo de parametro
		b fin
	
fin:	
		lw $fp , 12 (sp)
		lw gp , 16 (sp)
		lw ra , 20 (sp)
		lw s0 , 24 (sp)
		lw s1 , 28 (sp)
		lw s2 , 32 (sp)
		lw s3 , 36 (sp)
		lw s4 , 40 (sp)
		lw a0 , 44 (sp)
		lw a1 , 48 (sp)
		addiu sp, sp, 40
		jr ra
.end lineaLeer

.data
.align 2
.globl errores
errores: .word bien, error1, error2, error3, error4
		.size errores, 16
		.align 0
bien: .asciiz "Se ejecuto sin problemas"
error1: .asciiz "error1"
error2: .asciiz "error2"
error3: .asciiz "error3"
error4: .asciiz "error4"


