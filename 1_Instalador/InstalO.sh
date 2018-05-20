grupo=$HOME/Grupo4
valido=false
archivofConf=$HOME/Grupo4/dirconf/fnoc.conf
archivoLogInstalacion=$HOME/Grupo4/dirconf/instalo.log
existenTodosDirectorios=true
archivofConfEstaSano=true
source $HOME/SisOpTPconsuelo/Logger.sh

Pedir_Nombres_Directorios()
{
	directorioVacio=""
	echo "Todos sus directorios serán creados en $grupo"

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de ejecutables ($1):"
		read dirEjecutables
		Validar_Nombre $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos maestros ($2):"
		read dirMaestros
		Validar_Nombre $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de arribo de archivos externos ($3):"
		read dirExternos
		Validar_Nombre $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de novedades aceptadas ($4):"
		read dirAceptados
		Validar_Nombre $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos rechazados ($5):"
		read dirRechazados
		Validar_Nombre $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de archivos procesados ($6):"
		read dirProcesados
		Validar_Nombre $dirProcesados $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de reportes ($7):"
		read dirReportes
		Validar_Nombre $dirReportes $dirProcesados $dirRechazados $dirAceptados $dirExternos $dirMaestros $dirEjecutables
	done

	valido=false
	while [ $valido = false ]
	do
		echo "Defina el directorio de logs de auditoría del sistema ($8):"
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
	if [ -e $grupo/$1 ]
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
		echo "Vuelva a ingresar los nombres de los directorios"
		Pedir_Nombres_Directorios $dirEjecutables $dirMaestros $dirExternos $dirAceptados $dirRechazados $dirProcesados $dirReportes $dirLogs
	elif [ $confirmaInstalacion = "SI" ]
		then
		Crear_Directorios $dirEjecutables $dirMaestros $dirExternos $dirAceptados $dirRechazados $dirProcesados $dirReportes $dirLogs
	fi
}

Crear_Directorios()
{
	mkdir $grupo/$1
	mkdir $grupo/$2
	mkdir $grupo/$3
	mkdir $grupo/$4
	mkdir $grupo/$5
	mkdir $grupo/$6
	mkdir $grupo/$7
	mkdir $grupo/$8
	echo "Directorios creados exitosamente"

	Mover_Archivos
	Crear_Archivo_Configuracion
	Crear_Log_Instalacion
}

Mover_Archivos()
{
	rutaMaestros="$grupo/$dirMaestros/"

	archivoAMover="$grupo/archivostp/T1.tab"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$grupo/archivostp/T2.tab"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$grupo/archivostp/p-s.mae"
	mv $archivoAMover $rutaMaestros

	archivoAMover="$grupo/archivostp/PPI.mae"
	mv $archivoAMover $rutaMaestros

	####los otros archivos hay que moverlos tambien????
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
}

Crear_Log_Instalacion()
{
	LogearMensaje ${FUNCNAME[0]} "INF" "Creando log de instalacion" $archivoLogInstalacion
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
			fi
		else
			echo "El archivo de configuración no existe. Vuelva a instalar."
		fi
	else
		echo "No es una línea de comando válida."
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
}

Existen_Todos_Directorios()
{
	while read -r linea
	do
		directorioElegido=$(echo $linea | cut -d '-' -f2)
		if [ ! -e $grupo/$directorioElegido ]
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
		if [ ! -e $grupo/$directorioElegido ]
		then
			mkdir $grupo/$directorioElegido
		fi
	done < $archivofConf

	echo "Instalación reparada exitosamente."
}

Modulo_Reparacion()
{
	echo "La instalación está incompleta. ¿Desea repararla? (SI-NO):"
	read reparar
	while [ $reparar != "NO" -a $reparar != "SI" ]
	do
		echo "Ingrese SI o NO"
		read reparar
	done

	if [ $reparar = "SI" ]
	then
		Reparar
	else
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
		fi
	else
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
