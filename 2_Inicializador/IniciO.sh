#!/bin/bash

source ./Logger.sh
grupo=$HOME/Grupo4
configFile="../dirconf/fnoc.conf"
pidRecordFile="./pidRecord.dat"
logFile="../dirconf/IniciO.log"

bin_Instalador=InstalO.sh
bin_Inicializador=IniciO.sh
bin_Demonio=DetectO.sh
bin_Killer=StopO.sh
bin_Interprete=InterpretO.sh
bin_Reportes=ReportO.sh

mae_Files="p-s.mae PPI.mae"
table_Files="T1.tab T2.tab"

# Params: string mensajeEspecifico, string funcionOrigen
Error_Fatal()
{
	error="Imposible inicializar el sistema: $1"
	LogearMensaje "IniciO" "ERR" "$error" "$logFile"
	echo "$error"
	exit
}

# Params: string mensajeEspecifico, string funcionOrigen
Log_Info()
{
	LogearMensaje "IniciO" "INF" "$1" "$logFile"
	echo "$1"
}

Leer_Config()
{
	exDIR_EXEC=$(grep '^Ejecutables.*' $configFile | cut -f2 -d'-')
	exDIR_MASTER=$(grep '^Maestros.*' $configFile | cut -f2 -d'-')
	# TODO : Cambiar por Arribos
	exDIR_EXT=$(grep '^Externos.*' $configFile | cut -f2 -d'-')
	exDIR_ACCEPT=$(grep '^Aceptados.*' $configFile | cut -f2 -d'-')
	exDIR_REFUSE=$(grep '^Rechazados.*' $configFile | cut -f2 -d'-')
	exDIR_PROCESS=$(grep '^Procesados.*' $configFile | cut -f2 -d'-')
	exDIR_REPORTS=$(grep '^Reportes.*' $configFile | cut -f2 -d'-')
	exDIR_LOGS=$(grep '^Logs.*' $configFile | cut -f2 -d'-')
	
	for i in "$exDIR_EXEC" "$exDIR_MASTER" "$exDIR_EXT" "$exDIR_ACCEPT" "$exDIR_REFUSE" "$exDIR_PROCESS" "$exDIR_REPORTS" "$exDIR_LOGS"
	do
		if [ $i == "" ]
		then
			Error_Fatal "Archivo de configuracion dañado" "Leer_config"
		fi
	done
	
	exINIT_OK=1
}

Verificar_Directorio() # Params: string dirName
{
	if [ ! -d $grupo/$1 ] # Existe directorio
	then
		Error_Fatal "No se encuentra el directorio $1" "Verificar_Directorio"
	fi
}

# Validar existencia de archivos y directorios segun archivo de configuracion
Verificar_Directorios()
{
	Verificar_Directorio $exDIR_EXEC 
	Verificar_Directorio $exDIR_MASTER
	Verificar_Directorio $exDIR_EXT
	Verificar_Directorio $exDIR_ACCEPT
	Verificar_Directorio $exDIR_REFUSE
	Verificar_Directorio $exDIR_PROCESS
	Verificar_Directorio $exDIR_REPORTS
	Verificar_Directorio $exDIR_LOGS
}

Verificar_Archivo() # Params: string dirName, string scriptName
{
	if [ ! -f $grupo/$1/$2 ] # Existe archivo
	then
		Error_Fatal "No se encuentra el archivo $2" "Verificar_Archivo"
	fi
}

Verificar_Archivos()
{
	for i in "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
	do
		Verificar_Archivo $exDIR_EXEC $i
	done
	
	for i in $mae_Files
	do
		Verificar_Archivo $exDIR_MASTER $i
	done
	
	for i in $table_Files
	do
		Verificar_Archivo $exDIR_MASTER $i
	done
}

Verificar_Permiso_Lectura() # Params: string dirName, string fileName
{
	if [ ! -r $grupo/$1/$2 ]
	then
		chmod +r $grupo/$1/$2
		Log_Info "Se agrega permiso de lectura para el archivo $2." "Verificar_Permiso_Lectura"
	else
		Log_Info "$2: Permiso de lectura OK." "Verificar_Permiso_Lectura"
	fi
}

Verificar_Permiso_Ejecucion() # Params: string dirName, string fileName
{
	if [ ! -x $grupo/$1/$2 ]
	then
		chmod +x $grupo/$1/$2
		Log_Info "Se agrega permiso de ejecucioon para el archivo $2." "Verificar_Permiso_Ejecucion"
	else
		Log_Info "$2: Permiso de ejecucioon OK." "Verificar_Permiso_Ejecucion"
	fi
}

# Verificar y corregir permisos de archivos maestros y ejecutables
Verificar_Permisos()
{
	for i in "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
	do
		Verificar_Permiso_Ejecucion $exDIR_EXEC $i
	done
	
	for i in $mae_Files
	do
		Verificar_Permiso_Lectura $exDIR_MASTER $i
	done
	
	for i in $table_Files
	do
		Verificar_Permiso_Lectura $exDIR_MASTER $i
	done
}

# Prepara las variables de ambiente para ser utilizadas por el resto de los scripts
Setear_ambiente()
{
	export exDIR_EXEC
	export exDIR_MASTER
	export exDIR_EXT
	export exDIR_ACCEPT
	export exDIR_REFUSE
	export exDIR_PROCESS
	export exDIR_REPORTS
	export exDIR_LOGS
	export exINIT_OK
}

# Verifica demonio corriendo, si es afirmativo, muestra y loguea el PID
Verificar_Demonio()
{
	if [ -f $grupo/$exDIR_EXEC/$pidRecordFile ]
	then
		local PID=
		read -r PID < $grupo/$exDIR_EXEC/$pidRecordFile
		local PID_PS=$(ps -fo pid,args -p $PID | grep ".*$PID./$bin_Inicializador$" | cut -f1 -d' ')
		if [ "$PID" == "$PID_PS" -a "$PID_PS" != "" ]
		then
			tmp_Retorno=$PID
			Log_Info "Detector de novedades ya iniciado. No se volvera a ejecutar." "Verificar_Demonio"
		fi
	fi
}

# Iniciar el detector de novedades en background
Iniciar_Demonio()
{
	$grupo/$exDIR_EXEC/$bin_Demonio &
	demonio_PID=$!
	echo "$demonio_PID" > "$pidRecordFile"
	Log_Info "Se inicia el detector de novedades en el proceso: $demonio_PID" "Iniciar_Demonio"
}

# Preguntar e iniciar el modulo de reportes
Iniciar_Reportes()
{
	while [ "$ch_IniciarReportes" != "n"  -a "$ch_IniciarReportes" != "s" ]
	do
		read -r -e -n 1 -p "Desea iniciar el modulo de reportes? (s/n): " ch_IniciarReportes
	done
	
	if [ "$ch_IniciarReportes" == "s" ]
	then
		$grupo/$exDIR_EXEC/$bin_Reportes
	fi
}

Leer_Config
Verificar_Directorios
Verificar_Archivos
Verificar_Permisos
Setear_ambiente

tmp_Retorno=
Verificar_Demonio
if [ "$tmp_Retorno" == "" ]
then
	Iniciar_Demonio
fi

sleep 1
Iniciar_Reportes
