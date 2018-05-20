grupo=$HOME/Grupo4
source $HOME/SisOpTPconsuelo/4_Interprete/Logger.sh

#Estas variables deberian venir seteadas desde InicializO.sh
directorioAceptados=$HOME/Grupo4/acep
directorioArchivosMaestros=$HOME/Grupo4/mae
directorioProcesados=$HOME/Grupo4/proc
directorioLogs=$HOME/Grupo4/losg

archivoLogInterprete=$HOME/Grupo4/losg/InterpretO.log

Procesar()
{
	#Fijate que a directorioAceptados ponele el nombre que vos le pusiste al crearlo
	#Esa variable nos la tiene que dar InicializO.sh
	LogearMensaje ${FUNCNAME[0]} "INF" "Procesando archivos" $archivoLogInterprete
	if [ -e $directorioAceptados ]
		then
			EvaluarArchivos
	else
		echo "No hay archivos para ser procesados."
	fi
}

EvaluarArchivos()
{
	###Busco archivo T1
	archivoT1=$directorioArchivosMaestros/T1.tab

	#Busco todos los archivos a procesar
	 cd
	 cd $directorioAceptados
	archivosAProcesar=$(ls)

	# while ( cd $directorioAceptados && ls -1 )
	# do
	# 	files=( directorioAceptados/* )
	# 	echo "${files[0]}"
	# 	#archivoAMover= ( cd $directorioAceptados | ls | head -1 )
	#
	# 	#archivoAMover="$directorioAceptados/$archivo"
	# 	mv ${files[0]} $directorioProcesados
	#
	# done

	for archivo in $archivosAProcesar
	do
		ValidarSiYaFueProcesadoElArchivo $archivo
		if [ $ElArchivoEsValido = true ]
		then

			echo "FILE: $archivo"
	 	  pais=$(echo $archivo | cut -c 1)
	 	  echo "Pais: $pais"
	 	  sistema=$(echo $archivo | cut -c 3)
	 	  echo "Sistema: $sistema"

	 	 regex=$(grep $pais-$sistema $archivoT1)
	 	 echo "regex $regex"
	 	 delimitador_campos=$(echo $regex | cut -c 5)
	 	 echo "Delimitador campos: $delimitador_campos"
	 	 delimitador_decimal=$(echo $regex | cut -c 7)
	 	 echo "Delimitador decimal: $delimitador_decimal"
	 else
		 echo "El archivo $archivo ya habia sido procesado."
	 fi
	done
}

ValidarSiYaFueProcesadoElArchivo()
{
	fecha=$(date +"%Y%m%d")

	if [ ! -e $directorioProcesados/$fecha/$1 ]
		then
			ElArchivoEsValido=true
		else
			ElArchivoEsValido=false
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
