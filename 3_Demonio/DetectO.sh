# Se ejecuta en background . ./DetectO.sh &
# Cambiar llamadas al logger
# Cambiar $INIT_OK
# Cambiar $DIRECTORIO_ARRIBOS
# Cambiar $DIRECTORIO_ACEPTADOS
# Cambiar $DIRECTORIO_RECHAZADOS

######################################################### Funciones auxiliares #########################################################

Invocar_interprete()
{
	# Invocar al interprete si no se encuentra en ejecucion
	# registro que sucedio con la invocacion [LOG]

	echo "debug:"	
}

Mover_archivos_rechazados()
{
	echo "debug: Moviendo todos los archivos no aceptados"

	# Recorro los nombres de los archivos en el directorio de arribos no aceptados
	for archivo_rechazado in $(cd $DIRECTORIO_ARRIBOS && ls)
	do
		# [DEBUG]: Borrar
	    echo "Moviendo archivo: $archivo_rechazado"

	    mv $DIRECTORIO_ARRIBOS/$archivo_rechazado $DIRECTORIO_RECHAZADOS/$archivo_rechazado

	done 
}

Mover_a_carpeta_aceptados()
{
	# [DEBUG]
	echo "debug: Moviendo archivo aceptado: $1"

	# [LOG] archivo aceptado: $1

	mv $DIRECTORIO_ARRIBOS/$1 $DIRECTORIO_ACEPTADOS/$1
}

Verificar_archivo_recibido()
{
	# Verifico formato del nombre de archivo y su extension
	nombre_valido=$(echo $1 | grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}\.txt$')

	# Verifico contenido archivo que no este vacio
	# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
	esta_vacio=$(grep -c '^$' $DIRECTORIO_ARRIBOS/$1)

	if [ $nombre_valido != 1 ] || [ $esta_vacio == 1 ] 
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
# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
DIRECTORIO_ARRIBOS=/home/jleyes/ARRIBOS
DIRECTORIO_ACEPTADOS=/home/jleyes/Aceptados
DIRECTORIO_RECHAZADOS=/home/jleyes/Rechazados

# Cuento los ciclos
numero_ciclo=1

while true
do
	# registro el numero de ciclo [LOG]

	# Recorro los nombres de los archivos en el directorio de arribos y filtro por extension .txt
	for nombre_archivo in $(cd $DIRECTORIO_ARRIBOS && ls *.txt)
	do
		# [DEBUG]: Borrar
	    echo $nombre_archivo

	    # Analizo el archivo
	    Verificar_archivo_recibido $nombre_archivo	

	    # Guardo el resultado del analisis del archivo
    	archivo_valido=$?

    	if [ $archivo_valido == 1 ]
		then
			# [DEBUG]: Borrar
    		echo "Es valido: $archivo_valido"

			Mover_a_carpeta_aceptados $nombre_archivo
    	fi

	done  

	# Muevo todos los archivos que no fueron aceptados
	Mover_archivos_rechazados
	
	Invocar_interprete

	numero_ciclo=$(($numero_ciclo + 1))

	sleep 60

done

# Falta verificar periodo actual
# Falta verificar con los archivos maestros
# grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}\.txt$'
# grep -c -v '^$'