#!/usr/bin/perl

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



system("clear");

my $ambienteOK = $ENV{exINIT_OK}
die "El ambiente no esta inicializado. No se puede continuar." if $ambienteOK != 1;

print "Bienvenido al sistema de reportes Elija el tipo de reporte que desea realizar:\n";
print "(1) - Recomendacion.\n";
print "(2) - Listar Divergencias en porcentaje.\n";
print "(3) - Listar Divergencias en monto.\n";

&leerArchivos;
