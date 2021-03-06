#!/bin/bash

source ./Logger.sh
grupo=$HOME/Grupo4
configFile="$grupo/dirconf/fnoc.conf"
pidRecordFile="./pidRecord.dat"
logFile="$grupo/dirconf/IniciO.log"

bin_Instalador=InstalO.sh
bin_Inicializador=IniciO.sh
bin_Demonio=DetectO.sh
bin_Killer=StopO.sh
bin_Interprete=InterpretO.sh
bin_Reportes=ReportO.pl

mae_Files="p-s.mae PPI.mae"
table_Files="T1.tab T2.tab"

# Params: string mensajeEspecifico, string funcionOrigen
Error_Fatal()
{
	error="Imposible inicializar el sistema: $1"
	LogearMensaje "$2" "ERR" "$error" "$logFile"
	echo "$error"
}

# Params: string mensajeEspecifico, string funcionOrigen
Log_Info()
{
	LogearMensaje "$2" "INF" "$1" "$logFile"
	echo "$1"
}

Leer_Config()
{
	exDIR_EXEC=$(grep '^Ejecutables.*' $configFile | cut -f2 -d'-')
	exDIR_MASTER=$(grep '^Maestros.*' $configFile | cut -f2 -d'-')
	exDIR_EXT=$(grep '^Externos.*' $configFile | cut -f2 -d'-')
	exDIR_ACCEPT=$(grep '^Aceptados.*' $configFile | cut -f2 -d'-')
	exDIR_REFUSE=$(grep '^Rechazados.*' $configFile | cut -f2 -d'-')
	exDIR_PROCESS=$(grep '^Procesados.*' $configFile | cut -f2 -d'-')
	exDIR_REPORTS=$(grep '^Reportes.*' $configFile | cut -f2 -d'-')
	exDIR_LOGS=$(grep '^Logs.*' $configFile | cut -f2 -d'-')

	for i in "$exDIR_EXEC" "$exDIR_MASTER" "$exDIR_EXT" "$exDIR_ACCEPT" "$exDIR_REFUSE" "$exDIR_PROCESS" "$exDIR_REPORTS" "$exDIR_LOGS"
	do
		if [ "$i" == "" ]
		then
			Error_Fatal "Archivo de configuracion daniado" "Leer_config"
			return 1
		fi
	done

	return 0
}

Verificar_Directorio() # Params: string dirName
{
	if [ ! -d "$grupo/$1" ] # Existe directorio
	then
		Error_Fatal "No se encuentra el directorio $1" "Verificar_Directorio"
		return 1
	fi
	return 0
}

# Validar existencia de archivos y directorios segun archivo de configuracion
Verificar_Directorios()
{
	Verificar_Directorio "$exDIR_EXEC"
	local errors=$?
	Verificar_Directorio "$exDIR_MASTER"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_EXT"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_ACCEPT"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_REFUSE"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_PROCESS"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_REPORTS"
	errors=$(expr $errors + $?)
	Verificar_Directorio "$exDIR_LOGS"
	errors=$(expr $errors + $?)
	
	return $errors
}

Verificar_Archivo() # Params: string dirName, string scriptName
{
	if [ ! -f "$grupo/$1/$2" ] # Existe archivo
	then
		Error_Fatal "No se encuentra el archivo $2" "Verificar_Archivo"
		return 1
	fi
	return 0
}

Verificar_Archivos()
{
	local errors=0
	for i in "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
	do
		Verificar_Archivo "$exDIR_EXEC" $i
		errors=$(expr $errors + $?)
	done

	for i in $mae_Files
	do
		Verificar_Archivo "$exDIR_MASTER" $i
		errors=$(expr $errors + $?)
	done

	for i in $table_Files
	do
		Verificar_Archivo "$exDIR_MASTER" $i
		errors=$(expr $errors + $?)
	done
	return $errors
}

Verificar_Permiso_Lectura() # Params: string dirName, string fileName
{
	if [ ! -r "$grupo/$1/$2" ]
	then
		chmod +r "$grupo/$1/$2"
		Log_Info "Se agrega permiso de lectura para el archivo $2." "Verificar_Permiso_Lectura"
	else
		Log_Info "$2: Permiso de lectura OK." "Verificar_Permiso_Lectura"
	fi
}

Verificar_Permiso_Ejecucion() # Params: string dirName, string fileName
{
	if [ ! -x "$grupo/$1/$2" ]
	then
		chmod +x "$grupo/$1/$2"
		Log_Info "Se agrega permiso de ejecucion para el archivo $2." "Verificar_Permiso_Ejecucion"
	else
		Log_Info "$2: Permiso de ejecucion OK." "Verificar_Permiso_Ejecucion"
	fi
}

# Verificar y corregir permisos de archivos maestros y ejecutables
Verificar_Permisos()
{
	for i in "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
	do
		Verificar_Permiso_Ejecucion "$exDIR_EXEC" $i
	done

	for i in $mae_Files
	do
		Verificar_Permiso_Lectura "$exDIR_MASTER" $i
	done

	for i in $table_Files
	do
		Verificar_Permiso_Lectura "$exDIR_MASTER" $i
	done
}

# Prepara las variables de ambiente para ser utilizadas por el resto de los scripts
Setear_ambiente()
{
	exINIT_OK=1
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
	if [ -f "$grupo/$exDIR_EXEC/$pidRecordFile" ]
	then
		local PID=
		read -r PID < "$grupo/$exDIR_EXEC/$pidRecordFile"
		local PID_PS=$(ps -fo pid,args -p $PID | grep ".*$PID.*Grupo4.*\.sh$" | sed -e 's/^[ \t]*//' | cut -f1 -d' ')
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
	"$grupo/$exDIR_EXEC/$bin_Demonio" &
	demonio_PID=$!
	echo "$demonio_PID" > "$pidRecordFile"
	Log_Info "Se inicia el detector de novedades en el proceso: $demonio_PID. Para detener el detector ejecute el comando StopO.sh" "Iniciar_Demonio"
}

Main()
{
	if [ "$exINIT_OK" == 1 ]
	then
		echo "El ambiente ya fue inicializado anteriormente."
	else
		Leer_Config
		if [ $? -gt 0 ]; then return 1; fi
		Verificar_Directorios
		if [ $? -gt 0 ]; then return 1; fi
		Verificar_Archivos
		if [ $? -gt 0 ]; then return 1; fi
		Verificar_Permisos
		Setear_ambiente
	fi

	tmp_Retorno=
	Verificar_Demonio
	if [ "$tmp_Retorno" == "" ]
	then
		Iniciar_Demonio
	fi
}

Main