#!/bin/bash

grupo=$HOME/Grupo4
paqueteOrigen=$grupo/"package"
valido=false
archivofConf=$HOME/Grupo4/dirconf/fnoc.conf
archivoLogInstalacion=$HOME/Grupo4/dirconf/InstalO.log
existenTodosDirectorios=true
archivofConfEstaSano=true
source $paqueteOrigen/scripts/Logger.sh

Pedir_Nombres_Directorios()
{
	directorioVacio=""
	echo "Todos sus directorios serán creados en $grupo"
	LogearMensaje ${FUNCNAME[0]} "INF" "Indicando ruta donde se crearan los directorios $grupo" $archivoLogInstalacion

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de ejecutables ($1): " "dirEjecutables"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de ejecutables" $archivoLogInstalacion
		if [ "$dirEjecutables" = "" ]
		then
			dirEjecutables=$1
		fi
		Validar_Nombre "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de archivos maestros ($2): " "dirMaestros"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de archivos maestros" $archivoLogInstalacion
		if [ "$dirMaestros" = "" ]
		then
			dirMaestros=$2
		fi
		Validar_Nombre "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de arribo de archivos externos ($3): " "dirExternos"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de archivos externos" $archivoLogInstalacion
		if [ "$dirExternos" = "" ]
		then
			dirExternos=$3
		fi
		Validar_Nombre "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de novedades aceptadas ($4): " "dirAceptados"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de novedades aceptadas" $archivoLogInstalacion
		if [ "$dirAceptados" = "" ]
		then
			dirAceptados=$4
		fi
		Validar_Nombre "$dirAceptados" "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de archivos rechazados ($5): " "dirRechazados"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de archivos rechazados" $archivoLogInstalacion
		if [ "$dirRechazados" = "" ]
		then
			dirRechazados=$5
		fi
		Validar_Nombre "$dirRechazados" "$dirAceptados" "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de archivos procesados ($6): " "dirProcesados"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de archivos procesados" $archivoLogInstalacion
		if [ "$dirProcesados" = "" ]
		then
			dirProcesados=$6
		fi
		Validar_Nombre "$dirProcesados" "$dirRechazados" "$dirAceptados" "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de reportes ($7): " "dirReportes"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de reportes" $archivoLogInstalacion
		if [ "$dirReportes" = "" ]
		then
			dirReportes=$7
		fi
		Validar_Nombre "$dirReportes" "$dirProcesados" "$dirRechazados" "$dirAceptados" "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	valido=false
	while [ $valido = false ]
	do
		read -p "Defina el directorio de logs de auditoría del sistema ($8): " "dirLogs"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de directorio de logs de auditoría del sistema" $archivoLogInstalacion
		if [ "$dirLogs" = "" ]
		then
			dirLogs=$8
		fi
		Validar_Nombre "$dirLogs" "$dirReportes" "$dirProcesados" "$dirRechazados" "$dirAceptados" "$dirExternos" "$dirMaestros" "$dirEjecutables"
	done

	Pedir_Confirmacion
}

####Validar_Nombre recibe varios parametros: primero el directorio actual y despues los anteriormente ingresados
Validar_Nombre()
{
	if [ "$1" = "dirconf" ]
	then
		valido=false
		LogearMensaje ${FUNCNAME[0]} "ERR" "Define el nombre de directorio directorio como dirconf y eso es invalido" $archivoLogInstalacion
	elif [ "$1" = "package" ]
	then
		valido=false
		LogearMensaje ${FUNCNAME[0]} "ERR" "Define el nombre de directorio directorio como package y eso es invalido" $archivoLogInstalacion
	else
		valido=true

	    ####valido que sea diferente a los anteriormente ingresados
	    let	contador=0
	    for i in $@
	    do
		    let contador=contador+1
		    ###que $contador sea > que 1 para que no se compare con si mismo
		    if [ $contador \> "1" -a "$1" = $i ]
		    then
			    valido=false
		    fi
	    done

	    ####valido que no exista el uno ya creado con ese nombre
	    if [ -e "$grupo/$1" ]
	    then
		    valido=false
	    fi
	fi

	if [ $valido = false ]
	then
		echo "Nombre de directorio inválido."
		LogearMensaje ${FUNCNAME[0]} "ERR" "El nombre de directorio ingresado ya habia sido existe." $archivoLogInstalacion
	fi
}

Pedir_Confirmacion()
{
	echo "
TP SO7508 Primer Cuatrimestre 2018. Tema O Copyright © Grupo 4.
Librería del Sistema: dirconf
Ejecutables en: $dirEjecutables
Directorio para los archivos maestros: $dirMaestros
Directorio para el arribo de archivos externos: $dirExternos
Directorio para los archivos aceptados: $dirAceptados
Directorio para los archivos rechazados: $dirRechazados
Directorio para Archivos procesados: $dirProcesados
Directorio para los reportes: $dirReportes
Logs de auditoria del Sistema: $dirLogs
Estado de la instalación: LISTA
¿Confirma la instalación? (SI-NO): "
	read confirmaInstalacion
	while [ $confirmaInstalacion != "NO" -a $confirmaInstalacion != "SI" ]
	do
		echo "Ingrese SI o NO"
		LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita ingreso de confirmacion de directorios." $archivoLogInstalacion
		read confirmaInstalacion
	done

	if [ $confirmaInstalacion = "NO" ]
	then
		echo "Vuelva a ingresar los nombres de los directorios"
		LogearMensaje ${FUNCNAME[0]} "INF" "El usuario no confirma los directorios.Se procede a pedir el ingreso nuevamente." $archivoLogInstalacion
		Pedir_Nombres_Directorios "$dirEjecutables" "$dirMaestros" "$dirExternos" "$dirAceptados" "$dirRechazados" "$dirProcesados" "$dirReportes" "$dirLogs"
	elif [ $confirmaInstalacion = "SI" ]
		then
			LogearMensaje ${FUNCNAME[0]} "INF" "El usuario confirma los directorios." $archivoLogInstalacion
		  Crear_Directorios "$dirEjecutables" "$dirMaestros" "$dirExternos" "$dirAceptados" "$dirRechazados" "$dirProcesados" "$dirReportes" "$dirLogs"
	fi
}

Crear_Directorios()
{
	mkdir -p "$grupo/$1"
	mkdir -p "$grupo/$2"
	mkdir -p "$grupo/$3"
	mkdir -p "$grupo/$4"
	mkdir -p "$grupo/$5"
	mkdir -p "$grupo/$6"
	mkdir -p "$grupo/$7"
	mkdir -p "$grupo/$8"
	echo "Directorios creados exitosamente"
	LogearMensaje ${FUNCNAME[0]} "INF" "Se crearon los directorios exitosamente." $archivoLogInstalacion

	Mover_Archivos
	Crear_Archivo_Configuracion
	Crear_Log_Instalacion
}

Mover_Archivos()
{
	rutaMaestros="$grupo/$dirMaestros/"
    rutaScripts="$grupo/$dirEjecutables/"

	archivoAMover="$paqueteOrigen/archivostp/T1.tab"
	cp $archivoAMover "$rutaMaestros"

	archivoAMover="$paqueteOrigen/archivostp/T2.tab"
	cp $archivoAMover "$rutaMaestros"

	archivoAMover="$paqueteOrigen/archivostp/p-s.mae"
	cp $archivoAMover "$rutaMaestros"

	archivoAMover="$paqueteOrigen/archivostp/PPI.mae"
	cp $archivoAMover "$rutaMaestros"

	archivoAMover="$paqueteOrigen/scripts/Logger.sh"
	cp $archivoAMover "$rutaScripts"

	archivoAMover="$paqueteOrigen/scripts/IniciO.sh"
	cp $archivoAMover "$rutaScripts"

	archivoAMover="$paqueteOrigen/scripts/DetectO.sh"
	cp $archivoAMover "$rutaScripts"

	archivoAMover="$paqueteOrigen/scripts/StopO.sh"
	cp $archivoAMover "$rutaScripts"

	archivoAMover="$paqueteOrigen/scripts/InterpretO.sh"
	cp $archivoAMover "$rutaScripts"

	archivoAMover="$paqueteOrigen/scripts/ReportO.pl"
	cp $archivoAMover "$rutaScripts"

	LogearMensaje ${FUNCNAME[0]} "INF" "Se movieron los archivos del paquete de origen a las rutas establecidas por el usuario." $archivoLogInstalacion
}

Crear_Archivo_Configuracion()
{
	fecha=$(date +"%d/%m/%y,%H:%M:%S")

	####esto agrega una linea a lo ultimo del archivo
	####si el archivo no existe lo crea
	echo "Ejecutables-$dirEjecutables-$USER-$fecha" >> $archivofConf
	echo "Maestros-$dirMaestros-$USER-$fecha" >> $archivofConf
	echo "Externos-$dirExternos-$USER-$fecha" >> $archivofConf
	echo "Aceptados-$dirAceptados-$USER-$fecha" >> $archivofConf
	echo "Rechazados-$dirRechazados-$USER-$fecha" >> $archivofConf
	echo "Procesados-$dirProcesados-$USER-$fecha" >> $archivofConf
	echo "Reportes-$dirReportes-$USER-$fecha" >> $archivofConf
	echo "Logs-$dirLogs-$USER-$fecha" >> $archivofConf
	LogearMensaje ${FUNCNAME[0]} "INF" "Se crea el archivo de configuración con las rutas establecidas por el usuario." $archivoLogInstalacion
}

Crear_Log_Instalacion()
{
	LogearMensaje ${FUNCNAME[0]} "INF" "Instalacion finalizada." $archivoLogInstalacion
}

Ejecutar_Instalador_Con_Parametros()
{
	#Por ahora solo tenemos -r pero podemos extenderlo a otras funcionalidades
	if [ $1 = "-r" ]
	then
		if [ -e	 $archivofConf ]
		then
			Esta_Sano_fConf
			if [ $archivofConfEstaSano = true ]
			then
					Reparar
			else
				echo "El archivo de configuración está dañado. Imposible reparar."
				LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita realizar la reparacion pero el archivo de configuracion esta dañado. Imposible reparar." $archivoLogInstalacion
			fi
		else
			echo "El archivo de configuración no existe. Vuelva a instalar."
			LogearMensaje ${FUNCNAME[0]} "INF" "Se solicita realizar la reparacion pero no existe el archivo de configuracion." $archivoLogInstalacion
		fi
	else
		echo "No es una línea de comando válida."
		LogearMensaje ${FUNCNAME[0]} "ERR" "Ingreso de linea de comando invalida." $archivoLogInstalacion
	fi
}

Mostrar_Datos_Instalacion()
{
	echo "La instalación está completa."
	while read -r linea
	do
		archivosTipo=$(echo $linea | cut -d '-' -f1)
		directorioElegido=$(echo $linea | cut -d '-' -f2)
		echo "$archivosTipo en el directorio: $grupo/$directorioElegido"
	done < $archivofConf
	LogearMensaje ${FUNCNAME[0]} "INF" "Mostrando datos de instalacion." $archivoLogInstalacion
}

Existen_Todos_Directorios()
{
	while read -r linea
	do
		directorioElegido=$(echo $linea | cut -d '-' -f2)
		if [ ! -e "$grupo/$directorioElegido" ]
		then
			existenTodosDirectorios=false
		fi
	done < $archivofConf
}

Reparar()
{
	####Si faltaban directorios los creo
	while read -r linea
	do
		directorioElegido=$(echo $linea | cut -d '-' -f2)
		if [ ! -e "$grupo/$directorioElegido" ]
		then
			mkdir "$grupo/$directorioElegido"
		fi
	done < $archivofConf

	LogearMensaje ${FUNCNAME[0]} "INF" "Instalación reparada exitosamente." $archivoLogInstalacion
	echo "Instalación reparada exitosamente."
}

Modulo_Reparacion()
{
	echo "La instalación está incompleta. ¿Desea repararla? (SI-NO):"
	LogearMensaje ${FUNCNAME[0]} "INF" "La instalacion ya habia sido realizada, por ende se le solicita al usuario si desde repararla." $archivoLogInstalacion
	read reparar
	while [ $reparar != "NO" -a $reparar != "SI" ]
	do
		echo "Ingrese SI o NO"
		read reparar
	done

	if [ $reparar = "SI" ]
	then
		LogearMensaje ${FUNCNAME[0]} "INF" "El usuario solicita la reparacion." $archivoLogInstalacion
		Reparar
	else
		LogearMensaje ${FUNCNAME[0]} "INF" "El usuario no desea realizar la reparacion." $archivoLogInstalacion
		exit
	fi
}

Esta_Sano_fConf()
{
	####verifico que el archivo tenga 8 lineas, una por cada directorio
	let contador=0
	while read -r linea
	do
		let contador=contador+1
	done < $archivofConf

	if [ $contador -ne 8 ]
	then
		archivofConfEstaSano=false
	fi

	####verifico que las 8 lineas tengan 3 guiones (quiere decir que hay 4 campos)
	####y que minimamente todos los campos tengan un caracter y luego cualquier cosa (que no sea un campo vacio)
	lineasQueCumplenRE=$(grep '..*-..*-..*-..*' $archivofConf)
	let contador=0
	for linea in $lineasQueCumplenRE
	do
		let contador=contador+1
	done

	if [ $contador -ne 8 ]
	then
		archivofConfEstaSano=false
	fi
}

Instalacion()
{
	if [ -e	 $archivofConf ]
	then
		Esta_Sano_fConf
		if [ $archivofConfEstaSano = true ]
		then
			Existen_Todos_Directorios
			if [ $existenTodosDirectorios = true ]
			then
				Mostrar_Datos_Instalacion
			else
				Modulo_Reparacion
			fi
		else
			echo "El archivo de configuración está dañado. Imposible continuar."
			LogearMensaje ${FUNCNAME[0]} "ALE" "El archivo de configuración está dañado. Imposible continuar." $archivoLogInstalacion
		fi
	else
		LogearMensaje ${FUNCNAME[0]} "INF" "Ejecutando instalacion" $archivoLogInstalacion
		Pedir_Nombres_Directorios "ejec" "mae" "ext" "acep" "rech" "proc" "rep" "logs"
	fi
}



VERSION=$(perl -e 'print $];')

if [ $VERSION \< "5" ]
then
	echo "Tiene que tener instalado Perl 5 o más."
	exit
fi
case $# in
	0) Instalacion ;;
	1) Ejecutar_Instalador_Con_Parametros $1 ;;
	*) echo "No es una línea de comando válida.";;
esac
