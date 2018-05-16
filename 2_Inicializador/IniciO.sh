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