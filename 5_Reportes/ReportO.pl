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
	$Metadatos{"A"}{"6"}{"SEP_CAMP"} = ";";
	$Metadatos{"A"}{"6"}{"SEP_DEC"} = ";";
	$Metadatos{"A"}{"7"}{"SEP_CAMP"} = ";";
	$Metadatos{"A"}{"7"}{"SEP_DEC"} = ";";
}

sub leerArchivos
{
	### Para que funcione hay que tener estos archivos en el directorio donde estoy
	($archivo_prestamos) = "$ENV{HOME}/Grupo4/$ENV{exDIR_PROCESS}/PRESTAMOS.Argentina";
	($archivo_maestro) = "$ENV{HOME}/Grupo4/$ENV{exDIR_MASTER}/PPI.mae";
	print "Nombre de los archivos: $archivo_prestamos, $archivo_maestro \n";

	open(PRESTAMOS, "<$archivo_prestamos") || die "ERROR: no se pudo abrir el archivo $archivo_prestamos";
	open(MAESTRO, "<$archivo_maestro") || die "ERROR: no se pudo abrir el archivo $archivo_maestro";

	while ($linea = <MAESTRO>)
	{
		($PAIS_ID, $SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_FE, $PRES_ID, $PRES_TI, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB) = split(";", $linea);
		
		# A cada monto le reemplazo la , por . para poder hacer operaciones
		my $SEP_DEC = $Metadatos{$PAIS_ID}{$SIS_ID}{SEP_DEC}
		$MT_PRES =~ s/$SEP_DEC/./;
		$MT_IMPAGO =~ s/$SEP_DEC/./;
		$MT_INDE =~ s/$SEP_DEC/./;
		$MT_INNODE =~ s/$SEP_DEC/./;
		$MT_DEB =~ s/$SEP_DEC/./;
		
		# PRES_ID es el codigo de prestamo
		#%PPImpagos{$PRES_ID} = (MT_PRES => $MT_PRES, MT_IMPAGO => $MT_IMPAGO, MT_INDE => $MT_INDE, MT_INNODE => $MT_INNODE, MT_DEB => $MT_DEB)
		%PPImpagos{$PRES_ID} = (PAIS_ID => $PAIS_ID, SIS_ID => $SIS_ID, CTB_ANIO => $CTB_ANIO, CTB_MES => $CTB_MES, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO);
		$PPImpagos{$PRES_ID}{MT_PRES} = $MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB;
	
		# [DEBUG]
		print "Debug: MT_REST_MAESTRO: $PPImpagos{$PRES_ID}{MT_PRES}\n";
		
	}

	print "\n";

	while ($linea = <PRESTAMOS>)
	{
		($SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_ID, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB, $MT_REST, $PRES_CLI_ID, $PRES_CLI, $FECHA_GRAB, $USU_GRAB) = split(";", $linea);
		$MT_REST =~ s/$SEP_DEC/./;
		
		%PPais{$PRES_ID} = (SIS_ID => $SIS_ID, CTB_ANIO => $CTB_ANIO, CTB_MES => $CTB_MES, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO);

		# [DEBUG]
		print "Debug: MT_REST: $MT_REST\n";
	}
	
	close(PRESTAMOS);
	close(MAESTRO);
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
&leerArchivos;
