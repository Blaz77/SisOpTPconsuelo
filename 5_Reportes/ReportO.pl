#!/usr/bin/perl

use Getopt::Std;
my %Metadatos;

sub Mostrar_Ayuda{
	print "\n",
		"Modo de uso:\n",
		"  ReportO.pl <pais> [<sistema>] [<periodo>] [-a | -g]\n",
		"\n",
		"Condiciones de ejecucion:\n",
		"  El sistema debe estar inicializado\n",
		"\n",
		"Parametros:\n",
		"  <pais>	(OBLIGATORIO)\n",
		"		Codigo de pais.\n",
		"  <sistema> \n",
		"		Codigo del sistema. Si se omite se consideran todos.\n",
		"  <periodo> \n",
		"		Periodo de tiempo a filtrar (En anios). Ejemplo: 2016-2018.\n",
		"\n",
		"  -g		Si se define, se guardan los resultados en un archivo.\n",
		"			En caso contrario, se muestra por pantalla.\n",
		"  -a		Muestra esta ayuda\n",
		"\n";
}


sub Cargar_Metadatos
{
	# Hardcodeado, la vida misma
}

sub Obtener_PPImpagos
{
		($archivo_maestro) = "$ENV{HOME}/Grupo4/$ENV{exDIR_MASTER}/PPI.mae";
	### Para que funcione hay que tener estos archivos en el directorio donde estoy

	print "Nombre de archivos: $archivo_maestro \n";
	open(MAESTRO, "<$archivo_maestro") || die "ERROR: no se pudo abrir el archivo $archivo_maestro";

	my %PPImpagos;
	while ($linea = <MAESTRO>)
	{
		($PAIS_ID, $SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_FE, $PRES_ID, $PRES_TI, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB) = split(";", $linea);
		
		# A cada monto le reemplazo la , por . para poder hacer operaciones
		$MT_PRES =~ s/,/./;
		$MT_IMPAGO =~ s/,/./;
		$MT_INDE =~ s/,/./;
		$MT_INNODE =~ s/,/./;
		$MT_DEB =~ s/,/./;
		
		# PRES_ID es el codigo de prestamo
		#%PPImpagos{$PRES_ID} = (MT_PRES => $MT_PRES, MT_IMPAGO => $MT_IMPAGO, MT_INDE => $MT_INDE, MT_INNODE => $MT_INNODE, MT_DEB => $MT_DEB)
		%PPImpagos{$PRES_ID} = (PAIS_ID => $PAIS_ID, SIS_ID => $SIS_ID, CTB_ANIO => $CTB_ANIO, CTB_MES => $CTB_MES, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO);
		$PPImpagos{$PRES_ID}{MT_PRES} = $MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB;
	
		# [DEBUG]
		print "Debug: MT_REST_MAESTRO: $PPImpagos{$PRES_ID}{MT_PRES}\n";
		
	}
		close(MAESTRO);

	return %PPImpagos;
}

sub Obtener_PPais
{
	### Para que funcione hay que tener estos archivos en el directorio donde estoy

		($archivo_prestamos) = "$ENV{HOME}/Grupo4/$ENV{exDIR_PROCESS}/PRESTAMOS.Argentina";
	print "Nombre de archivos: $archivo_prestamos \n";
	open(PRESTAMOS, "<$archivo_prestamos") || die "ERROR: no se pudo abrir el archivo $archivo_prestamos";

	my %PPais;
			while ($linea = <PRESTAMOS>)
	{
		($SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_ID, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB, $MT_REST, $PRES_CLI_ID, $PRES_CLI, $FECHA_GRAB, $USU_GRAB) = split(";", $linea);
		$MT_REST =~ s/,/./;
		
		%PPais{$PRES_ID} = (SIS_ID => $SIS_ID, CTB_ANIO => $CTB_ANIO, CTB_MES => $CTB_MES, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO);

		# [DEBUG]
		print "Debug: MT_REST: $MT_REST\n";
	}
	
	close(PRESTAMOS);
	return %PPais;
}

sub Mostrar_Listado
{
	# Muestra el listado a partir del hash previamente generado
	# Si se llamo al script con opcion -g, ademas lo guarda en un archivo
}

sub Generar_Recomendacion
{
	# Devuelve los prestamos que pudieron compararse en un hash cuya clave es PRES_ID
	# Tambien guarda RECAL o NORECAL para la recomendacion
}

sub Generar_Recomendacion
{
	local %PPImpagos = &Obtener_PPImpagos;
	local %PPais = &Obtener_PPais;

	%PComparados = &Comparar_Prestamos

	&Mostrar_Listado
}

sub Gestionar_Parametros
{
	my %parametros = ();
	getopts('ag', \%parametros) or die Mostrar_Ayuda();
    if (defined $parametros{a})
    {
        Mostrar_Ayuda();
        die "";
    }
}

sub Verificar_Ambiente
{
	my $ambienteOK = $ENV{exINIT_OK};
	die "El ambiente no esta inicializado. No se puede continuar." if $ambienteOK != 1;
}

sub Mostrar_Menu
{
	print "Bienvenido al sistema de reportes Elija el tipo de reporte que desea realizar:\n";
	print "(1) - Recomendacion.\n";
	print "(2) - Listar Divergencias en porcentaje.\n";
	print "(3) - Listar Divergencias en monto.\n";
	
}

system("clear");

&Gestionar_Parametros;
&Verificar_Ambiente;
&Cargar_Metadatos;

&Mostrar_Menu;
&Generar_Recomendacion;
