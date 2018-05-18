configFile=../dirconf/fnoc.conf

Leer_Config()
{
	exDIR_EXEC=grep '^Ejecutables.*' $configFile | cut -f2 -d'-'
	exDIR_MASTER=grep '^Maestros.*' $configFile | cut -f2 -d'-'
	exDIR_EXT=grep '^Externos.*' $configFile | cut -f2 -d'-'
	exDIR_ACCEPT=grep '^Aceptados.*' $configFile | cut -f2 -d'-'
	exDIR_REFUSE=grep '^Rechazados.*' $configFile | cut -f2 -d'-'
	exDIR_PROCESS=grep '^Procesados.*' $configFile | cut -f2 -d'-'
	exDIR_REPORTSgrep '^Reportes.*' $configFile | cut -f2 -d'-'
	exDIR_LOGS=grep '^Logs.*' $configFile | cut -f2 -d'-'
}

# Validar existencia de archivos y directorios segun archivo de configuracion
Verificar_Directorios()
{
	echo "a"
}

# Verificar y corregir permisos de archivos maestros y ejecutables
Verificar_Permisos()
{
	echo "b"
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
Verificar_Permisos
Setear_ambiente
Iniciar_Demonio

Iniciar_Reportes