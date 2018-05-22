#!/bin/bash

# Se ejecuta en background . ./DetectO.sh &
# Nombre log DetecO.log

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

	# [DEBUG]
	echo "Validador invocado: process id $pid_Interprete"

	Log_Info "Iniciar_interprete" "Validador invocado: process id $pid_Interprete"
}

# Invoca al interprete si hay archivos en la carpeta aceptados y si no se encuentra en ejecucion
Validar_estado_interprete()
{
	# [DEBUG]
	echo "Analizando estado del interprete"	

	cantidad_archivos_aceptados=$(ls $DIRECTORIO_ACEPTADOS | wc -l)

	if [ $cantidad_archivos_aceptados != 0 ]
	then

		# [DEBUG]
		echo "Hay archivos para ejecutar el interprete"

		Log_Info "Validar_estado_interprete" "Hay archivos para ejecutar el interprete"

		if [ $interprete_iniciado == false ]
		then

			Iniciar_interprete		

			interprete_iniciado=true

		else

			interprete_sigue_corriendo=$(ps -p $pid_Interprete | wc -l)	

			# interprete_sigue_corriendo == 1, no se encuentra en ejecucion
			if [ $interprete_sigue_corriendo == 1 ]
			then

				Iniciar_interprete

			else

				# [DEBUG]
				echo "Invocacion del validador pospuesta para el siguiente ciclo"

				Log_Info "Validar_estado_interprete" "Invocacion del validador pospuesta para el siguiente ciclo"
			fi
		fi

		return 
	fi

	# [DEBUG]
	echo "No hay archivos para ejecutar el interprete"		

	Log_Info "Validar_estado_interprete" "No hay archivos para ejecutar el interprete"
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

			# [DEBUG]
			echo "Se crea carpeta de duplicados"

			Log_Info "Mover_archivo" "Se crea carpeta de duplicados"

			mkdir $2/duplicados
		fi

		fecha_duplicado=$(date +%Y-%m-%d_%H:%M:%S)

		# [DEBUG]
		# echo "Fecha archivo duplicado: $fecha_duplicado"

		mv $1/$3 $2/duplicados/$3_$fecha_duplicado

		# [DEBUG]
		echo "Muevo novedad duplicada: $3"

		Log_Info "Mover_archivo" "Muevo archivo duplicado: $3"

	else
		# [DEBUG] 
		echo "Muevo novedad aceptada: $3"

		Log_Info "Mover_archivo" "Muevo novedad aceptada: $3"

		mv $1/$3 $2/$3
	fi
}

Verificar_archivo_recibido()
{
	# Verifico formato del nombre de archivo
	nombre_valido=$(echo $1 | grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}$')

	if [ $nombre_valido != 1 ]
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: formato de nombre invalido."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: formato de nombre invalido."

		return 0
	fi

	# Verifico contenido archivo que no este vacio
	esta_vacio=$(grep -c '^$' $DIRECTORIO_ARRIBOS/$1)

	if [ $esta_vacio == 1 ] 
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: el archivo esta vacio."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: el archivo esta vacio."

		return 0
	fi

	# Verifico que sea un archivo regular
	if [ ! -f $DIRECTORIO_ARRIBOS/$1 ]
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: no es un archivo regular."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: no es un archivo regular."

		return 0
	fi

	# Verifico contra archivo maestro pais-sistema
	codigo_pais=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.\{4\}\)-\(.\{2\}\)/\1/')
	
	# [DEBUG]
	# echo "codigo pais: $codigo_pais"

	codigo_sistema=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.\{4\}\)-\(.\{2\}\)/\2/')

	# [DEBUG]
	# echo "codigo sistema: $codigo_sistema"

	pais_sistema_valido=$(grep -i -c "^$codigo_pais-.*-$codigo_sistema-" $PATH_MAESTRO_PAIS_CODIGO)

	# [DEBUG]
	echo "Pais-Sistema valido: $pais_sistema_valido" 

	if [ $pais_sistema_valido == 0 ]
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: codigo de pais y sistema inexistente."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: codigo de pais y sistema inexistente."

		return 0
	fi

	# Verifico que no sea superior al periodo actual
	anio=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.\{4\}\)-\(.\{2\}\)/\3/')
	
	# [DEBUG]
	# echo "Anio: $anio"

	mes=$(echo $1 | sed 's/\(.\{1\}\)-\(.\{1\}\)-\(.\{4\}\)-\(.\{2\}\)/\4/')

	# [DEBUG]
	# echo "Mes: $mes"

	anio_actual=$(date +%Y)

	mes_actual=$(date +%m)

	if [ $anio -gt $anio_actual ]
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: año adelantado."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: año adelantado."
		
		return 0
	fi 

	if [ $anio -eq $anio_actual ] && [ $mes -gt $mes_actual ]
	then
		# [DEBUG]
		echo "Novedad rechazada: $1, motivo del descarte: periodo adelantado."

		Log_Info "Verificar_archivo_recibido" "Novedad rechazada: $1, motivo del descarte: periodo adelantado."

		return 0
	fi

	# [DEBUG]
	echo "Novedad aceptada: $1"

	Log_Info "Verificar_archivo_recibido" "Novedad aceptada: $1"

	return 1
}

Verifico_inicializacion()
{
	if [ $exINIT_OK != 1 ]
	then
		echo "El sistema no esta correctamente inicializado, fin de la ejecucion."

		Log_Error "Verifico_inicializacion" "El sistema no esta correctamente inicializado, fin de la ejecucion."
		
		exit 1
	fi	
	
	echo "El sistema esta correctamente inicializado."	

	Log_Info "Verifico_inicializacion" "El sistema esta correctamente inicializado."
}

# Log_Error() $funcionOrigen $MensajeInfo
Log_Error()
{
	LogearMensaje "$1" "ERR" "$2" "$PATH_LOG"
}

# Log_Info() $funcionOrigen $MensajeInfo
Log_Info()
{
	LogearMensaje "$1" "INF" "$2" "$PATH_LOG"
}

######################################################### Detector de novedades #########################################################

Verifico_inicializacion

# Seteo variables de ambiente
grupo=$HOME/Grupo4
DIRECTORIO_ARRIBOS=$grupo/$exDIR_EXT
DIRECTORIO_ACEPTADOS=$grupo/$exDIR_ACCEPT
DIRECTORIO_RECHAZADOS=$grupo/$exDIR_REFUSE

PATH_MAESTRO_PAIS_CODIGO=$grupo/$exDIR_MASTER/p-s.mae
PATH_INTERPRETE=$grupo/$exDIR_EXEC/InterpretO.sh
PATH_LOG=$grupo/$exDIR_LOGS/DetecO.log

numero_ciclo=1

interprete_iniciado=false

while true
do
	echo "Ciclo: $numero_ciclo"
	echo "Analizo directorio de archivos recibidos"

	Log_Info "mainDetectO" "Ciclo numero $numero_ciclo"

	for nombre_archivo in $(ls $DIRECTORIO_ARRIBOS)
	do
	    Verificar_archivo_recibido $nombre_archivo	

	    # Guardo el resultado del analisis del archivo
    	archivo_valido=$?

    	if [ $archivo_valido == 1 ]
		then
			Mover_archivo $DIRECTORIO_ARRIBOS $DIRECTORIO_ACEPTADOS $nombre_archivo
		else
			Mover_archivo $DIRECTORIO_ARRIBOS $DIRECTORIO_RECHAZADOS $nombre_archivo
    	fi

	done  

	Validar_estado_interprete

	numero_ciclo=$(($numero_ciclo + 1))

	sleep 60

done
