#!/bin/bash

grupo=$HOME/Grupo4
source ./Logger.sh

#Estas variables deberian venir seteadas desde InicializO.sh
directorioAceptados=$grupo/$exDIR_ACCEPT
directorioArchivosMaestros=$grupo/$exDIR_MASTER
directorioProcesados=$grupo/$exDIR_PROCESS
directorioRechazados=$grupo/$exDIR_REFUSE

directorioLogs=$grupo/$exDIR_LOGS
archivoLogInterprete=$directorioLogs/InterpretO.log

archivoT1=$directorioArchivosMaestros/T1.tab
archivoT2=$directorioArchivosMaestros/T2.tab
archivops=$directorioArchivosMaestros/p-s.mae


Procesar()
{
	#Fijate que a directorioAceptados ponele el nombre que vos le pusiste al crearlo
	#Esa variable nos la tiene que dar InicializO.sh
	LogearMensaje ${FUNCNAME[0]} "INF" "Procesando archivos" $archivoLogInterprete
	cantidad_archivos_aceptados=$(ls $directorioAceptados | wc -l)

	if [ $cantidad_archivos_aceptados != 0 ]
		then
			EvaluarArchivos
	else
		echo "No hay archivos para ser procesados."
	fi
}

EvaluarArchivos()
{
	#Busco todos los archivos a procesar
	for archivo in $(cd $directorioAceptados && ls)
	do
		ValidarSiYaFueProcesadoElArchivo $archivo
		if [ $ElArchivoEsValido = true ]
		then
			Procesar_Archivo
			Mover_Archivo
			LogearMensaje ${FUNCNAME[0]} "INF" "Archivo procesado: $archivo $logParaRegistroDeArchivo." $archivoLogInterprete
	 	else
			Mover_Archivo_A_Rechazados $archivo
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
	logParaRegistroDeArchivo=""
	let contadorDeRegistro=0
	endRead=0
	while [[ $endRead == 0 ]]
	do
		read -r linea
		endRead=$?
		let contadorDeRegistro=contadorDeRegistro+1
		ResetearCampos
		let contador=1
		while [ $contador -le $cantidadCampos ]
		do
			GuardarCampos
			let contador=contador+1
		done

		InterpretarFecha
		InterpretarMontos
		GrabarArchivo
	done < $directorioAceptados/$archivo
}

ResetearCampos()
{
	CTB_FE=""
	CTB_ESTADO=""
	PRES_ID=""
	MT_PRES=""
	MT_IMPAGO=""
	MT_INDE=""
	MT_INNODE=""
	MT_DEB=""
	MT_REST=""
	PRES_CLI_ID=""
	PRES_CLI=""
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

InterpretarMontos()
{
	###Reemplazo las comas por puntos para poder hacer operaciones
	MT_PRES=$(echo $MT_PRES | sed s/","/"."/)
	MT_IMPAGO=$(echo $MT_IMPAGO | sed s/","/"."/)
	MT_INDE=$(echo $MT_INDE | sed s/","/"."/)
	MT_INNODE=$(echo $MT_INNODE | sed s/","/"."/)
	MT_DEB=$(echo $MT_DEB | sed s/","/"."/)

	###Los montos vacíos los reemplazo por 0
	MT_PRES=$(echo $MT_PRES | sed s/"^$"/"0"/)
	MT_IMPAGO=$(echo $MT_IMPAGO | sed s/"^$"/"0"/)
	MT_INDE=$(echo $MT_INDE | sed s/"^$"/"0"/)
	MT_INNODE=$(echo $MT_INNODE | sed s/"^$"/"0"/)
	MT_DEB=$(echo $MT_DEB | sed s/"^$"/"0"/)

	MT_REST=$(echo "$MT_PRES+$MT_IMPAGO+$MT_INDE+$MT_INNODE-$MT_DEB" | bc -l)

	#echo "mt pres: $MT_PRES"
	#echo "mt impago: $MT_IMPAGO"
	#echo "mt inde: $MT_INDE"
	#echo "mt innode: $MT_INNODE"
	#echo "mt deb: $MT_DEB"
	#echo "mt rest: $MT_REST"
	#echo ""
}

GrabarArchivo()
{
	###Reemplazo los puntos por comas para tener el formato de números pedido
	MT_PRES=$(echo $MT_PRES | sed s/"\."/","/)
	MT_IMPAGO=$(echo $MT_IMPAGO | sed s/"\."/","/)
	MT_INDE=$(echo $MT_INDE | sed s/"\."/","/)
	MT_INNODE=$(echo $MT_INNODE | sed s/"\."/","/)
	MT_DEB=$(echo $MT_DEB | sed s/"\."/","/)
	MT_REST=$(echo $MT_REST | sed s/"\."/","/)

	###Grabar nuevo archivo: va a tener 16 campos
	echo "$SIS_ID;$CTB_ANIO;$CTB_MES;$CTB_DIA;$CTB_ESTADO;$PRES_ID;$MT_PRES;$MT_IMPAGO;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$PRES_CLI_ID;$PRES_CLI;$FECHA;$USER" >> $directorioProcesados/PRESTAMOS.$nombrePais
	logParaRegistroDeArchivo="$logParaRegistroDeArchivo Registro $contadorDeRegistro aceptado "
}

Mover_Archivo()
{
	###Creo directorio del día si es que no existe y muevo el archivo procesado
	fecha=$(date +"%Y%m%d")
	if [ ! -e $directorioProcesados/$fecha ]
	then
		mkdir $directorioProcesados/$fecha
	fi
	directorioDelDia="$directorioProcesados/$fecha"
	mv $directorioAceptados/$archivo $directorioDelDia
}

#Parametros: Archivo
Mover_Archivo_A_Rechazados()
{
	esta_duplicado=$(ls $directorioRechazados | grep -c -i "$1")
	existe_carpeta_duplicados=$(ls $directorioRechazados | grep -c duplicados)

	if [ $esta_duplicado == 1 ]
		then
			if [ $existe_carpeta_duplicados == 0 ]
				then
					LogearMensaje ${FUNCNAME[0]} "INF" "Se crea carpeta de duplicados en $directorioRechazados" $archivoLogInterprete
					mkdir $directorioRechazados/duplicados
			fi
			fecha_duplicado=$(date +%Y-%m-%d_%H:%M:%S)
			mv $directorioAceptados/$1 $directorioRechazados/duplicados/$1_$fecha_duplicado
			LogearMensaje ${FUNCNAME[0]} "INF" "Se rechaza archivo $1 por estar duplicado. Se guarda como $archivo_$fecha_duplicado en $directorioRechazados/duplicados" $archivoLogInterprete
		else
			LogearMensaje ${FUNCNAME[0]} "INF" "Se rechaza archivo $1 por estar duplicado. Se guarda en $directorioRechazados" $archivoLogInterprete
			mv $directorioAceptados/$1 $directorioRechazados/$1
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

if [ $exINIT_OK ]
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
