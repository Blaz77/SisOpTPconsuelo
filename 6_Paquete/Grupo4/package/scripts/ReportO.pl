#!/usr/bin/perl

#DEBUG
use Data::Dumper;

use Getopt::Std;
my $flagGuardar = 0;
my %PAISES;
my %SISTEMAS;
my $DIR_GRUPO = "$ENV{HOME}/Grupo4";
my $DIR_REPORTES;
my $DIR_LOGS;
my $DIR_PROC;
my $DIR_MAE;
my $maestro_pais_sistema;
my $maestro_impagos;
my $anio_actual = (localtime)[5] + 1900;

# Opciones ingresadas
my $Continuar = "S";
my $Reporte;
my $paramPais;
my $paramSistema;
my $paramPeriodo;
my $paramPorcentaje;

sub DEBUG_print_dic
{
	print Dumper( $_[0] )
}

sub Mostrar_Ayuda{
	print "\n",
		"Modo de uso:\n",
		"  ReportO.pl [-a | -g] \n",
		"\n",
		"Condiciones de ejecucion:\n",
		"  El sistema debe estar inicializado\n",
		"\n",
		"Parametros:\n",
		"\n",
		"  -g       Si se define, se guardan los resultados en un archivo.\n",
		"           En caso contrario, solo se muestra por pantalla.\n",
		"  -a       Muestra esta ayuda\n",
		"\n",
		"Al iniciar, se le solicitara el reporte que desea realizar junto a los argumentos \n",
		"necesarios. Algunos de ellos son opcionales y puede dejarlos en blanco.\n",
		"Se cuenta con 3 reportes disponibles.\n\n",
		"  1. Recomendacion: Compara los prestamos impagos respecto a los prestamos por pais \n",
		"         y genera un listado de recomendacion basado en el estado contable y la \n",
		"         diferenca entre los montos restantes. Si se ejecuta con -g se guardan los\n",
		"         resultados en Comparado.<Pais>.\n",
		"  2. Divergencias en porcentaje (Requiere Recomendacion): Muestra un listado de prestamos\n",
		"         comparados previamente filtrando aquellos cuya diferencia porcentual en valor\n",
		"         absoluto supere un valor X solicitado.\n",
		"  3. Divergencia en monto (Requiere Recomendacion): Muestra un listado de prestamos\n",
		"         comparados previamente filtrando aquellos cuyo monto de diferencia en valor\n",
		"         absoluto supere un valor X solicitado.\n",
		"\n";
		exit;
}

sub Cargar_Parametros
{
	my %parametros = ();
	getopts('ag', \%parametros) or &Mostrar_Ayuda();
    if (defined $parametros{a})
    {
        Mostrar_Ayuda();
    }
	elsif (defined $parametros{g})
    {
        $flagGuardar = 1;
    }
}

sub Verificar_Ambiente
{
	my $ambienteOK = $ENV{exINIT_OK};
	die "El ambiente no esta inicializado. No se puede continuar." if $ambienteOK != 1;
}

sub Cargar_Metadatos
{
	$DIR_REPORTES = $ENV{exDIR_REPORTS};
	$DIR_LOGS = $ENV{exDIR_LOGS};
	$DIR_PROC = $ENV{exDIR_PROCESS};
	$DIR_MAE = $ENV{exDIR_MASTER};
	
	$maestro_pais_sistema = "$DIR_GRUPO/$DIR_MAE/p-s.mae";
	$maestro_impagos = "$DIR_GRUPO/$DIR_MAE/PPI.mae";

	open(PSH, "<$maestro_pais_sistema") || die "ERROR: no se pudo abrir el archivo $maestro_pais_sistema";
	while ($linea = <PSH>)
	{
		chomp($linea);
		($PAIS_ID, $PAIS_DESC, $SIS_ID, $SIS_DESC) = split("-", $linea);
		
		if (! exists ($PAISES{$PAIS_ID})) {
			$PAISES{$PAIS_ID} = $PAIS_DESC;
		}
		
		if (! exists ($SISTEMAS{$SIS_ID})) {
			$SISTEMAS{$SIS_ID} = $SIS_DESC;
		}
		
	}
	close(PSH);
	
	# [DEBUG]
	# print "SISTEMAS\n";
	# &DEBUG_print_dic(\%SISTEMAS);
	# print "PAISES\n";
	# &DEBUG_print_dic(\%PAISES);
}

sub Solicitar_Ingreso
{
	my($TextoSolicitud, $RegEx) = @_;
	
	print "$TextoSolicitud: ";
	my $input = <STDIN>; chomp($input);
	while (! ($input =~ $RegEx) )
	{
		print "Valor incorrecto. $TextoSolicitud: ";
		$input = <STDIN>; chomp($input);
	}
	
	return $input;
}

sub Solicitar_Ingreso_Periodo
{
	my $TextoSolicitud = "Ingrese el periodo de filtro (Desde-Hasta) con formato YYYYMM-YYYYMM\n(Dejar vacio para ignorar): ";
	my $valido = "0";
	my $input;
	while ($valido ne "1")
	{
		print "$TextoSolicitud";
		$input = <STDIN>; chomp($input);
		if ($input eq "")
		{
			$valido = "1";
			next;
		}
		
		if (! ($input =~ /^([0-9]{6}-[0-9]{6})?$/) )
		{
			print "Formato incorrecto.\n";
			next;
		}
		
		my($desde, $hasta) = split("-", $input);
		my $anio_desde = substr($desde, 0, 4);
		my $mes_desde = substr($desde, 4, 2);
		if ($anio_desde > $anio_actual || $anio_desde < 1900 || $mes_desde == 0 || $mes_desde > 12)
		{
			print "El valor de la fecha DESDE no es valido.\n";
			next;
		}
		
		my $anio_hasta = substr($hasta, 0, 4);
		my $mes_hasta = substr($hasta, 4, 2);
		if ($anio_hasta > $anio_actual || $anio_hasta < 1900 || $mes_hasta == 0 || $mes_hasta > 12)
		{
			print "El valor de la fecha HASTA no es valido.\n";
			next;
		}
		
		if ($desde > $hasta)
		{
			print "El valor de la fecha DESDE no puede ser mayor que HASTA.\n";
			next;
		}
		
		$valido = "1";
	}
	
	return $input;
}

sub Mostrar_Menu
{
	my $archivo_comparado = "$DIR_GRUPO/$DIR_REPORTES/Comparado." . "$PAISES{$paramPais}";
	my $RegEx;

	print "Elija el tipo de reporte que desea realizar:\n";
	print "(1) - Recomendacion.\n";
	if (-f $archivo_comparado)
	{
		print "(2) - Listar Divergencias en porcentaje.\n";
		print "(3) - Listar Divergencias en monto.\n\n";
		$RegEx = qr/^[1-3]$/;
	}
	else 
	{
		print "Algunas opciones se ocultaron. Para habilitarlas ejecute el reporte de Recomendacion con la opcion -g.\n\n";
		$RegEx = qr/^[1]$/;
	}
	
	$Reporte = Solicitar_Ingreso("Ingrese una opcion", $RegEx);
}

sub Obtener_PPImpagos
{
	open(MAESTRO, "<$maestro_impagos") || die "ERROR: no se pudo abrir el archivo $archivo_maestro";

	my %PPImpagos;
	while ($linea = <MAESTRO>)
	{
		chomp($linea);
		my($PAIS_ID, $SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_FE, $PRES_ID, $PRES_TI, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB) = split(";", $linea);
		$CTB_MES = sprintf("%02.0f", $CTB_MES);
		
		# Filtrado:
		if ($paramSistema ne "" and $paramSistema ne $SIS_ID)
		{
			next;
		}
		if ($paramPeriodo ne "")
		{
			my ($desde, $hasta) = split("-", $paramPeriodo);
			my $anio_mes = $CTB_ANIO . $CTB_MES;
			
			if ($anio_mes < $desde || $anio_mes > $hasta)
			{
				next;
			}
		}
		
		# A cada monto le reemplazo la , por . para poder hacer operaciones
		$MT_PRES =~ s/,/./;
		$MT_IMPAGO =~ s/,/./;
		$MT_INDE =~ s/,/./;
		$MT_INNODE =~ s/,/./;
		$MT_DEB =~ s/,/./;
		
		# PRES_ID es el codigo de prestamo
		if (! (exists($PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES})) or $PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_DIA"} < $CTB_DIA )
		{
			$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"SIS_ID"} = $SIS_ID;
			$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_DIA"} = $CTB_DIA;
			$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_ESTADO"} = $CTB_ESTADO;
			$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"MT_REST"} = sprintf("%.2f", $MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB);
		}
	}
	close(MAESTRO);
	
	return %PPImpagos;
}

sub Obtener_PPais
{
	my $archivo_prestamos = "$DIR_GRUPO/$DIR_PROC/PRESTAMOS." . "$PAISES{$paramPais}";
	
	open(PRESTAMOS, "<$archivo_prestamos") || die "ERROR: no se pudo abrir el archivo $archivo_prestamos";

	my %PPais;
	while ($linea = <PRESTAMOS>)
	{
		chomp($linea);
		($SIS_ID, $CTB_ANIO, $CTB_MES, $CTB_DIA, $CTB_ESTADO, $PRES_ID, $MT_PRES, $MT_IMPAGO, $MT_INDE, $MT_INNODE, $MT_DEB, $MT_REST, $PRES_CLI_ID, $PRES_CLI, $FECHA_GRAB, $USU_GRAB) = split(";", $linea);
		$MT_REST =~ s/,/./;
		$CTB_MES = sprintf("%02.0f", $CTB_MES);
		$FECHA_GRAB =~ s?(\d{2})/(\d{2})/(\d{4})?$3$2$1?;
		
		# Tomo solamente el que voy a usar para la recomendacion (Mayor dia, mayor fecha de grabacion)
		if (! (exists ($PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES})) or $PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_DIA"} < $CTB_DIA or $PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"FECHA_GRAB"} < $FECHA_GRAB) {
			$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"SIS_ID"} = $SIS_ID;
			$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_DIA"} = $CTB_DIA;
			$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"CTB_ESTADO"} = $CTB_ESTADO;
			$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"MT_REST"} = $MT_REST;
			$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}{"FECHA_GRAB"} = $FECHA_GRAB;
		}
	}
	
	close(PRESTAMOS);
	return %PPais;
}

# Devuelve los prestamos que pudieron compararse en arreglo de prestamos
# Tambien guarda RECAL o NORECAL para la recomendacion
sub Comparar_Prestamos
{
	my @PComparados;
	
	foreach $PRES_ID (keys(%PPImpagos)) {
		if (! (exists ($PPais{$PRES_ID})) ) {
			next;
		}
		foreach $CTB_ANIO (keys %{$PPImpagos{$PRES_ID}}) {
			if (! (exists ($PPais{$PRES_ID}{$CTB_ANIO})) ) {
				next;
			}
			foreach $CTB_MES (keys %{$PPImpagos{$PRES_ID}{$CTB_ANIO}}) {
				if (! (exists ($PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES})) ) {
					next;
				}
				
				%DatosMaestro = %{$PPImpagos{$PRES_ID}{$CTB_ANIO}{$CTB_MES}};
				%DatosPrestamo = %{$PPais{$PRES_ID}{$CTB_ANIO}{$CTB_MES}};
				
				if ($DatosMaestro{"CTB_ESTADO"} eq "SMOR" and $DatosPrestamo{"CTB_ESTADO"} ne "SMOR") {
					$RECO = "RECAL";
				}
				elsif ($DatosMaestro{"MT_REST"} < $DatosPrestamo{"MT_REST"}) {
					$RECO = "RECAL";
				}
				else {
					$RECO = "NORECAL";
				}
				
				$DIF = sprintf("%.2f", $DatosMaestro{"MT_REST"} - $DatosPrestamo{"MT_REST"});
				my %DatosComparado = ("PAIS" => $paramPais, "SISID" => $DatosMaestro{"SIS_ID"}, "PRESID" => $PRES_ID, "RECO" => $RECO, "M.ESTADO" => $DatosMaestro{"CTB_ESTADO"}, "P.ESTADO" => $DatosPrestamo{"CTB_ESTADO"}, "M.REST" => $DatosMaestro{"MT_REST"}, "P.REST" => $DatosPrestamo{"MT_REST"}, "DIF" => $DIF, "ANIO" => $CTB_ANIO, "MES" => $CTB_MES, "M.DIA" => $DatosMaestro{"CTB_DIA"}, "P.DIA" => $DatosPrestamo{"CTB_DIA"});
				push(@PComparados, \%DatosComparado);

				# [DEBUG]
				# print "Maestro\n";
				# &DEBUG_print_dic(\%DatosMaestro);
				# print "Prestamo\n";
				# &DEBUG_print_dic(\%DatosPrestamo);
				# print "Comparado\n";
				# &DEBUG_print_dic(\%DatosComparado);}
			}
		}
	}
	# print "Array Comparado\n";
	# &DEBUG_print_dic(\@PComparados);			
	
	return @PComparados;
}

sub Mostrar_Datos_Consulta
{
	print "---------------------------------------------------------------------\n";
	print "Datos de la consulta:\n";
	print "PAIS: $paramPais ($PAISES{$paramPais})\n";
	
	if ($paramSistema ne "")
	{
		print "SISTEMA: $paramSistema ($SISTEMAS{$paramSistema})\n"; 
	}
	else
	{
		print "SISTEMA: Sin definir\n";
	}
	if ($paramPeriodo ne "")
	{
		print "PERIODO: $paramPeriodo\n"; 
	}
	else
	{
		print "PERIODO: Sin definir\n";
	}
	if ($paramPorcentaje ne "")
	{
		print "Porcentaje minimo de diferencia: $paramPorcentaje\%\n"; 
	}
	if ($paramMonto ne "")
	{
		print "Monto minimo de diferencia: \$ $paramMonto\n"; 
	}
	print "---------------------------------------------------------------------\n";
}

# Muestra el listado a partir del array previamente generado
# Si se llamo al script con opcion -g, ademas lo guarda en un archivo
sub Mostrar_Listado
{
	my $encabezado = "PAIS;SISID;PRESID;RECO;M.ESTADO;P.ESTADO;M.REST;P.REST;DIF;ANIO;MES;M.DIA;P.DIA";
	
	print "\n";
	&Mostrar_Datos_Consulta();
	print "$encabezado\n";
	foreach $Registro (@PComparados) {
		print %$Registro{"PAIS"} . ";" . %$Registro{"SISID"} . ";" . %$Registro{"PRESID"} . ";" . %$Registro{"RECO"} . ";" . %$Registro{"M.ESTADO"} . ";" . %$Registro{"P.ESTADO"} . ";" . %$Registro{"M.REST"} . ";" . %$Registro{"P.REST"} . ";" . %$Registro{"DIF"} . ";" . %$Registro{"ANIO"} . ";" . %$Registro{"MES"} . ";" . %$Registro{"M.DIA"} . ";" . %$Registro{"P.DIA"} . "\n";
	}
	
    if ($flagGuardar == 1)
    {
		$archivo_recomendacion = "$DIR_GRUPO/$DIR_REPORTES" . "/" . "Comparado." . $PAISES{$paramPais};
		open(SALIDA, ">>$archivo_recomendacion") || die "ERROR: no se pudo guardar el archivo $archivo_recomendacion";
		
		foreach $Registro (@PComparados) {
			print SALIDA %$Registro{"PAIS"} . ";" . %$Registro{"SISID"} . ";" . %$Registro{"PRESID"} . ";" . %$Registro{"RECO"} . ";" . %$Registro{"M.ESTADO"} . ";" . %$Registro{"P.ESTADO"} . ";" . %$Registro{"M.REST"} . ";" . %$Registro{"P.REST"} . ";" . %$Registro{"DIF"} . ";" . %$Registro{"ANIO"} . ";" . %$Registro{"MES"} . ";" . %$Registro{"M.DIA"} . ";" . %$Registro{"P.DIA"} . "\n";
		}
		
		close (SALIDA);
    }
}

# Muestra el listado a partir del hash previamente generado
# Si se llamo al script con opcion -g, ademas lo guarda en un archivo
sub Mostrar_Listado_Divergencia
{
	my $tipo = $_[0];
	my $encabezado = "PAIS;SISID;PRESID;RECO;M.REST;P.REST;DIF;DIF_PORC";
	
	print "\n";
	&Mostrar_Datos_Consulta();
	print "$encabezado\n";
	foreach $Registro (@PListados) {
		my $linea = join(";", @$Registro);
		print "$linea\n";
	}
	
    if ($flagGuardar == 1)
    {
		$nombre_archivo = &Obtener_nombre_incremental("$DIR_GRUPO/$DIR_REPORTES", "$tipo.$PAISES{$paramPais}");
		$archivo_divergencia = "$DIR_GRUPO/$DIR_REPORTES" . "/" . "$nombre_archivo";
		open(SALIDA, ">$archivo_divergencia") || die "ERROR: no se pudo guardar el archivo $archivo_divergencia";
		
		foreach $Registro (@PListados) {
			my $linea = join(";", @$Registro);
			print SALIDA "$linea\n";
		}
		
		close (SALIDA);
    }
}

sub Obtener_nombre_incremental
{
	my($ruta, $nombre_base) = @_;
	
	my $i = 1;
	my $nombre = "$i"."_$nombre_base";
	while (-e "$ruta/$nombre") {
		$i++;
		$nombre = "$i"."_$nombre_base";
	}
	
	return $nombre;
}

sub Solicitar_Filtros_Generales
{
	$paramSistema = Solicitar_Ingreso("Ingrese codigo de sistema (Dejar vacio para ignorar)", qr/^[0-9]?$/);
	if ( $paramSistema ne "" && !(exists($SISTEMAS{$paramSistema})) )
	{
		print "No se encontro el sistema solicitado\n";
		return 0;
	}
	$paramPeriodo = &Solicitar_Ingreso_Periodo();
	return 1;
}

sub Reporte_Recomendacion
{
	&Solicitar_Filtros_Generales() || return;
	
	local %PPImpagos = &Obtener_PPImpagos();
	local %PPais = &Obtener_PPais();
	
	local @PComparados = &Comparar_Prestamos();
	&Mostrar_Listado();
	# [DEBUG]
	# print "IMPAGOS\n";
	# &DEBUG_print_dic(\%PPImpagos);
	# print "PRESTAMOS.PAIS\n";
	# &DEBUG_print_dic(\%PPais);
}

sub Reporte_Divergencia_Porcentaje
{
	&Solicitar_Filtros_Generales() || return;
	
	$paramPorcentaje = Solicitar_Ingreso("Ingrese porcentaje de referencia entre 1 y 100 (Dejar vacio para cancelar consulta)", qr/^0*(?:[1-9][0-9]?|100)$/);
	if ( $paramPorcentaje eq "" )
	{
		return;
	}
	
	my $archivo_comparado = "$DIR_GRUPO/$DIR_REPORTES/Comparado." . "$PAISES{$paramPais}";
	
	open(COMPARADO, "<$archivo_comparado") || die "ERROR: no se pudo abrir el archivo $archivo_comparado";
	
	local @PListados;
	while ($linea = <COMPARADO>)
	{
		chomp($linea);
		my($PAIS, $SISID, $PRESID, $RECO, $M_ESTADO, $P_ESTADO, $M_REST, $P_REST, $DIF, $ANIO, $MES, $M_DIA, $P_DIA) = split(";", $linea);
		
		# Filtrado:
		if ($paramSistema ne "" and $paramSistema ne $SISID)
		{
			next;
		}
		if ($paramPeriodo ne "")
		{
			my ($desde, $hasta) = split("-", $paramPeriodo);
			my $anio_mes = $ANIO . $MES;
			
			if ($anio_mes < $desde || $anio_mes > $hasta)
			{
				next;
			}
		}
		
		my $DIF_PORC;
		if ($M_REST == 0) {
			$DIF_PORC = sprintf("%2.0f", abs($DIF * 100 / 0.01));
		} else {
			$DIF_PORC = sprintf("%2.0f", abs($DIF * 100 / $M_REST));
		}
		if ($DIF_PORC >= $paramPorcentaje)
		{
			push(@PListados, [ $PAIS, $SISID, $PRESID, $RECO, $M_REST, $P_REST, abs($DIF), abs($DIF_PORC) ]);
		}
	}
	close(COMPARADO);
	
	&Mostrar_Listado_Divergencia("Div_Porcentaje");
}

sub Reporte_Divergencia_Monto
{
	&Solicitar_Filtros_Generales() || return;
	
	$paramMonto = Solicitar_Ingreso("Ingrese monto entero de referencia (Dejar vacio para cancelar consulta)", qr/^(0*[1-9][0-9]*)?$/);
	if ( $paramMonto eq "" )
	{
		return;
	}
	
	my $archivo_comparado = "$DIR_GRUPO/$DIR_REPORTES/Comparado." . "$PAISES{$paramPais}";
	
	open(COMPARADO, "<$archivo_comparado") || die "ERROR: no se pudo abrir el archivo $archivo_comparado";
	
	local @PListados;
	while ($linea = <COMPARADO>)
	{
		chomp($linea);
		my($PAIS, $SISID, $PRESID, $RECO, $M_ESTADO, $P_ESTADO, $M_REST, $P_REST, $DIF, $ANIO, $MES, $M_DIA, $P_DIA) = split(";", $linea);
		
		# Filtrado:
		if ($paramSistema ne "" and $paramSistema ne $SISID)
		{
			next;
		}
		if ($paramPeriodo ne "")
		{
			my ($desde, $hasta) = split("-", $paramPeriodo);
			my $anio_mes = $ANIO . $MES;
			
			if ($anio_mes < $desde || $anio_mes > $hasta)
			{
				next;
			}
		}
		
		my $DIF_PORC;
		if ($M_REST == 0) {
			$DIF_PORC = sprintf("%2.0f", abs($DIF * 100 / 0.01));
		} else {
			$DIF_PORC = sprintf("%2.0f", abs($DIF * 100 / $M_REST));
		}
		if (abs($DIF) > $paramMonto)
		{
			push(@PListados, [ $PAIS, $SISID, $PRESID, $RECO, $M_REST, $P_REST, abs($DIF), abs($DIF_PORC) ]);
		}
	}
	close(COMPARADO);
	
	&Mostrar_Listado_Divergencia("Div_Monto");
}

&Cargar_Parametros();
&Verificar_Ambiente;
&Cargar_Metadatos();

print "Bienvenido al sistema de reportes.\n";
$paramPais = Solicitar_Ingreso("Ingrese codigo de pais para comenzar (Obligatorio)", qr/^[A-Z]$/);
if (! (exists($PAISES{$paramPais})) )
{
	print "No se encontro el pais solicitado. Consulta cancelada.\n";
	exit;
}
	
while ($Continuar eq "S")
{
	$paramPorcentaje = "";
	$paramMonto = "";
	
	&Mostrar_Menu();

	if ($Reporte eq "1")
	{
		&Reporte_Recomendacion();
	}
	elsif($Reporte eq "2")
	{
		&Reporte_Divergencia_Porcentaje();
	}
	elsif($Reporte eq "3")
	{
		&Reporte_Divergencia_Monto();
	}
	
	print "\n";
	$Continuar = &Solicitar_Ingreso("Desea realizar otra consulta? (S-N)", qr/^[sSnN]$/);
	$Continuar =~ s/s/S/;
}

