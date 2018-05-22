#!/usr/bin/perl

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

sub leerArchivos
{
	### Para que funcione hay que tener estos archivos en el directorio donde estoy
	($archivo_prestamos) = "PRESTAMOS.Argentina";
	($archivo_maestro) = "PPI.mae";
	print "Nombre de los archivos: $archivo_prestamos, $archivo_maestro \n";

	open(PRESTAMOS, "<$archivo_prestamos") || die "ERROR: no se pudo abrir el archivo $archivo_prestamos";
	open(MAESTRO, "<$archivo_maestro") || die "ERROR: no se pudo abrir el archivo $archivo_maestro";

	while ($linea = <MAESTRO>)
	{
		@arreglo = split(";", $linea);
		### A cada monto le reemplazo la , por . para poder hacer operaciones
		$arreglo[9] =~ s/,/./;
		$arreglo[10] =~ s/,/./;
		$arreglo[11] =~ s/,/./;
		$arreglo[12] =~ s/,/./;
		$arreglo[13] =~ s/,/./;
		
		$hash{"MT_PRES"} = $arreglo[9];
		$hash{"MT_IMPAGO"} = $arreglo[10];
		$hash{"MT_INDE"} = $arreglo[11];
		$hash{"MT_INNODE"} = $arreglo[12];
		$hash{"MT_DEB"} = $arreglo[13];
	
		$MT_REST_MAESTRO = $hash{"MT_PRES"} + $hash{"MT_IMPAGO"} + $hash{"MT_INDE"} + $hash{"MT_INNODE"} - $hash{"MT_DEB"};
		print "MT_REST_MAESTRO: $MT_REST_MAESTRO\n";
	}

	print "\n";

	while ($linea = <PRESTAMOS>)
	{
		@arreglo = split(";", $linea);	
		$arreglo[11] =~ s/,/./;
		$MT_REST_PRESTAMOS = $arreglo[11];
		print "MT_REST_PRESTAMOS: $MT_REST_PRESTAMOS\n";
	}
	
	close(PRESTAMOS);
	close(MAESTRO);
}

sub Gestionar_Parametros
{
	my %parametros = ();
	getopts('ag', \%parametros) or die Mostrar_Ayuda();

	Mostrar_Ayuda() if defined $parametros{a};
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
&Mostrar_Menu;
&leerArchivos;
