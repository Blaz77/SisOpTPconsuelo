grupo=$HOME/Grupo4
configFile=../dirconf/fnoc.conf
bin_Instalador=InstalO.sh
bin_Inicializador=IniciO.sh
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
	for i in "$bin_Instalador" "bin_Killer" "bin_Interprete" "bin_Reportes"
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
	for i in "$bin_Instalador" "bin_Killer" "bin_Interprete" "bin_Reportes"
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
	echo "2"
}

# Iniciar el detector de novedades en background
Iniciar_Demonio()
{

}

# Preguntar e iniciar el modulo de reportes
Iniciar_Reportes()
{

}

# Estas cuatro llamadas solo deben hacerse si no hay demonio corriendo
Verificar_Directorios
Verificar_Archivos
Verificar_Permisos
Setear_ambiente
Iniciar_Demonio

Iniciar_Reportes