.data
slist: 	.word 0 # Puntero que utilizaran las funciones smalloc y sfree. Es una lista de bloques de memoria libres para asignar nodos
cclist: .word 0 # Puntero a lista de categorias
wclist: .word 0 # Puntero a la categoria actual
schedv: .space 36
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
	.ascii "9-Instanciar Hola Mundo\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error: 	.asciiz "Error: "
return: .asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
instanciar:.asciiz "\nEscribi Hola mundo:"
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operación se realizo con exito\n\n"
greater_symbol: .asciiz ">"
invalid_option: .asciiz "\nOpción inválida. Inténtelo de nuevo.\n"
mensajeNoEncontrado: .asciiz "No encontrado. \n"

.text
main:
# Inicialización del vector de funciones en schedv
	la $t0, schedv # Cargo la direccion de schedv (donde se almacenan las funciones)
	la $t1, newcategory # Cargo la direccion de la funcion para crear categoria
	sw $t1, 0($t0)      # Opción 1: Nueva categoría. Almaceno su direccion en la primer posicion de schedv         

	la $t1, siguienteCategoria # Cargo y guardo la funcion de siguiente categoria y asi con todas las restantes..
	sw $t1, 4($t0)               # Opción 2: Siguiente categoría

	la $t1, categoriaAnterior
	sw $t1, 8($t0)              # Opción 3: Categoría anterior

	la $t1, listarCategorias
	sw $t1, 12($t0)             # Opción 4: Listar categorías

	la $t1, eliminarCategoria
	sw $t1, 16($t0)             # Opción 5: Borrar categoría

	la $t1, nuevoObjeto
	sw $t1, 20($t0)             # Opción 6: Añadir objeto

	la $t1, listarObjetos
	sw $t1, 24($t0)             # Opción 7: Listar objetos

	la $t1, eliminarObjeto
	sw $t1, 28($t0)             # Opción 8: Borrar objeto
	
	la $t1, instanciarHola
	sw $t1, 32($t0)             # Opción 9: instancia un hola mundo. 

menuBucle:
# Imprimir el menu con las opciones al usuario
    	la $a0, menu # Cargo direccion de la cadena del menu 
    	li $v0, 4 # La imprimo
    	syscall
    	
    	li $v0, 5 #Para que el usuario ingrese la opcion
    	syscall
    	move $t2, $v0 #Guardar opción en $t2

#Para que el rango de opciones sea entre 1 y 8
    	beqz $t2, exit # Si la opcion es 0 termina el programa
    	li $t3, 1
    	blt $t2, $t3, opcionInvalida # Si la opcion es menor a 1 salta a esa funcion
    	li $t3, 9
    	bgt $t2, $t3, opcionInvalida # Si la opcion es mayor a 8 salta a esa funcion 

#Calcular la posición en schedv (opción - 1) * 4
    	subi $t2, $t2, 1 # Resto 1 a la opcion seleccionada porque los indices del arreglo van de 0 a 7 y las opciones de 1 a 8
    	sll $t2, $t2, 2 # 2 elevado a la 2 = 4. Es como multiplicar la opcion del menu por 4 
    	la $t0, schedv # Guardo la direccion de schedv (Esta en 0)
    	add $t0, $t0, $t2  #$t0 ahora tiene la dirección de la función en schedv

    	lw $t1, 0($t0) #Llamo a la funcion a través de la dirección guardada en $t0
    	jalr $t1  #Saltar a la funcion correspondiente

    	j menuBucle #Vuelvo al menú

opcionInvalida: #Para imprimir mensaje de opción inválida
    	la $a0, invalid_option
    	li $v0, 4
    	syscall
    	j menuBucle  #Vuelvo al menú

newcategory:
	addiu $sp, $sp, -4 # Reserva word en stack
	sw $ra, 4($sp) # Guarda el valor de $ra (de retorno) de la funcion que invoca a newcategory
	la $a0, catName  # Carga la direccion de la cadena "Ingrese el nombre de una categoria"
	jal getblock
	move $a2, $v0 # Guardo en $a2 el valor de retorno de getblock (direccion del nombre de la categoria)
	la $a0, cclist # Carga en a0 la direccion de la lista de categorias
	li $a1, 0 # $a1 = NULL
	jal addnode # Para agregar un nodo a la lista de categorias
	lw $t0, wclist # Carga en t0 la direccion de la lista actual 
	bnez $t0, newcategory_end # Si t0 es distinto de 0, salta a esa funcion
	sw $v0, wclist # Si la lista actual es 0, la actualiza con el nuevo nodo (valor de retorno de addnode)
newcategory_end:
	li $v0, 0 # Indica que la operacion fue exitosa 
	lw $ra, 4($sp) # Recupera la direccion de retorno de la linea 96
	addiu $sp, $sp, 4 # Restaura stack
	jr $ra # Para retornar a la linea 3 (j menubucle)
	
siguienteCategoria:
    	addiu $sp, $sp, -4 # Reservo espacio en stack
    	sw $ra, 4($sp) # Guardo direccion de retorno de la funcion que llama a siguienteCategoria

    	lw $t0, cclist # Guardo en $t0 el puntero a lista de categorias (cclist)
    	beqz $t0, error_201 # Si es igual a 0, error 201

    	lw $t1, wclist # Guardo en $t1 la direccion de la categoria actual
    	lw $t2, 12($t1) # Cargo en $t2 el puntero de la siguiente categoria de la categoria actual
    	beq $t1, $t2, error_202 # Si la direccion de la categoria actual es igual a la direccion de la siguiente, es porque hay una sola

    	sw $t2, wclist # Almacena la dirección de la siguiente categoría ($t2) en wclist, actualizando la categoria
    	lw $a0, 8($t2) # Cargo el nombre de la siguiente categoria y lo imprimo
    	li $v0, 4
    	syscall
    	li $v0, 0 # Establezco a $v0 en indicando que la función terminó correctamente
    	j siguienteCategoriaFin # Salto a la funcion
    	
error_201:
    	la $a0, error # Cargo la direccion de la cadena de error
    	li $v0, 4 # La imprimo 
    	syscall
    	li $a0, 201 # Carga el codigo de error en a0
    	li $v0, 1 # Imprime el numero 
    	syscall
    	la $a0, return # Carga la cadena de return
    	li $v0, 4 # La imprime
    	syscall
    	li $v0, 201 # Establece $v0 a 201, que es el código de error
    	j siguienteCategoriaFin # Salta a la finalizacion de la funcion 
    	
error_202:
    	la $a0, error # Carga la direccion de la cadena de error 
    	li $v0, 4
    	syscall
    	li $a0, 202 # Carga el codigo de error en a0
    	li $v0, 1 # Imprime el numero 
    	syscall
    	la $a0, return # Carga la direcion de la cadena de return
    	li $v0, 4 # La imprime 
    	syscall
    	
siguienteCategoriaFin:
    	lw $ra, 4($sp) # Restaura el valor de retorno de la pila
    	addiu $sp, $sp, 4 # Restaura la pila
    	jr $ra # Regresa a la funcion que llamo a siguiente categoria
    
categoriaAnterior:
    	addiu $sp, $sp, -4 # Reserva espacio en stack
    	sw $ra, 4($sp) # Guarda direccion de retorno de la funcion que llama a categoria Anterior
    	
    	lw $t0, cclist # Guardo en $t0 el puntero a lista de categorias (cclist)
    	beqz $t0, error_201 # Si no hay categorías, es decir, igual a 0

    	lw $t1, wclist # Guardo en $t1 la categoria actual
    	lw $t2, 0($t1) # Cargo en $t2 el puntero de la categoria anterior de la categoria actual
    	beq $t1, $t2, error_202 # Si la anterior es igual a la actual, es  porque solo hay una
 
    	sw $t2, wclist # Almacena la dirección de categoria anterior ($t2) en wclist, actualizando la categoria

    	lw $a0, 8($t2) # Cargo el nombre de la categoria
    	li $v0, 4 # La imprimo
    	syscall              

    	lw $ra, 4($sp) # Restauro el valor de retorno de la pila
    	addiu $sp, $sp, 4 # Restauro la pila 
    	jr $ra            

listarCategorias:
    	lw $t0, cclist # Cargo en t0 el puntero a lista de categorias (comienza desde la primera)
    	beqz $t0, list_error_301 # Si es igual a 0, es decir, que no hay categorias, reporto error 
    	lw $t2, wclist # Cargo en t2 la direccion de la categoria actual 
    	move $t1, $t0 # Muevo la dirección del primer nodo de la lista (cclist) a $t1
       
listarBucle: # Bucle para recorrer la lista de categorías
    	bne $t1, $t2, listarBucle2 # Si el puntero a la lista de categorias no es igual a la categoria actual 
    	
imprimirSimbolo:
    	la $a0, greater_symbol # Si el puntero a la lista de categorias es igual a la categoria actual, le imprime un simbolo 
    	syscall
    	
listarBucle2: 
       lw $a0, 8($t1)          # Carga en $a0 el nombre de la categoría
       move $t3, $a0           # Muevo nombre de la categoria a t3

convertirBucle:
        lb $t4, 0($t3)      # Cargo el siguiente byte (carácter) de la cadena
        beqz $t4, convertirFin  # Si es el final de la cadena (por '\0'), salta a la funcion
        li $t5, 97           # Cargo el valor ASCII de 'a'
        li $t6, 122          # Cargo el valor ASCII de 'z'
        blt $t4, $t5, bucleContinua  # Si el carácter es menor que 'a' se omite la conversion 
        bgt $t4, $t6, bucleContinua  # Si el carácter es mayor que 'z' se omite la conversion

        subi $t4, $t4, 32     # Convierte el carácter a mayúscula restando 32 a su valor ASCII ('A' = 65 y 'Z' = 90)
        sb $t4, 0($t3)        # Guarda el carácter convertido en la misma posición de la cadena

bucleContinua:
        addiu $t3, $t3, 1     # Avanza al siguiente carácter de la cadena
        j convertirBucle      # Repite el proceso para el siguiente carácter

 convertirFin:
    # Ahora imprimimos el nombre de la categoría en mayúsculas
    li $v0, 4               # Prepara la llamada a impresión de cadena
    syscall                 # Imprime el nombre de la categoría (ya en mayúsculas)

    lw $t1, 12($t1)         # Carga en $t1 el puntero al siguiente nodo de la lista
    bne $t1, $t0, listarBucle  # Si el siguiente nodo no es el actual (cclist), salta al inicio del bucle

listarCategoriaFin:
    	jr $ra # Regresa a la función que llamó a listarCategorias

list_error_301:
	la $a0, error # Cargo el mensaje de error
    	li $v0, 4 # Lo imprimo
    	syscall
    	li $a0, 301 # Carga el codigo de error en a0
    	li $v0, 1 # Lo imprimo
    	syscall
    	la $a0, return # Carga la direcion de la cadena de return
    	li $v0, 4 # La imprime 
    	syscall
    	li $v0, 301 # Establece $v0 a 301, que es el código de error
    	j listarCategoriaFin # Salta a listarCategoriaFin
    
    
eliminarCategoria:
    	addiu $sp, $sp, -4 # Reserva espacio en stack
    	sw $ra, 4($sp) # Guarda direccion de retorno de la funcion que llama a eliminarCategoria
    	lw $t0, wclist # Cargo en t0 el puntero a la categoria actual
    	beqz $t0, error_401 # Si es igual a 0, es decir, que no hay categorias, salto al error 401
    	lw $t1, 4($t0)  # Cargo en t1 el valor del segundo campo del nodo, que es la cantidad de objetos
    	beqz $t1, eliminarCategoriaSinObjetos # Si t1 es = a 0, salto a la funcion eliminarCategoriaSinObjetos
    	move $a0, $t1 # Muevo el contenido de t1 a a0 para pasarlo como argumento a la siguiente funcion
    	jal eliminarTodosObjetos  #Funcion para eliminar todos los objetos de la categoria
	
eliminarCategoriaSinObjetos:
    	lw $a0, wclist # Carga el puntero de la categoria actual en a0
    	lw $a1, cclist # Carga el puntero al primer nodo de la lista de categorias en a1
    	lw $t5, 12($a0) # Carga en t5 el puntero al siguiente nodo de la lista 
    	beq $t5, $a0, eliminarUltimaCategoria # Si el siguiente nodo es igual al nodo actual, salta a eliminarUltimaCategoria
    	sw $t5, wclist # si no es la ultima categoria, se actualiza el puntero wclist para que apunte al siguiente nodo
    	bne $a0, $a1,  eliminarNodoCategoria # Si el nodo actual es distinto al primer nodo en la lista, salto a elimarNodoCategoria
    	sw $t5, cclist # Si el nodo actual es el primero en la lista, se actualiza cclist para que apunte al siguiente nodo, porque estamos eliminando el primero
    	j eliminarNodoCategoria # Salto a eliminarNodoCategoria
  
eliminarUltimaCategoria: # Si la categoria es la ultima
    	sw $zero, cclist # Establece cclist en 0
	sw $zero, wclist # Establece wclist en 0
    	
eliminarNodoCategoria: # Eliminacion del nodo actual
	jal delnode # Salta a la funcion delnode
    	lw $ra, 4($sp) # Recupera el valor de $ra desde la pila
    	addiu $sp, $sp, 4 # Restaura la pila
    	jr $ra # Para retornar a la funcion que invoco a eliminarNodoCategoria

error_401:
	la $a0, error # Cargo el mensaje de error
    	li $v0, 4 # Lo imprimo 
    	syscall
    	li $a0, 401 # Carga inmediata del numero 401
    	li $v0, 1 # Lo imprimo
    	syscall
    	la $a0, return # Cargo el mensaje de return
    	li $v0, 4 # Lo imprimo
    	syscall
    	li $v0, 401 # Establece $v0 a 401, que es el código de error
    	jr $ra # Vuelve a la funcion que invoco a error_401
    
nuevoObjeto:
    	addiu $sp, $sp, -4 # Reservo espacio en la pila 
    	sw $ra, 4($sp) # Guardo en la pila la direccion de retorno de la funcion que llama a nuevoObjeto
    	lw $t0, cclist # Cargo puntero de la lista de categorias
    	beqz $t0, error_501 # Si la lista de categorias es 0 salta al error 
    	la $a0, objName # Cargo la direccion de la cadena "Ingrese el nombre de un objeto"
    	jal getblock # Salto a getblock para asignar memoria e ingresar el nombre del objeto 
    	move $a2, $v0 # Lo que retorna getblock lo muevo al registro a2
    	lw $t0, wclist # Se carga la direccion de la lista de objetos de la categoria actual
    	addi $t0, $t0, 4 # Para que apunte al segundo campo del nodo del objeto (donde esta el ID)
    	move $a0, $t0 # Movemos la direccion a a0
    	lw $t5, ($a0) # Cargamos el valor de la direccion (del segundo campo) en t5
    	bnez  $t5, otroObjeto # Si el valor es distinto a 0, es decir, que no es el primer objeto de la lista, salta a la funcion
    	li   $a1, 1 # Si es el primer objeto, se carga el 1 en el registro a1
    	jal addnode # Salta a addnode pasando como parametros lo que esta en a0 y en a1
    	j   nuevoObjetoFin
    
otroObjeto:
    	lw $t4, ($t5) # Cargo en t4 el puntero al objeto actual (que apunta al primer campo del nodo)
    	lw $t5, 4($t4) # Cargo en t5 el valor del segundo campo del objeto (su ID)
    	addiu $a1, $t5, 1 # Lo incremento en 1 y lo guardo en a1
    	jal addnode # Salto a addnode y le paso como parametro lo que esta en a0 (direccion del nodo de objetos) y en a1 (el ID incrementado)

nuevoObjetoFin:
    	li $v0, 0 # Para indicar retorno exitoso
    	lw $ra, 4($sp) # Restauro la direccion de retorno de la funcion que llama a nuevoObjeto
    	addiu $sp, $sp, 4 # Restauro la pila
    	jr $ra # Para volver a la funcion que invoco a nuevoObjeto
	
error_501: # Si la lista de categorias es 0 
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
    
    
listarObjetos:
    	lw $t0, wclist # Cargo en t0 la lista de objetos de la categoria actual 
    	beqz $t0, error_601 # Si no hay objetos, salta al error 601
    	lw $t1, 4($t0) # Cargo en t1 el ID del objeto
   	beqz $t1, error_602 # Si el ID del objeto es 0, salta al error 602 
    	move $t2, $t1 # Mueve el ID de t1 a t2 
    	
listarObjetosBucle:
    	lw $a0, 8($t2) # Cargo en a0 el nombre del objeto
    	li $v0, 4 # Lo imprimo
    	syscall
    	lw $t2, 12($t2) # Cargo en t2 el puntero del siguiente objeto
    	bne $t2, $t1, listarObjetosBucle # Si t2 (siguiente objeto) no es igual al actual, llamada recursiva y repite bucle
    	li $v0, 0 # Una vez que no entra mas al bucle (el siguiente objeto es igual al actual), coloco un 0 en $v0 como retorno exitoso
    	jr $ra # Retorno a la funcion que llamo a listarObjetos

error_601: # Mensaje de error si no hay objetos en la lista 
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

eliminarTodosObjetos:
    	addiu $sp, $sp, -4  # Reservo espacio en la pila     
    	sw $ra, 4($sp)  # Guardo la direccion de retorno de la funcion que invoco a eliminarTodosObjetos      
    	lw $t0, wclist  #$t0 apunta a la categoría seleccionada, o actual
    	beqz $t1, error_602  #Si la categoria no tiene objetos (lo paso como argumento a traves de a0), imprime error 602

eliminarTodosObjetosBucle: # En c/iteracion elimina un objeto, actualiza los punteros de los objetos y luego pasa al siguiente
        # $t1 ahora apunta al primer objeto de la lista (en la primer iteracion)
    	lw $t2, 12($t1) # $t2 guarda el puntero al siguiente objeto (apunta al siguiente objeto)
    	lw $t3, 0($t1)  # $t3 guarda el puntero al objeto anterior (apunta al objeto anterior)
    	lw $t4, 8($t1) # $t4 apunta al nombre del objeto
    	sw $t3, 0($t2)	# Establece el puntero anterior del siguiente objeto para que apunte al objeto anterior
    	sw $t2, 12($t3) # Establece el puntero siguiente del objeto anterior para que apunte al siguiente objeto
    	li $t5, 0                   
    	sw $t5, 0($t1) # Pongo un cero en el puntero del nodo anterior del objeto que estamos eliminanado
    	sw $t5, 4($t1)  # Pongo un cero en el puntero del nodo siguiente del objeto que estamos eliminando
    	sw $t5, 8($t1) # Pongo un cero en el puntero al nombre del objeto que estamos eliminando
    	move $a0, $t1 # Lo muevo para pasarlo como argumento a la funcion sfree
    	jal sfree # Para iberar el bloque de memoria del objeto actual
    	beq $t2, $t1, eliminarObjetoFin  # Si el siguiente objeto es igual al primero, es decir que es el ultimo, salta a la funcion
    	move $t1, $t2 # Continuamos con el siguiente objeto. $t1 ahora apunta al siguiente objeto para continuar el bucle
    	j eliminarTodosObjetosBucle

eliminarObjetoFin:		
    	lw $t0, wclist # Carga el puntero de la categoria actual
    	sw $zero, 4($t0) # Si eliminamos todos los objetos, ponemos en 0 la lista de objetos de la categoría elegida
    	li $v0, 0 # Indicamos que la operación se completó con éxito
    	lw $ra, 4($sp) # Restaura el valor de retorno de la funcion que invoco a eliminarTodosObjetos
    	addiu $sp, $sp, 4 # Restaura la pila 
    	jr $ra # Para volver a la funcion que invoca a eliminarTodosObjetos

error_602:  #Mensaje de error para cuando no hay objetos 
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
    
eliminarObjeto:
    	addiu $sp, $sp, -4 # Reservo espacio en la pila 
    	sw $ra, 4($sp) # Guardo la direccion de retorno de la funcion que invoco a eliminarObjeto
    	lw $t0, wclist # Cargo en t0 la direccion de la lista de objetos de la categoria actual 
    	beqz $t0, error_701 # Si la lista de objetos esta vacia, saltamos al error 701 
    	la $a0, idObj # Cargamos la direccion de la cadena "Ingrese el ID del objeto a eliminar: "
    	li $v0, 4 # La imprimimos
    	syscall
    	li $v0, 5 # Ingresamos el ID 
    	syscall							
    	move $t1, $v0  # Movemos el ID ingresado a t1 
    	lw $t2, 4($t0) # Cargo en t2 el puntero al primer objeto de la lista de objetos de la categoria actual 
    	lw $t4, 0($t2) # Cargo en t4 el puntero al ultimo objeto de la lista de objetos de la categoria actual 
    	lw $t3, 4($t4) # Guardo en t3 el segundo campo (4($t4)) del ultimo objeto de la lista, es decir, su ID
    	li $t5, 0 # Inicializo un contador que se incrementa a medida que recorremos los objetos de la lista
    	move $a1, $t2 # Muevo la direccion del primer objeto a a1
       
eliminarObjetoBucle:
    	lw $t3, 4($t2) # Cargo en t3 el ID objeto actual
    	beq $t1, $t3, objetoEncontrado # Si el ID ingresado por pantalla es igual al del objeto actual, salta a la funcion
    	lw $t2, 12($t2) # Si no coincide el ID, cargamos la direccion del siguiente objeto 
    	bgt $t5, $t3, objetoNoEncontrado # Si el contador es mayor al ID del objeto, salta a la funcion
    	addiu $t5, $t5, 1 # Para ir incrementando contador
    	bne $t2, $zero, eliminarObjetoBucle # Si t2 es distinto de 0 se repite el bucle. Si es = a 0 es porque llegamos al final de la lista

objetoNoEncontrado:
	la $a0, mensajeNoEncontrado # Carga direccion de la cadena "No encontrado"
    	li $v0, 4 # La imprime 
    	syscall
    	lw $ra, 4($sp) # Restaura la direccion de retorno de la funcion que invoco a eliminarObjeto
    	addiu $sp, $sp, 4 # Restauro la pila 
    	jr $ra # Para volver a la funcion que invoco eliminarObjeto

objetoEncontrado:
    	lw $t4, 4($t0) # Cargo en t4 la dirección del primer objeto de la lista de objetos de la categoría actual
    	beq $t2, $t4, actualizarListaObjetos # Si t2 (direccion del objeto que estamos eliminando) es igual a $t4 (dirección del primer objeto), salta a la funcion
    	
objetoEncontrado2:   
    	move $a0, $t2 # Muevo la direccion del objeto eliminar a a0 para pasarlo como argumento a delnode 
    	jal delnode
    	lw $ra, 4($sp) # Restauro el valor de retorno de la funcion que invoco a eliminarObjeto
    	addiu $sp, $sp, 4 # Restauro la pila 
   	jr $ra 
    
actualizarListaObjetos:
    	lw  $t5, 12($t2) # Guardo en $t5 el siguiente objeto de la lista 
    	addiu $t4, $t0, 4  # Cargo la direccion donde la categoria tiene el puntero de la lista de objetos
    	seq $t6, $t5, $t2 # Si el siguiente objeto es el mismo que se va a eliminar es porque solo hay uno 
    	bnez $t6, actualizarListaObjetos2 # Si t6 es distinto de cero (es decir, el objeto a eliminar es el único en la lista), salta a la función
    	sw  $t5, 0($t4)	# se actualiza el puntero en la lista de objetos de la categoría, asignando la dirección del siguiente objeto ($t5)
    	j   objetoEncontrado2 # Luego de actualizar el puntero de la lista de objetos, salta a la funcion 
    
actualizarListaObjetos2:
    	sw  $zero, 0($t4) # Actualizo el puntero de lista objetos a NULL, ya que elimine el unico objeto 
    	j   objetoEncontrado2 # Salto a la funcion 
    
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
instanciarHola:
	addiu $sp, $sp, -4 # Reserva word en stack
	sw $ra, 4($sp) # Guarda el valor de $ra (de retorno) de la funcion que invoca a newcategory
	la $a0, instanciar  # Carga la direccion de la cadena "Ingrese el nombre de una categoria"
	jal getblock
	move $a2, $v0 # Guardo en $a2 el valor de retorno de getblock (direccion del nombre de la categoria)
	li $v0, 0 # Indica que la operacion fue exitosa 
	lw $ra, 4($sp) # Recupera la direccion de retorno de la linea 96
	addiu $sp, $sp, 4 # Restaura stack
	jr $ra # Para retornar a la linea 3 (j menubucle)
	    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added

addnode: # Funcion que agrega un nodo a una lista doblemente enlazada
	addi $sp, $sp, -8 # Reservo espacio en la pila para dos words 
	sw $ra, 8($sp) # Guardo valor de retorno de la funcion que invoca a addnode
	sw $a0, 4($sp) # Guardo la direccion de la lista de categorias (cclist), a la que se va a agregar el nodo, o la direccion del segundo campo del objeto (por la funcion nuevoObjeto)
	jal smalloc # Salto a smalloc para reservar memoria en el heap para el nuevo nodo, cuya direccion estara en v0
	sw $a1, 4($v0) # Guardo el contenido de a1 (que es 0 por la funcion newcategory o 1 por la funcion nuevoObjeto) en la segunda palabra de $vo (dirección de memoria donde se asignó el nodo)
	sw $a2, 8($v0) # Guardo el contenido de a2 (de la funcion newcategory, es decir, el nombre de la categoria) en la tercera palabra del nodo
	lw $a0, 4($sp) # Recupero de la la pila la direccion de la lista de la linea 454
	lw $t0, ($a0) # Carga en t0 la dirección del primer nodo de la lista
	beqz $t0, addnode_empty_list # Si t0 es igual a 0, es decir, que la lista esta vacia, salta a la funcion
addnode_to_end:
	lw $t1, ($t0) # Carga la dirección del último nodo en t1
	# Actualizar punteros prev y next del nuevo nodo
	sw $t1, 0($v0) # El puntero prev del nuevo nodo apunta al último nodo
	sw $t0, 12($v0) # El puntero next del nuevo nodo apunta al nodo anterior
	# Actualizar punteros del último nodo para apuntar al nuevo nodo
	sw $v0, 12($t1) # El puntero next del último nodo apunta al nuevo nodo
	sw $v0, 0($t0) # El puntero prev del nodo anterior apunta al nuevo nodo
	j addnode_exit
addnode_empty_list:
	sw $v0, ($a0) # Guarda la dirección del nuevo nodo en la posición inicial de la lista, es decir, como el primero
	sw $v0, 0($v0) # El puntero anterior del nuevo nodo apunta a si mismo
	sw $v0, 12($v0) # El puntero siguiente del nuevo nodo apunta a si mismo
addnode_exit:
	lw $ra, 8($sp) # Restaura la dirección de retorno desde la pila
	addi $sp, $sp, 8 # Restaura el puntero de la pila 
	jr $ra # Regresa a la función que llamó a addnode
	
# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8 # Reservo espacio en la pila 
	sw $ra, 8($sp) # Guarda en la pila la direccion de retorno de la funcion que llama a delnode
	sw $a0, 4($sp) # Guarda en la pila la direccion del nodo actual (que se esta eliminando)
	lw $a0, 8($a0) # get block address. Se obtiene la dirección del bloque de memoria que corresponde al nodo a eliminar
	jal sfree # Salta a la funcion free
	lw $a0, 4($sp) # Restauro la direccion del nodo 
	lw $t0, 12($a0) # Cargo en t0 la dirección del siguiente nodo (el nodo siguiente al que apunta el nodo actual). Esta en a0 porque asi se establecio en la funcion anterior
	
node: # Eliminación de un nodo intermedio
	beq $a0, $t0, delnode_point_self # Si a0 (nodo actual) es igual a t0 (el nodo siguiente), el nodo a eliminar es el único nodo en la lista
	lw $t1, 0($a0) # Guardo la direccion del nodo anterior y actualiza los punteros de los nodos
	sw $t1, 0($t0) # Se actualiza el puntero del nodo siguiente ($t0) para que apunte al nodo anterior
	sw $t0, 12($t1) # Se actualiza el puntero del nodo anterior ($t1) para que apunte al nodo siguiente
	lw $t1, 0($a1) # Carga la dirección del primer nodo en la lista
	
again: # Si el nodo es el primero de la lista
	bne $a0, $t1, delnode_exit # Si el nodo a eliminar no es el primero, salta a esa funcion 
	sw $t0, ($a1) # Si el nodo a eliminar es el primero, primero se actualiza el puntero y luego se elimina con la linea siguiente
	j delnode_exit
	
delnode_point_self: # Cuando hay un solo nodo 
	sw $zero, ($a1) # Se establece el puntero de la lista ($a1) a cero, indicando que la lista está vacía
	#sw $zero, cclist
	#sw $zero, wclist
	
delnode_exit:
	jal sfree # Se llama a sfree para liberar memoria 
	lw $ra, 8($sp) # Restauro la direccion de retorno desde la pila
	addi $sp, $sp, 8 # Restauro la pila
	jr $ra # Para volver a la funcion que la invoco

# a0: msg to ask
# v0: block address allocated with string

getblock: # Funcion encargada de asignar memoria a cada nodo
	addi $sp, $sp, -4 # Reserva espacio en stack 
	sw $ra, 4($sp) # Guarda en stack el ra (valor de retorno) de la funcion newcategory
	li $v0, 4 # Imprime la cadena de texto (guardada en newcategory en $a0 o en nuevoObjeto) "Ingrese el nombre de una categoria"
	syscall	
	jal smalloc #salta a smalloc para obtener un bloque de memoria 
	move $a0, $v0 # guarda en a0 la direccion de heap + 16 bytes. En v0 se encuentra el valor retornado por smalloc, es decir, la direccion de memoria asiganada
	li $a1, 16 # Establece que el bloque tiene tamaño de 16 bytes (4 words) 
	li $v0, 8 # Para ingresar por pantalla nombre de la categoria u objeto y almacenarlo en la dirección que se había reservado con smalloc
	syscall
	move $v0, $a0 # Vuelvo a mover la direccion de memoria asiganada a v0 para que sea el valor de retorno de getblock
	lw $ra, 4($sp) # Restauro valor de retorno de $ra para que cuando termine la funcion regrese a la que originalmente llamo a getblock
	addi $sp, $sp, 4 # Restauro puntero del stack 
	jr $ra # Regreso a la funcion que llamo a getblcok
	
# $v0 ES UTILIZADO PARA GUARDAR LOS VALORES DE RETORNO DE LAS FUNCIONES!!!!!!!!!!!!!!!
# $a0 ES UTULZIADO PARA PASAR ARGUMENTOS A LAS FUNCIONES!!!!!!!!!!!!!!!!!
	 
smalloc: #gestiona la memoria y asigna bloques de memoria dinamica 
	lw $t0, slist # Carga en t0 el contenido de slist
	beqz $t0, sbrk # Si es 0, es decir, no hay bloques disponibles em la lista, salta a srbk para solicitar memoria al sistema op
	move $v0, $t0 # Mueve la direccion del nodo a v0 
	lw $t0, 12($t0) # Carga en t0 la direccion del siguiente nodo de la lista 
	sw $t0, slist #actualiza a slist para que apunte al siguiente nodo 
	jr $ra # Regresa a la funcion que llamo a smalloc (getblock)
	
sbrk: # Solicita memoria del sistema operativo
	li $a0, 16 # Necesito 16 bytes para 4 words 
	li $v0, 9  # llamo al heap reservando 16 bytes / 4 words
	syscall 
	jr $ra # Regresa a la linea 517 (getblock)
	
sfree: # Libera el nodo y lo agrega a una lista de bloques libres
	lw $t0, slist # Se carga en t0 el puntero a la lista de bloques libres
	sw $t0, 12($a0) # Se guarda la dirección del bloque libre en la posición 12 del nodo actual
	sw $a0, slist # Actualizar el puntero slist para que apunte al nodo actual
	jr $ra # Para volver a la funcion que la invoco
	
exit:
	li $v0, 10
	syscall
