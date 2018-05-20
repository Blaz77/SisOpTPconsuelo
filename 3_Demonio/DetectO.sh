#!/bin/bash

# Detector de novedades
# Se ejecuta en background . ./DetectO.sh &
# Cambiar llamadas al logger
# Cambiar $DIRECTORIO_ARRIBOS


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

# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
INIT_OK=true

#Verifico variable de inicializacion correcta
if [ $INIT_OK == false ]
then
	echo "El sistema no esta correctamente inicializado."
	# [LOG]: El sistema no esta correctamente inicializado
	exit 1

fi	

# [LOG]: El sistema esta correctamente inicializado
echo "El sistema esta correctamente inicializado."

# Cuento los ciclos
numero_ciclo=1

while true
do
	# registro el numero de ciclo [LOG]

	# [Leo variable de ambiente con carpeta de arribos]
	# [REPLACE]: !REEMPLAZAR POR VARIABLE DE INICIALIZADOR!
	DIRECTORIO_ARRIBOS=/home/jleyes/ARRIBOS

	# Recorro los nombres de los archivos en el directorio de arribos y filtro por extension .txt
	for linea in $(cd $DIRECTORIO_ARRIBOS && ls *.txt)
	do
		# [DEBUG]: Borrar
	    echo $linea

	    # Analizo el archivo
	    Verificar_archivo_recibido $linea	

	    # Guardo el resultado del analisis del archivo
    	archivo_valido=$?

    	# [DEBUG]: Borrar
    	echo "Es valido: $archivo_valido"

	done  
	
	# Invocar al interprete si no se encuentra en ejecucion
	# registro que sucedio con la invocacion [LOG]

	numero_ciclo=$(($numero_ciclo + 1))

	sleep 60

done

# Falta verificar periodo actual
# Falta verificar con los archivos maestros
# grep -c '^[Aa-Zz]\{1\}-[0-9]\{1\}-[0-9]\{4\}-[0-9]\{2\}\.txt$'
# grep -c -v '^$'