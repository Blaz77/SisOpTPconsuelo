#!/usr/bin/perl

use Getopt::Std;
my %PAISES;
my %SISTEMAS;
my $DIR_REPORTES;
my $DIR_LOGS;
my $DIR_PROC;
my $DIR_MAE;
my $GRUPO = "$ENV{HOME}/Grupo4";

my $PARAM_PAIS_ID;
my $PARAM_SIS_ID;

sub Mostrar_Ayuda{
	print "\n",
		"Modo de uso:\n",
		"  ReportO.pl <pais> [<sistema>] [<periodo>] [-a | -g]\n",
		"\n",
		"Condiciones de ejecucion:\n",
		"  El sistema debe estar inicializado\n",
		"\n",
		"Argumentos:\n",
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
	$DIR_REPORTES = $ENV{exDIR_REPORTS};
	$DIR_LOGS = $ENV{exDIR_LOGS};
	$DIR_PROC = $ENV{exDIR_PROCESS};
	$DIR_MAE = $ENV{exDIR_MASTER};
	
	($archivo_pais_sistema) = "$DIR_MAE/p-s.mae";

	open(PYS, "<$archivo_pais_sistema") || die "ERROR: no se pudo abrir el archivo $archivo_pais_sistema";
	while ($linea = <PYS>)
	{
		($PAIS_ID, $PAIS_DESC, $SIS_ID, $SIS_DESC) = split("-", $linea);
		
		if (! exists ($PAISES{$PAIS_ID})) {
			$PAISES{$PAIS_ID} = $PAIS_DESC;
		}
		
		if (! exists ($SISTEMAS{$SIS_ID})) {
			$SISTEMAS{$SIS_ID} = $SIS_DESC;
		}
		
	}
	close(MAESTRO);
	
	# [DEBUG]
	print "Debug: PAISES: %PAISES\n";
	print "Debug: SISTEMAS: %SISTEMAS\n";
}

sub Obtener_PPImpagos
{
	($archivo_maestro) = "$DIR_MAE/PPI.mae";
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
		
		# Tomo solamente el que voy a usar para la recomendacion (Mayor dia )
		if (! exists (%PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}) or $PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{CTB_DIA} < $CTB_DIA) {
			%PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES} = (PAIS_ID => $PAIS_ID, SIS_ID => $SIS_ID, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO);
			$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{MT_PRES} = $MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB;
		}
		# [DEBUG]
		print "Debug: MT_REST_MAESTRO: $PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{MT_PRES}\n";
		
	}
	close(MAESTRO);

	return %PPImpagos;
}

sub Obtener_PPais
{
	### Para que funcione hay que tener estos archivos en el directorio donde estoy
	($archivo_prestamos) = "$DIR_PROC/PRESTAMOS." . "$PAISES{$PARAM_PAIS_ID}";
	
	print "Nombre de archivos: $archivo_prestamos \n";
	open(PRESTAMOS, "<$archivo_prestamos") || die "ERROR: no se pudo abrir el archivo $archivo_prestamos";

	my %PPais;
	while ($linea = <PRESTAMOS>)
	{
		($SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_ID, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB, $MT_REST, $PRES_CLI_ID, $PRES_CLI, $FECHA_GRAB, $USU_GRAB) = split(";", $linea);
		$MT_REST =~ s/,/./;
		$FECHA_GRAB =~ s?(\d{2})/(\d{2})/(\d{4})?$3$2$1?;
		
		# Tomo solamente el que voy a usar para la recomendacion (Mayor dia, mayor fecha de grabacion)
		if (! exists (%PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}) or $PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{CTB_DIA} < $CTB_DIA || $PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{FECHA_GRAB} < $FECHA_GRAB) {
			%PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES} = (SIS_ID => $SIS_ID, CTB_ANIO => $CTB_ANIO, CTB_MES => $CTB_MES, CTB_DIA => $CTB_DIA, CTB_ESTADO => $CTB_ESTADO, MT_REST => $MT_REST, FECHA_GRAB => $FECHA_GRAB);
		}
		
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

# Devuelve los prestamos que pudieron compararse en arreglo de prestamos
# Tambien guarda RECAL o NORECAL para la recomendacion
sub Comparar_Prestamos
{
	my @PComparados;
	foreach $PRES_ID (keys(%PPImpagos)) {
		if (! exists (%PPais{$PRES_ID})) {
			next;
		}
		foreach $CTB_ANIO (keys(%PPImpagos{$PRES_ID})) {
			if (! exists (%PPais{$PRES_ID}{$CTB_ANIO})) {
				next;
			}
			foreach $CTB_MES (keys(%PPImpagos{$PRES_ID}{$CTB_ANIO}) {
				if (! exists (%PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES})) {
					next;
				}
				%DatosMaestro = %PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES};
				%DatosPrestamo = %PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES};
				
				if ($DatosMaestro{CTB_ESTADO} == "SMOR" and $DatosPrestamo{CTB_ESTADO} != "SMOR") {
					$RECO = "RECAL";
				}
				elsif ($DatosMaestro{MT_REST} < $DatosPrestamo{MT_REST}) {
					$RECO = "RECAL";
				}
				else {
					$RECO = "NORECAL";
				}
				
				$DIF = $DatosMaestro{MT_REST} - $DatosPrestamo{MT_REST};
				%DatosComparado = (PAIS => $PARAM_PAIS_ID, SISID => $DatosMaestro{SIS_ID}, PRESID => $PRES_ID, RECO => $RECO, M.ESTADO => $DatosMaestro{CTB_ESTADO}, P.ESTADO => $DatosPrestamo{CTB_ESTADO}, M.REST => $DatosMaestro{MT_REST}, P.REST => $DatosPrestamo{MT_REST}, DIF => $DIF, ANIO => $CTB_ANIO, MES => $CTB_MES, M.DIA => $DatosMaestro{CTB_DIA}, P.DIA => $DatosPrestamo{CTB_DIA});
				push(@PComparados %DatosComparado);
			}
		}
	}
}

sub Reportar_Recomendacion
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
	
	$PARAM_PAIS_ID = "A";
}

system("clear");

&Gestionar_Parametros;
&Verificar_Ambiente;
&Cargar_Metadatos;

&Mostrar_Menu;
&Reportar_Recomendacion;
