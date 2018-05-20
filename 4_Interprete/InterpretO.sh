#!/bin/bash

grupo=$HOME/Grupo4
source $HOME/SisOpTPconsuelo/Logger.sh

#Estas variables deberian venir seteadas desde InicializO.sh
directorioAceptados=$HOME/Grupo4/acep
directorioArchivosMaestros=$HOME/Grupo4/mae
directorioProcesados=$HOME/Grupo4/proc

directorioLogs=$HOME/Grupo4/losg
archivoLogInterprete=$HOME/Grupo4/losg/InterpretO.log

archivoT1=$directorioArchivosMaestros/T1.tab
archivoT2=$directorioArchivosMaestros/T2.tab
archivops=$directorioArchivosMaestros/p-s.mae


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
			Procesar_Archivo
	 	else
			echo "El archivo $archivo ya había sido procesado."
	 	fi
	done
}

Procesar_Archivo()
{
	pais=$(echo $archivo | cut -c1)
	sistema=$(echo $archivo | cut -c3)

	SIS_ID=$sistema
	FECHA=$(date +"%d/%m/%Y")

	###Busco el nombre del pais en el archivo p-s.mae
	paisSistema=$(grep "^$pais-..*-$sistema" $archivops)
	nombrePais=$(echo $paisSistema | cut -d '-' -f2)

	###Busco los separadores de campos y decimal en el archivo T1
	regex=$(grep "$pais-$sistema" $archivoT1)
	delimitador_campos=$(echo $regex | cut -c5)
	delimitador_decimal=$(echo $regex | cut -c7)

	cantidadCampos=$(grep -c "$pais-$sistema" $archivoT2)
	###No se por que el while no lee la ultima linea del archivo
	while read -r linea
	do
		let contador=1
		while [ $contador -le $cantidadCampos ]
		do
			GuardarCampos
			let contador=contador+1
		done

		InterpretarFecha

		MT_REST=$MT_PRES+$MT_IMPAGO+$MT_INDE+$MT_INNODE–$MT_DEB ###esto no esta funcionando, lo que hace no es sumar, si no concatenar

		###Grabar nuevo archivo: va a tener 16 campos
		echo "$SIS_ID;$CTB_ANIO;$CTB_MES;$CTB_DIA;$CTB_ESTADO;$PRES_ID;$MT_PRES;$MT_IMPAGO;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$PRES_CLI_ID;$PRES_CLI;$FECHA;$USER" >> $directorioProcesados/PRESTAMOS.$nombrePais
	done < $archivo
}

GuardarCampos()
{
	campo=$(echo $linea | cut -d $delimitador_campos -f $contador)
	lineaT2=$(grep "$pais-$sistema-.*-$contador-" $archivoT2)
	nombreCampo=$(echo $lineaT2 | cut -d '-' -f3)
	posicionCampo=$(echo $lineaT2 | cut -d '-' -f4)
	tipoCampo=$(echo $lineaT2 | cut -d '-' -f5)
	case $nombreCampo in
		CTB_FE)
			CTB_FE=$campo
			CTB_FE_tipo=$tipoCampo ;;
		CTB_ESTADO)
			CTB_ESTADO=$campo
			CTB_ESTADO_tipo=$tipoCampo ;;
		PRES_ID)
			PRES_ID=$campo
			PRES_ID_tipo=$tipoCampo ;;
		MT_PRES)
			MT_PRES=$campo
			MT_PRES_tipo=$tipoCampo ;;
		MT_IMPAGO)
			MT_IMPAGO=$campo
			MT_IMPAGO_tipo=$tipoCampo ;;
		MT_INDE)
			MT_INDE=$campo
			MT_INDE_tipo=$tipoCampo ;;
		MT_INNODE)
			MT_INNODE=$campo
			MT_INNODE_tipo=$tipoCampo ;;
		MT_DEB)
			MT_DEB=$campo
			MT_DEB_tipo=$tipoCampo ;;
		PRES_CLI_ID)
			PRES_CLI_ID=$campo
			PRES_CLI_ID_tipo=$tipoCampo ;;
		PRES_CLI)
			PRES_CLI=$campo
			PRES_CLI_tipo=$tipoCampo ;;
	esac
}

InterpretarFecha()
{
	longitudFecha=$(echo $CTB_FE_tipo | cut -c7,8)
	if [ $longitudFecha = "10" ]
	then
		tieneSeparador=true
	else
		tieneSeparador=false
	fi

	primerosCaracteres=$(echo $CTB_FE_tipo | cut -c1,2)

	if [ $tieneSeparador = true ]
	then
		if [ $primerosCaracteres = "dd" ]
		then
			CTB_DIA=$(echo $CTB_FE | cut -c1,2)
			CTB_MES=$(echo $CTB_FE | cut -c4,5)
			CTB_ANIO=$(echo $CTB_FE | cut -c7-10)
		elif [ $primerosCaracteres = "yy" ]
		then
			CTB_ANIO=$(echo $CTB_FE | cut -c1-4)
			CTB_MES=$(echo $CTB_FE | cut -c6,7)
			CTB_DIA=$(echo $CTB_FE | cut -c9,10)
		fi
	else
		if [ $primerosCaracteres = "dd" ]
		then
			CTB_DIA=$(echo $CTB_FE | cut -c1,2)
			CTB_MES=$(echo $CTB_FE | cut -c3,4)
			CTB_ANIO=$(echo $CTB_FE | cut -c5-8)
		elif [ $primerosCaracteres = "yy" ]
		then
			CTB_ANIO=$(echo $CTB_FE | cut -c1-4)
			CTB_MES=$(echo $CTB_FE | cut -c5,6)
			CTB_DIA=$(echo $CTB_FE | cut -c7,8)
		fi
	fi
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
