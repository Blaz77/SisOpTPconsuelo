grupo=$HOME/Grupo4
fnoc=$grupo/dirconf/fnoc.conf
directorioAceptados=$HOME/Grupo4/acep

	###Busco directorio de maestros en el archivo de configuracion
	# lineaMaestros=$(grep '^Maestros-' $fnoc)
	# directorioMaestros=$(echo $lineaMaestros | cut -d '-' -f 2)
	# archivoT1=$grupo/$directorioMaestros/T1.tab



	###Busco todos los archivos a procesar
	# cd $grupo/acep
	# archivosAProcesar=$(ls)


	###Por cada archivo a procesar, busco sus delimitadores
	# for archivo in $archivosAProcesar
	# do
	#  echo "FILE: $archivo"
	#  pais=$(echo $archivo | cut -c 1)
	#  echo "Pais: $pais"
	#  sistema=$(echo $archivo | cut -c 3)
	#  echo "Sistema: $sistema"
	#
	#  regex=$(grep $pais-$sistema $archivoT1)
	# echo "regex $regex"
	#  delimitador_campos=$(echo $regex | cut -c 5)
	#  echo "Delimitador campos: $delimitador_campos"
	#  delimitador_decimal=$(echo $regex | cut -c 7)
	#  echo "Delimitador decimal: $delimitador_decimal"
	# done

Procesar()
{
	#Fijate que a directorioAceptados ponele el nombre que vos le pusiste al crearlo
	#Esa variable nos la tiene que dar InicializO.sh
	if [ -e $grupo/$directorioAceptados ]
		then
			echo "Si existen archivos a procesar"
			#Procesar cada archivo
	else
		echo "No hay archivos para ser procesados."
	fi
}

VerificarEstadoInicializacion()
{
	#Asigno true para hacer pruebas
	#Aunque tal vez sea una variable dada por Instalo.sh
	FueBienInicializado=true;
}

#Simulo que la variable esta inicializada para hacer pruebas
#Esta variable es recibida desde InicializO.sh
INIT_OK="1"
if [ $INIT_OK ]
then
	VerificarEstadoInicializacion
	if [ $FueBienInicializado = true ]
		then
			Procesar
		else
			echo "El sistema fue inicializado con errores. Vuelva a inicializar"
	fi
else
	echo "El sistema no fue inicializado."
fi
