#!/bin/bash

# Se ejecuta en background . ./DetectO.sh &

# Cambiar llamadas al logger [LOG]
# Poner mensajes en [LOG]
# Nombre DetecO.log

# Cambiar variables de ambiente [REPLACE]

# Falta verificar periodo actual

######################################################### Funciones auxiliares #########################################################

# grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}$'
# grep -c -v '^$'
# ls | grep -c -i A-8-2018-04
# ls | grep -c duplicados
# ls | wc -l
# ps -p 1 | wc -l
# date +%Y-%m-%d_%H:%M:%S

Iniciar_interprete()
{
	$PATH_INTERPRETE &

	# $! guarda el PID del proceso en background
	pid_Interprete=$!	
}

# Invoca al interprete si hay archivos en la carpeta aceptados y si no se encuentra en ejecucion
Validar_estado_interprete()
{
	# [DEBUG]
	echo "debug: analizando estado del interprete"	

	cantidad_archivos_aceptados=$(ls $DIRECTORIO_ACEPTADOS | wc -l)

	if [ $cantidad_archivos_aceptados != 0 ]
	then

		# [LOG]
		# [DEBUG]
		echo "Hay archivos para ejecutar el interprete"

		if [ $interprete_iniciado == false ]
		then
			Iniciar_interprete		

			interprete_iniciado=true

			# [DEBUG]
			echo "PID: $pid_Interprete"
		else
			interprete_sigue_corriendo=$(ps -p $pid_Interprete | wc -l)	

			# interprete_sigue_corriendo == 1, no se encuentra en ejecucion
			if [ $interprete_sigue_corriendo == 1 ]
			then
				Iniciar_interprete

				# [LOG]
				echo "PID: $pid_Interprete"
			else
				# [LOG]
				echo "El interprete se esta ejecutando, queda para el siguiente ciclo"
			fi
		fi

		return 
	fi

	# [LOG]
	# [DEBUG]
	echo "No hay archivos para ejecutar el interprete"		
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
	# Verifico formato del nombre de archivo
	nombre_valido=$(echo $1 | grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}$')

	# Verifico contenido archivo que no este vacio
	esta_vacio=$(grep -c '^$' $DIRECTORIO_ARRIBOS/$1)

	codigo_pais=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.*\)/\1/')
	
	# [DEBUG]
	# echo "codigo pais: $codigo_pais"

	codigo_sistema=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.*\)/\2/')

	# [DEBUG]
	# echo "codigo sistema: $codigo_sistema"

	# Verifico contra archivo maestro pais-sistema
	pais_sistema_valido=$(grep -i -c "^$codigo_pais-.*-$codigo_sistema-" $PATH_MAESTRO_PAIS_CODIGO)

	# [DEBUG]
	# echo "Pais-Sistema valido: $pais_sistema_valido" 

	# Verificar que el archivo sea regular
	if [ $nombre_valido != 1 ] || [ $esta_vacio == 1 ] || [ ! -f $DIRECTORIO_ARRIBOS/$1 ] || [ pais_sistema_valido == 0 ]
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
	if [ $INIT_OK == false ]
	then
		# [LOG]: El sistema no esta correctamente inicializado
		echo "El sistema no esta correctamente inicializado."
		
		exit 1
	fi	
	
	# [LOG]: El sistema esta correctamente inicializado
	echo "El sistema esta correctamente inicializado."	
}

######################################################### Detector de novedades #########################################################

# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
INIT_OK=true

Verifico_inicializacion

# Seteo variables de ambiente
grupo=$HOME/Grupo4
DIRECTORIO_ARRIBOS=$grupo/$exDIR_EXT
DIRECTORIO_ACEPTADOS=$grupo/$exDIR_ACCEPT
DIRECTORIO_RECHAZADOS=$grupo/$exDIR_REFUSE

PATH_MAESTRO_PAIS_CODIGO=$grupo/$exDIR_MASTER/p-s.mae
PATH_INTERPRETE=$grupo/$exDIR_EXEC/InterpretO.sh

numero_ciclo=1

interprete_iniciado=false

while true
do
	# registro el numero de ciclo [LOG]
	echo "Analizo directorio de archivos recibidos"

	# Recorro los nombres de los archivos en el directorio de arribos
	for nombre_archivo in $(cd $DIRECTORIO_ARRIBOS && ls)
	do
	    Verificar_archivo_recibido $nombre_archivo	

	    # Guardo el resultado del analisis del archivo
    	archivo_valido=$?

    	if [ $archivo_valido == 1 ]
		then
			Mover_archivo $DIRECTORIO_ARRIBOS $DIRECTORIO_ACEPTADOS $nombre_archivo
    	fi

	done  

	# Muevo todos los archivos que no fueron aceptados
	Mover_archivos_rechazados
	
	Validar_estado_interprete

	numero_ciclo=$(($numero_ciclo + 1))

	sleep 60

done