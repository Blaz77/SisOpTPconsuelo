grupo=/Grupo4
archivofConf=/Grupo4/dirconf/fnoc.conf

Pedir_Nombres_Directorios()
{
	echo "Defina el directorio de ejecutables ($grupo/$1):"
	read dirEjecutables
	echo "Defina el directorio de archivos maestros ($grupo/$2):"
	read dirMaestros
	echo "Defina el directorio de arribo de archivos externos ($grupo/$3):"
	read dirExternos
	echo "Defina el directorio de novedades aceptadas ($grupo/$4):"
	read dirAceptados
	echo "Defina el directorio de archivos rechazados ($grupo/$5):"
	read dirRechazados
	echo "Defina el directorio de archivos procesados ($grupo/$6):"
	read dirProcesados
	echo "Defina el directorio de reportes ($grupo/$7):"
	read dirReportes
	echo "Defina el directorio de logs de auditoría del sistema ($grupo/$8):"
	read dirLogs
	###faltan validaciones

	Pedir_Confirmacion
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

	####aca tambien hay que copiar archivos
	####y por ultimo, crear fnoc.conf
}

Ejecutar_Instalador_Con_Parametros()
{
	if [ $1 = "-r" ]
			then
				Verificar_Existencia_Archivo_Configuracion
			else
				echo "No es una linea de comnado valida."
	fi
}

Verificar_Existencia_Archivo_Configuracion()
{
	if [ -f archivofConf ]
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
	0) Pedir_Nombres_Directorios ejec mae ext acep rech proc rep logs;;
	1) Ejecutar_Instalador_Con_Parametros $1 ;;
	*) echo "No es una linea de comnado valida.";;
esac
