#!/bin/bash

# Se ejecuta en background . ./DetectO.sh &

# Cambiar llamadas al logger [LOG]
# Poner mensajes en [LOG]
# Nombre DetecO.log

# Cambiar variables de ambiten [REPLACE]

# Falta verificar periodo actual
# Falta verificar con los archivos maestros

######################################################### Funciones auxiliares #########################################################

# grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}$'
# grep -c -v '^$'
# ls | grep -c -i A-8-2018-04
# ls | grep -c duplicados
# date +%Y-%m-%d_%H:%M:%S

Invocar_interprete()
{
	# Invocar al interprete si no se encuentra en ejecucion
	# registro que sucedio con la invocacion [LOG]

	echo "debug: Invocando al interprete"	
}

Mover_archivos_rechazados()
{
	echo "debug: Moviendo todos los archivos no aceptados"

	# Recorro los nombres de los archivos en el directorio de arribos no aceptados
	for archivo_rechazado in $(cd $DIRECTORIO_ARRIBOS && ls)
	do
		# [DEBUG]: Borrar
	    # echo "Moviendo archivo: $archivo_rechazado"

	    # [LOG] archivo rechazado: $archivo_rechazado

	    Mover_archivo $DIRECTORIO_ARRIBOS $DIRECTORIO_RECHAZADOS $archivo_rechazado

	done 
}

# Mover_archivo() DIRECTORIO_ORIGEN DIRECTORIO_DESTINO NOMBRE_ARCHIVO
Mover_archivo()
{
	# [DEBUG]
	echo "debug: Moviendo archivo $3"

	esta_duplicado=$(ls $2 | grep -c -i "$3")

	# [DEBUG]
	# echo "Esta duplicado: $esta_duplicado"

	existe_carpeta_duplicados=$(ls $2 | grep -c duplicados)

	# [DEBUG]
	# echo "Existe carpeta duplicados: $existe_carpeta_duplicados"

	if [ $esta_duplicado == 1 ]
	then

		if [ $existe_carpeta_duplicados == 0 ]
		then
			# [LOG] se crea carpeta de duplicados
			mkdir $2/duplicados

			# [DEBUG]
			echo "Creo carpeta duplicados"
		fi

		fecha_duplicado=$(date +%Y-%m-%d_%H:%M:%S)

		# [DEBUG]
		# echo "Fecha archivo duplicado: $fecha_duplicado"

		mv $1/$3 $2/duplicados/$3_$fecha_duplicado
		# [LOG] archivo aceptado duplicado: $3_$fecha_duplicado

	else

		# [LOG] archivo aceptado: $1
		mv $1/$3 $2/$3
	fi
}

Verificar_archivo_recibido()
{
	# Verifico formato del nombre de archivo y su extension
	nombre_valido=$(echo $1 | grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}$')

	# Verifico contenido archivo que no este vacio
	# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
	esta_vacio=$(grep -c '^$' $DIRECTORIO_ARRIBOS/$1)

	if [ $nombre_valido != 1 ] || [ $esta_vacio == 1 ] || [ ! -f $DIRECTORIO_ARRIBOS/$1 ]
	then
		# [DEBUG]
		echo "Archivo invalido"
		return 0
	fi

	# [DEBUG]
	echo "Archivo valido"

	return 1
}

Verifico_inicializacion()
{
	if [ ! $exINIT_OK ]
	then
		# [LOG]: El sistema no esta correctamente inicializado
		echo "El sistema no esta correctamente inicializado."
		
		exit 1
	fi	
	
	# [LOG]: El sistema esta correctamente inicializado
	echo "El sistema esta correctamente inicializado."	
}

######################################################### Detector de novedades #########################################################

Verifico_inicializacion

# Seteo variables de ambiente
grupo=$HOME/Grupo4
DIRECTORIO_ARRIBOS=$grupo/$exDIR_EXT
DIRECTORIO_ACEPTADOS=$grupo/$exDIR_ACCEPT
DIRECTORIO_RECHAZADOS=$grupo/$exDIR_REFUSE

numero_ciclo=1

while true
do
	# registro el numero de ciclo [LOG]

	# Recorro los nombres de los archivos en el directorio de arribos
	for nombre_archivo in $(cd $DIRECTORIO_ARRIBOS && ls)
	do
		# [DEBUG]: Borrar
	    # echo $nombre_archivo

	    # Analizo el archivo
	    Verificar_archivo_recibido $nombre_archivo	

	    # Guardo el resultado del analisis del archivo
    	archivo_valido=$?

    	if [ $archivo_valido == 1 ]
		then
			# [DEBUG]: Borrar
    		# echo "Es valido: $archivo_valido"

			Mover_archivo $DIRECTORIO_ARRIBOS $DIRECTORIO_ACEPTADOS $nombre_archivo
    	fi

	done  

	# Muevo todos los archivos que no fueron aceptados
	Mover_archivos_rechazados
	
	Invocar_interprete

	numero_ciclo=$(($numero_ciclo + 1))

	sleep 60

done