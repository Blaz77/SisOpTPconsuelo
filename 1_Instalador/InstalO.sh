grupo=/Grupo4
valido=false
archivofConf=$HOME/Grupo4/dirconf/fnoc.conf

Pedir_Nombres_Directorios()
{
	directorioVacio=""
	
	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de ejecutables ($grupo/$1):"
		read dirEjecutables
		Validar_Nombre $dirEjecutables
	done
	
	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos maestros ($grupo/$2):"
		read dirMaestros
		Validar_Nombre $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de arribo de archivos externos ($grupo/$3):"
		read dirExternos
		Validar_Nombre $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de novedades aceptadas ($grupo/$4):"
		read dirAceptados
		Validar_Nombre $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos rechazados ($grupo/$5):"
		read dirRechazados
		Validar_Nombre $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos procesados ($grupo/$6):"
		read dirProcesados
		Validar_Nombre $dirProcesados $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de reportes ($grupo/$7):"
		read dirReportes
		Validar_Nombre $dirReportes $dirProcesados $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de logs de auditoría del sistema ($grupo/$8):"
		read dirLogs
		Validar_Nombre $dirLogs $dirReportes $dirProcesados $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	Pedir_Confirmacion
}

####Validar_Nombre recibe varios parametros: primero el directorio actual y despues los anteriormente ingresados
Validar_Nombre()
{
	if [ $1 = "$directorioVacio" ]
	then
		valido=false
	elif [ $1 = "dirconf" ]
	then
		valido=false
	else
		valido=true
	fi

	####valido que sea diferente a los anteriormente ingresados
	let	contador=0
	for i in $@
	do
		let contador=contador+1
		###que $contador sea > que 1 para que no se compare con si mismo
		if [ $contador \> "1" -a $1 = $i ]
		then
			valido=false
		fi
	done

	####valido que no exista el uno ya creado con ese nombre
	if [ -e $HOME/$grupo/$1 ]
	then
		valido=false
	fi

	if [ $valido = false ]
	then
		echo "Nombre de directorio inválido."
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
		read confirmaInstalacion
	done

	if [ $confirmaInstalacion = "NO" ]
	then
		echo "\nVuelva a ingresar los nombres de los directorios"
		Pedir_Nombres_Directorios $dirEjecutables $dirMaestros $dirExternos $dirAceptados $dirRechazados $dirProcesados $dirReportes $dirLogs
	elif [ $confirmaInstalacion = "SI" ]
	then
		Crear_Directorios $dirEjecutables $dirMaestros $dirExternos $dirAceptados $dirRechazados $dirProcesados $dirReportes $dirLogs
	fi
}

Crear_Directorios()
{
	mkdir $HOME/$grupo/$1
	mkdir $HOME/$grupo/$2
	mkdir $HOME/$grupo/$3
	mkdir $HOME/$grupo/$4
	mkdir $HOME/$grupo/$5
	mkdir $HOME/$grupo/$6
	mkdir $HOME/$grupo/$7
	mkdir $HOME/$grupo/$8
	echo "Directorios creados exitosamente"

	Mover_Archivos
	Crear_Archivo_Configuracion
}

Mover_Archivos()
{
	rutaMaestros="$HOME/Grupo4/$dirMaestros/"

	archivoAMover="$HOME/Grupo4/archivostp/T1.tab"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$HOME/Grupo4/archivostp/T2.tab"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$HOME/Grupo4/archivostp/p-s.mae"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$HOME/Grupo4/archivostp/PPI.mae"
	mv $archivoAMover $rutaMaestros

	####los otros archivos hay que moverlos tambien????
}

Crear_Archivo_Configuracion()
{
	fecha=$(date +"%d/%m/%y %H:%M:%S")

	####esto agrega una linea a lo ultimo del archivo
	####si el archivo no existe lo crea
	echo "ejecutables-$dirEjecutables-$USER-$fecha" >> $archivofConf
	echo "maestros-$dirMaestros-$USER-$fecha" >> $archivofConf
	echo "externos-$dirExternos-$USER-$fecha" >> $archivofConf
	echo "aceptados-$dirAceptados-$USER-$fecha" >> $archivofConf
	echo "rechazados-$dirRechazados-$USER-$fecha" >> $archivofConf
	echo "procesados-$dirProcesados-$USER-$fecha" >> $archivofConf
	echo "reportes-$dirReportes-$USER-$fecha" >> $archivofConf
	echo "logs-$dirLogs-$USER-$fecha" >> $archivofConf
}

Verificar_Existencia_Archivo_Configuracion()
{
	if [ -f $archivofConf ]
	then
		echo "Instalado"
		###Falta verificacion de salud y reparacion
	else
		echo "No instalado. Imposible de reparar."
	fi
}


VERSION=$(perl -e 'print $];')

if [ $VERSION \< "5" ]
then
	echo "Tiene que tener instalado Perl 5 o más."
	exit
fi
case $# in
	0) Pedir_Nombres_Directorios "ejec" "mae" "ext" "acep" "rech" "proc" "rep" "logs";;
	1) Verificar_Existencia_Archivo_Configuracion ;;
	*) echo "No es una línea de comando válida.";;
esac
