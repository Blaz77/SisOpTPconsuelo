grupo=$HOME/Grupo4
configFile=../dirconf/fnoc.conf
pidRecordFile=

bin_Instalador=InstalO.sh
bin_Inicializador=IniciO.sh
bin_Demonio=DetectO.sh
bin_Killer=StopO.sh
bin_Interprete=InterpretO.sh
bin_Reportes=ReportO.sh

mae_Files="P-S.mae PPI.mae"
table_Files="T1.tab T2.tab"

Error_Fatal()
{
	# LOGW5 $1 $2 $3 $4 $5
	echo "Imposible inicializar " # Y bla bla
	exit
}

Leer_Config()
{
	exDIR_EXEC=grep '^Ejecutables.*' $configFile | cut -f2 -d'-'
	exDIR_MASTER=grep '^Maestros.*' $configFile | cut -f2 -d'-'
	# TODO : Cambiar por Arribos
	exDIR_EXT=grep '^Externos.*' $configFile | cut -f2 -d'-'
	exDIR_ACCEPT=grep '^Aceptados.*' $configFile | cut -f2 -d'-'
	exDIR_REFUSE=grep '^Rechazados.*' $configFile | cut -f2 -d'-'
	exDIR_PROCESS=grep '^Procesados.*' $configFile | cut -f2 -d'-'
	exDIR_REPORTS=grep '^Reportes.*' $configFile | cut -f2 -d'-'
	exDIR_LOGS=grep '^Logs.*' $configFile | cut -f2 -d'-'
	
	for i in "$exDIR_EXEC" "$exDIR_MASTER" "$exDIR_EXT" "$exDIR_ACCEPT" "$exDIR_REFUSE" "$exDIR_PROCESS" "$exDIR_REPORTS" "$exDIR_LOGS"
	do
		if [ $i == "" ]
		then
			Error_Fatal 1 2 3 4 5
		fi
	done
	
	exINIT_OK=1
}

Verificar_Directorio() # Params: string dirName
{
	if [ ! -d $grupo/$1 ] # Existe directorio
	then
		Error_Fatal $1 2 3 4 5
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
		Error_Fatal $2 2 3 4 5
	fi
}

Verificar_Archivos()
{
	for i in "$bin_Instalador" "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
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
		# LOGW5
		echo "Se agrega permiso de lectura para el archivo $2."
	else
		# LOGW5
		echo "$2: Permiso de lectura OK."
	fi
}

Verificar_Permiso_Ejecucion() # Params: string dirName, string fileName
{
	if [ ! -x $grupo/$1/$2 ]
	then
		chmod +x $grupo/$1/$2
		# LOGW5
		echo "Se agrega permiso de ejecucioon para el archivo $2."
	else
		# LOGW5
		echo "$2: Permiso de ejecucioon OK."
	fi
}

# Verificar y corregir permisos de archivos maestros y ejecutables
Verificar_Permisos()
{
	for i in "$bin_Instalador" "$bin_Demonio" "$bin_Killer" "$bin_Interprete" "$bin_Reportes"
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
}ç

# Verifica demonio corriendo, si es afirmativo, muestra y loguea el PID
Verificar_Demonio()
{
	if [ -f $grupo/$exDIR_EXEC/$pidRecordFile ]
	then
		local PID=
		read -r PID < $grupo/$exDIR_EXEC/$pidRecordFile
		if [[ "$PID" =~ "^[0-9]+$" ]] # Solo numeros
        then
			local PID_PS = ps -eo pid,args | grep ".*$PID.*$bin_Demonio$" | cut -f1 -d' '
			if [ $PID == $PID_PS ]
			then
				tmp_Retorno=$PID
				# LOGW5
				echo "Detector de novedades ya iniciado. No se volvera a ejecutar."
			fi
		fi
	fi
}

# Iniciar el detector de novedades en background
Iniciar_Demonio()
{
	$grupo/$exDIR_EXEC/$bin_Demonio &
	demonio_PID=$!
	# LOGW5
	echo "Se inicia el detector de novedades en el proceso:" $demonio_PID
}

# Preguntar e iniciar el modulo de reportes
Iniciar_Reportes()
{
	while [ $ch_IniciarReportes != "n" -a $ch_IniciarReportes != "s" ]
	do
		read -r -e -n 1 -p "Desea iniciar el modulo de reportes? (s/n): " ch_IniciarReportes
	done
	
	if [ $ch_IniciarReportes == "s" ]
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
if [ tmp_Retorno == "" ]
then
	Iniciar_Demonio
fi

Iniciar_Reportes