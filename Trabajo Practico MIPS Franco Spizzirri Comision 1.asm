.data
slist: 	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: 	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error: 	.asciiz "Error: "
return: .asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operación se realizo con exito\n\n"
greater_symbol: .asciiz ">"
opcion_invalida: .asciiz "\nOpción inválida. Inténtelo de nuevo.\nError (101)."
mensaje_no_encontrado: .asciiz "Not Found. \n"

.text
main:
	la $t0, schedv #carga en t0 a schedv 
	la $t1, newcategory
	sw $t1, 0($t0)              # Opción 1: Nueva categoría

	la $t1, Categoria_siguiente
	sw $t1, 4($t0)              # Opción 2: Siguiente categoría

	la $t1, Categoria_previa
	sw $t1, 8($t0)              # Opción 3: Categoría anterior

	la $t1, ListarCategorias
	sw $t1, 12($t0)             # Opción 4: Listar categorías

	la $t1, BorrarCategoria
	sw $t1, 16($t0)             # Opción 5: Borrar categoría

	la $t1, NuevoObjeto
	sw $t1, 20($t0)             # Opción 6: Añadir objeto

	la $t1, ListarObjt
	sw $t1, 24($t0)             # Opción 7: Listar objetos

	la $t1, Borrar_objt
	sw $t1, 28($t0)             # Opción 8: Borrar objeto

menu_loop:
    	la $a0, menu # Mostrar el menú
    	li $v0, 4
    	syscall
    	
    	li $v0, 5 # Leer opción del usuario
    	syscall
    	move $t2, $v0 # Guardar opción (v0) en $t2

    	beqz $t2, exit # Verificar rango de opción válida (1-8). Si ingresa 0, el programa termina. 
    	li $t3, 1
    	blt $t2, $t3, opcion_invalida_etiqueta #si la opcion que ingrese (guardada en t2) es menor a 1, que salte la etiqueta de error. 
    	li $t3, 8
    	bgt $t2, $t3, opcion_invalida_etiqueta #si la opcion que ingrese(guardada en t2) es mas grande que 8, que salte la etiqueta de error. 

    	subi $t2, $t2, 1 # Calcular la posición en schedv (opción - 1) * 4
    	sll $t2, $t2, 2 #multiplicas por 4. 
    	la $t0, schedv # carga la direccion base de schedv en $t0. 
    	add $t0, $t0, $t2  # $t0 ahora tiene la dirección de la función en schedv

    	# Llamar a la subrutina a través de la dirección en $t0
    	lw $t1, 0($t0) #cargas al direccion de la funcion
    	#move $t1, $ra
    	jalr $t1                 # Saltar a la subrutina correspondiente

    	# Regresar al bucle del menú después de ejecutar la opción
    	j menu_loop

opcion_invalida_etiqueta:
    	# Mensaje de opción inválida
    	la $a0, opcion_invalida #lo tenes que cargar en a0 xq es el registro que la syscall usa para imprimir cadenas. 
    	li $v0, 4
    	syscall
    	j menu_loop                # Regresar al menú

newcategory:
	addiu $sp, $sp, -4 #reserva word en stack (espacio para la pila) para guardar la direccion de salto. 
	sw $ra, 4($sp)	   #guardas la direccion de retorno. 	
	la $a0, catName    # input category name, deja en $a0 catname para poder imprimirlo. (tiene el asciiz q dice ingrese el nombre de una categoria). 
	jal getblock
	move $a2, $v0 # $a2 = *char to category name (puntego al nombre de la categoria, la direccion de la categoria). Mueve la direccion de la categoria (si tengo escrito "gatos", mueve gatos ahi) a a2. 
	la $a0, cclist # $a0 = list
	li $a1, 0 # $a1 = NULL. Carga un 0 en a1. Que ahi estaba guardado el espacio (+ 16 bytes). 
	jal addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # update working list if was NULL
newcategory_end:
	li $v0, 0 # return success
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
Categoria_siguiente:
    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)

    	lw $t0, cclist # Dejo en $t0 el comienzo de la lista
    	beqz $t0, error_201 #Si es igual a 0, error 201

    	lw $t1, wclist # Dejo en $t1 la cat en curso
    	lw $t2, 12($t1) # Cargo en $t2 la sig
    	beq $t1, $t2, error_202 # Si la sig es igual a la en curso, significa que hay una sola.

    	sw $t2, wclist
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	li $v0, 0
    	j Categoria_siguiente_fin
error_201:
    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 201
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 201
    	j Categoria_siguiente_fin
error_202:
    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 202
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 202 # borrar esto
Categoria_siguiente_fin:
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    
Categoria_previa:
    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)
    	
    	lw $t0, cclist        # Cargar la lista de categorías
    	beqz $t0, error_201   # Si cclist es NULL, no hay categorías (error 201)

    	lw $t1, wclist # Dejo en $t1 la cat en curso
    	lw $t2, 0($t1) # Cargo en $t2 la ant
    	beq $t1, $t2, error_202 # Si la ant es igual a la en curso, significa que hay una sola.
 
    	sw $t2, wclist

    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall              # Imprimir mensaje

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra               # Volver

ListarCategorias:
    	lw $t0, cclist
    	beqz $t0, Listar_error_301
    	lw $t2, wclist
    	move $t1, $t0
       
Listar_loop:
    	bne $t1, $t2, Listar_loop2
Imprimir_simbolo:
    	la $a0, greater_symbol
    	syscall
Listar_loop2:
    	lw $a0, 8($t1)
    	li $v0, 4
    	syscall
    	lw $t1, 12($t1)
    	bne $t1, $t0, Listar_loop

ListarCategorias_fin:
    	jr $ra

Listar_error_301:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 301
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 301
    	j ListarCategorias_fin
    
    
BorrarCategoria:
    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_401

    	lw $t1, 4($t0)   # Lista de objetos en la categoría
    	beqz $t1, BorrarCategoria_sin_objt

    	move $a0, $t1
    	jal Borrar_todos_objt  # Llama a una función que borra todos los objetos
	
BorrarCategoria_sin_objt:
    	lw $a0, wclist
    	lw $a1, cclist
    	lw $t5, 12($a0)
    	beq $t5, $a0, Borrar_ultm_cat
    	sw $t5, wclist
    	bne $a0, $a1,  Borra_nodo_cat
    	sw $t5, cclist
    	j Borra_nodo_cat
    	#sw $t5, cclist
Borrar_ultm_cat:
    	sw $zero, cclist
	sw $zero, wclist
    	
Borra_nodo_cat:	
	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

error_401:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 401
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 401
    	jr $ra
    
NuevoObjeto:
    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, cclist
    	beqz $t0, error_501

    	# Obtener nombre del objeto
    	la $a0, objName
    	jal getblock
    	move $a2, $v0
    	lw $t0, wclist
    	addi $t0, $t0, 4
    	move $a0, $t0
    	lw $t5, ($a0)
    	bnez  $t5, OtroObjt
    	li   $a1, 1
    	jal addnode
    	j   NuevoObjeto_fin
    
OtroObjt:
    	lw $t4, ($t5)
    	lw $t5, 4($t4)
    	addiu $a1, $t5, 1
    	jal addnode

NuevoObjeto_fin:
    	li $v0, 0
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
	
error_501:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 501
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 501
    	jr $ra
    
    
ListarObjt:
    	lw $t0, wclist
    	beqz $t0, error_601

    	lw $t1, 4($t0)
   	beqz $t1, error_602

    	move $t2, $t1
ListarObjt_loop:
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	lw $t2, 12($t2)
    	bne $t2, $t1, ListarObjt_loop

    	li $v0, 0
    	jr $ra

error_601:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 601
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 601
    	jr $ra

Borrar_todos_objt:
    	addiu $sp, $sp, -4           
    	sw $ra, 4($sp)               

    	lw $t0, wclist               # $t0 apunta a la categoría seleccionada

    	beqz $t1, error_602          # Si la lista está vacía, saltamos a error_602

    	# Comenzamos a recorrer la lista de objetos
Borrar_objt_loop:
    	lw $t2, 12($t1)              # $t2 contiene el puntero al siguiente objeto
    	lw $t3, 0($t1)               # $t3 contiene el puntero al objeto anterior
    	lw $t4, 8($t1)               # $t4 apunta al puntero de nombre del objeto (suponiendo que esté en el offset 8)
    
    	sw $t3, 0($t2)		# Establecer el anterior puntero del objeto siguiente
    	sw $t2, 12($t3) 		# Establecer el siguiente puntero del objeto anterior
    	# Limpiar los valores dentro del objeto
    	li $t5, 0                    # Cargar el valor 0
    	sw $t5, 0($t1)               # Poner a cero el puntero anterior (nodo anterior)
    	sw $t5, 4($t1)               # Poner a cero el puntero siguiente (nodo siguiente)
    	sw $t5, 8($t1)               # Poner a cero el puntero al nombre (nodo nombre)
    	move $a0, $t1 # Liberar el bloque de memoria del objeto
    	jal sfree                   
    	beq $t2, $t1, Borrar_objt_fin  # Si hemos llegado al final de la lista (el siguiente es igual al primero), terminamos Si el siguiente objeto es el primero, salimos del bucle
    	move $t1, $t2 # Continuamos con el siguiente objeto
    	j Borrar_objt_loop

Borrar_objt_fin:		
    	lw $t0, wclist # Si hemos eliminado todos los objetos, actualizamos la lista de objetos de la categoría
    	sw $zero, 4($t0)# Establecemos la lista de objetos a NULL en la categoría seleccionada
    	li $v0, 0 # Indicamos que la operación se completó con éxito

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra 

error_602:  # Si la lista de objetos está vacía, devolvemos un error
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 602
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 602
    	jr $ra


 
    
Borrar_objt:
    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_701
	
	
    	la $a0, idObj
    	li $v0, 4
    	syscall
     
    	li $v0, 5
    	syscall
    								
    	move $t1, $v0  # ID buscado
    	lw $t2, 4($t0) # Primer objeto
  	
    	lw $t4, 0($t2) # ultimo objeto
    	lw $t3, 4($t4) #ID ultimo objeto
    	li $t5, 0
  
    	move $a1, $t2
       
Borrar_obj_loop:
    	lw $t3, 4($t2)
    	beq $t1, $t3, Borrar_objt_encontrado
    	lw $t2, 12($t2)
    	bgt $t5, $t3, no_encontrado
    	addiu $t5, $t5, 1
    	bne $t2, $zero, Borrar_objt_loop

no_encontrado:
	la $a0, mensaje_no_encontrado
    	li $v0, 4
    	syscall
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

 Borrar_objt_encontrado:
    	lw $t4, 4($t0)
    	beq $t2, $t4, actualiz_list_objt
    	
 Borrar_objt_encontrado2:   
    	move $a0, $t2
    	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
   	jr $ra
    
actualiz_list_objt:
    	lw  $t5, 12($t2)     #$t5 queda con el objeto siguiente
    	addiu $t4, $t0, 4    #cargo la direccion donde la categoria tiene el puntero de la lista de objetos
    	seq $t6, $t5, $t2    #si el siguiente objeto es el mismo a eliminar significa que hay uno solo
    	bnez $t6, actualiz_list_objt2 #si lo anterior era ver $t6 tendria q ser 1 y saltar a update2
    	sw  $t5, 0($t4)	
    	j   Borrar_objt_encontrado2
    
actualiz_list_objt2:
    	sw  $zero, 0($t4)	#actualizo el puntero de lista objetos a 0
    	j   Borrar_objt_encontrado2  
    
error_701:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 701
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
   	li $v0, 701
    	jr $ra
    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp) #guarda en el stack el ra de newcategory. 
	sw $a0, 4($sp) #guarda el puntero a cclist. 
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list
addnode_to_end:
	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# updat	e prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
addnode_empty_list:
	sw $v0, ($a0) 
	sw $v0, 0($v0)
	sw $v0, 12($v0)
addnode_exit:
	lw $ra, 8($sp) # entra a la direccion de newcategory, lo guarda otra vez en ra y vuelve el stack al mismo tamaño
	addi $sp, $sp, 8
	jr $ra
# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0
node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0) # el anterior pasa a la siguiente categoria
	sw $t0, 12($t1)
	lw $t1, 0($a1) # get address to first node
again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit
delnode_point_self:
	sw $zero, ($a1) # only one node
	#sw $zero, cclist
	#sw $zero, wclist
delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: msg to ask
# v0: block address allocated with string
getblock:
	addi $sp, $sp, -4 #reserva espacio para la direccion de salto. 
	sw $ra, 4($sp) #guardo en stack el ra de newcategory
	li $v0, 4 #imprime el mensaje de catname. 
	syscall	
	jal smalloc
	move $a0, $v0 # guarda en a0 la direccion de heap + nodo (16 bytes). Guarda la direcciond el heap en la que quedo. Despues de hacer la reserva de 16 bytes, que son los dos nodos y el mensaje.  
	li $a1, 16 #podes escribir hasta 16 caracteres, en a1 guardas el maximo numero de caracteres para leer.
	li $v0, 8 #con este llamado te pide q ingreses la categoria. 
	syscall
	move $v0, $a0 #mueve la direccion a v0. Xq em v0 se modifica cuando haces syscall (queda con 8), para q vuelva a tener la misma direccion de los 16 bytes guardados. La categoria la guarda en el Heap. Pone el dato despues de los 4 words reservados. 
	lw $ra, 4($sp) #carga en el stack el ra de newcategory
	addi $sp, $sp, 4 #devuelve el espacio q se tomo para almacenar la pila, pero la pila no esta como el inicio. 
	jr $ra #vuelve a newcategory. 
	 
smalloc:  
	lw $t0, slist #carga en t0 el contenido del puntero slist
	beqz $t0, sbrk # si t0 = 0, salta a sbrk. Luego, este t0 no va a ser = 0, en el primer nodo reserva y luego se va moviendo con el siguiente. 
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk: #aca va al heap. 
	li $a0, 16 # node size fixed 4 words. Pones la cantidad de bytes que queres reservar. 
	li $v0, 9  # llamo al heap reservando 16 bytes / 4 words. Lo cargas en la llamada. 
	syscall # return node address in v0, te la la proxima direccion del heap que esta libre. 
	jr $ra #va a lo ultimo guardado en ra, que es la direccion de retorno de getblock. La segunda vez vuelve a addnode. 
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra
	
exit:
	li $v0, 10
	syscall

