#!/bin/perl

use feature qw(switch);
no warnings 'experimental';

use Getopt::Std;

$NAME_FILE_MAESTRO = "PPI.mae";

#$PATH_MAESTRO = "$DIR_MAE\$NAME_FILE_MAESTRO";

#DEBUG borrar es solo para debug sin ambiente
$PATH_MAESTRO = $NAME_FILE_MAESTRO;

#HASH
%CONTABLE_PPI;

%MONTO_RESTANTE_PPI; #Este hash tiene como clave: codigo de prestamo, y valor: monto restante calculado

%LINEAS_PRESTAMOS; #Hash que contiene las líneas del archivo préstamos que coinciden con préstamo, año y mes del hash de maestros %CONTABLE_PPI

my %SISTEMAS;
my $DIR_REPORTES;
my $DIR_LOGS;
my $DIR_PROC;
my $DIR_MAE;

my $GRUPO = "$ENV{HOME}/Grupo4";

my $PARAM_PAIS_ID;
my $PARAM_SIS_ID;

my $DebeGuardarSalida;
my $Estado_Contable;
my $Diferencia_Montos;

sub Gestionar_Parametros
{
	$num_args = $#ARGV + 1;

  	given($num_args)
  	{
    	when(0) { print "Debe ingresar al menos un argumento \n"; }
    	when(1)
    	{
      		given($ARGV[0])
      		{
        		when("-a") { Mostrar_Ayuda(); }
        		when("-g") { print "Debe ingresar un filtro para poder grabar la salida \n"; }
        		default { Recomendacion_Cod_Pais($ARGV[0]); }
        	}
      	}
    	when(2) { RealizarRecomendacion2($ARGV[0],$ARGV[1]); }
    	when(3) { RealizarRecomendacion3($ARGV[0],$ARGV[1],$ARGV[2]); }
    	when(4) { RealizarRecomendacion4($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3]); }
    	default { print "El ingreso maximo de parametros es 4. \n";  }
	}
}

sub CalcularMontoRestante
{
	foreach $pres_id (keys(%CONTABLE_PPI))
	{
		@campos = split(";", $CONTABLE_PPI{"$pres_id"});
		$anio_contable = $campos[2];
		$mes_contable = $campos[3];
		if ($mes_contable < 10)
		{
			#A los meses por ejemplo "5" los cambio por "05" para poder comparar con el otro archivo
			$mes_contable = "0".$mes_contable;
		}
		$monto_prestamo = $campos[9];
		$monto_impago = $campos[10];
		$monto_devengado = $campos[11];
		$monto_no_devengado = $campos[12];
		$monto_debitado = $campos[13];

		$monto_restante = $monto_prestamo + $monto_impago + $monto_devengado + $monto_no_devengado - $monto_debitado;
		$MONTO_RESTANTE_PPI{"$pres_id"} = $monto_restante;
		#print "Montos: $monto_prestamo + $monto_impago + $monto_devengado + $monto_no_devengado - $monto_debitado";
		#print "Restante: $monto_restante\n";
		#$valor = $CONTABLE_PPI{"$pres_id"};
		#print "Valor maestro $valor\n";

	}
}

sub Comparar
{
	open(PRESTAMOS, "<PRESTAMOS.Argentina") || die "ERROR: no se pudo abrir el archivo PRESTAMOS.Argentina";
	while ($linea = <PRESTAMOS>)
	{
		@campos_prestamos = split(";", $linea);
		$anio_contable_prestamos = $campos_prestamos[1];
		$mes_contable_prestamos = $campos_prestamos[2];
		$dia_contable_prestamos = $campos_prestamos[3];
		$pres_id_prestamos = $campos_prestamos[5];
		$fecha_grabacion = $campos_prestamos[14];
		$monto_restante_prestamos = $campos_prestamos[11];
		$monto_restante_prestamos =~ s/,/./;

		if exists($CONTABLE_PPI{"$pres_id_prestamos"})
		{
			 @campos = split(";", $CONTABLE_PPI{"$pres_id_prestamos"});
			 $anio_contable = $campos[2];
	 		 $mes_contable = $campos[3];
	 		 if ($mes_contable < 10)
	 	  	{
	 		  	#A los meses por ejemplo "5" los cambio por "05" para poder comparar con el otro archivo
	 		  	$mes_contable = "0".$mes_contable;
	 	   	}
				if ($anio_contable eq $anio_contable_prestamos and $mes_contable eq $mes_contable_prestamos)
				{
					if exists($LINEAS_PRESTAMOS{"$pres_id_prestamos"})
					{
						@campos_prestamos = split(";", $LINEAS_PRESTAMOS{"$pres_id_prestamos"});
						$dia_contable_actual_registrado = $campos_prestamos[3];
						$fecha_grabacion_actual_registrado = $campos_prestamos[14];

						if ($dia_contable_actual_registrado < $dia_contable_prestamos)
						{
							delete($LINEAS_PRESTAMOS{"$pres_id_prestamos"});
							$LINEAS_PRESTAMOS{"$pres_id_prestamos"} = "$linea";
						}
						else
						{
							if ($dia_contable_actual_registrado eq $dia_contable_prestamos and $fecha_grabacion_actual_registrado < $fecha_grabacion)
							{
								delete($LINEAS_PRESTAMOS{"$pres_id_prestamos"});
								$LINEAS_PRESTAMOS{"$pres_id_prestamos"} = "$linea";
							}
						}

					}
					else
					{
						$LINEAS_PRESTAMOS{"$pres_id_prestamos"} = "$linea";
					}
				}
		}
		#print "Monto restante préstamos: $monto_restante_prestamos\n";
		#print "$anio_contable_prestamos, $mes_contable_prestamos, $pres_id_prestamos, $monto_restante_prestamos\n";
	}
	close(PRESTAMOS);
}

sub Recomendar
{
	foreach $pres_id (keys(%CONTABLE_PPI))
	{
		#print "pres id $pres_id\n";
		$linea_ppi = $CONTABLE_PPI{"$pres_id"};
		@campos_ppi = split(";", $linea_ppi);
		$estado_ppi = $campos_ppi[5];
		$monto_rest_ppi = $MONTO_RESTANTE_PPI{"$pres_id"};

		if exists($LINEAS_PRESTAMOS{"$pres_id"})
		{
			$Estado_Contable="NO-RECAL"
			@campos_prestamos = split(";", $LINEAS_PRESTAMOS{"$pres_id"});
			$estado_prestamos = $campos_prestamos[4];
			$monto_restante_prestamos = $campos_prestamos[11];
			#print "estado ppi $estado_ppi, estado prestamos $estado_prestamos\n";
			#print "monto ppi $monto_rest_ppi, monto prestamos $monto_restante_prestamos\n";
			if ($linea_prestamos ne "")
			{
				if ($estado_ppi eq "SMOR" and $estado_prestamos ne "SMOR")
				{
					$Estado_Contable="RECAL";
				}
				if ($monto_rest_ppi < $monto_restante_prestamos)
				{
					$Estado_Contable="RECAL";
				}
		   }

			 $Diferencia_Montos= $monto_rest_ppi - $monto_restante_prestamos;

			 my $pais = $campos_ppi[0];
			 my $sisID = $campos_ppi[1];
			 print "PAIS; SISID; PRESID; RECO; M.ESTADO; P.ESTADO; M.REST; P.REST; DIF; ANIO; MES; M.DIA; P.DIA\n";

			 print "$pais; $sisID; $pres_id; $Estado_Contable; $estado_ppi; ; ; $Diferencia_Montos; ; ; ; \n ";
			}

	}
}

sub Recomendacion_Cod_Pais
{
	my $codigo_pais = @_[0];

	#DEBUG
	print "$codigo_pais" . "\n";

	print "Filtro PPI.mae por codigo de pais y cargo el hash \n";
	print "Realizar recomendacion por codigo de pais \n";

	open (Handler_maestro,"<$PATH_MAESTRO") || die "ERROR: No puedo abrir el fichero $PATH_MAESTRO \n";

	while ($linea=<Handler_maestro>)
	{
		#DEBUG
		#print $linea . "\n";

		($IdPais, $IdSistema, $Year, $Month, $Day, $Estado, $Date, $IdPrestamo, $TipoPrestamo, $MontoPrestamo, $MontoImpago, $MID, $MIND, $MontoDebitado) =
		split(";", $linea);

		if ($IdPais eq $codigo_pais) {

			$MontoPrestamo =~ s/,/./;
			$MontoImpago =~ s/,/./;
			$MID =~ s/,/./;
			$MIND =~ s/,/./;
			$MontoDebitado =~ s/,/./;

			#DEBUG
			print "$IdPais,$IdSistema,$Year,$Month,$Day,$Estado,$Date,$IdPrestamo,$TipoPrestamo,$MontoPrestamo,$MontoImpago,$MID,$MIND,$MontoDebitado";

			$CONTABLE_PPI{"$IdPrestamo"} = "$IdPais;$IdSistema;$Year;$Month;$Day;$Estado;$Date;$IdPrestamo;$TipoPrestamo;$MontoPrestamo;$MontoImpago;$MID;$MIND;$MontoDebitado";
		}
	}

	close (Handler_maestro);

	&CalcularMontoRestante;
	&Comparar;
	&Recomendar;
}

sub RealizarRecomendacion2
{
	if ( $ARGV[0] eq "-a")
    { print "La opcion -a no puede ir anidada con busquedas\n";  }
  else
    {	#print " RealizarRecomendacion 2 parametro \n";
			my($param1, $param2) = @_;
			print "parametro 1 $param1 , parametro 2 $param2\n";
			if ( $param1 eq "-g")
			{
				$DebeGuardarSalida=1;
				FiltrarMaestros1($param1);
			}
			else
			{
				FiltrarMaestros2($param1, $param2);
			}
		}
}

sub RealizarRecomendacion3
{
	#Filtrar PPI.mae segun parametros
	if ( $ARGV[0] eq "-a")
    { print "La opcion -a no puede ir anidada con busquedas\n";  }
  else
    { print " Filtrao de PPI.mae \n";
			print " RealizarRecomendacion 3 parametro \n";
			my($param1, $param2, $param3) = @_;
			print "parametro 1 $param1 , parametro 2 $param2 , parametro 3 $param3\n";
			if ( $param1 eq "-g")
			{
				$DebeGuardarSalida=1;
				FiltrarMaestros2($param2, $param3);
			}
			else
			{
				FiltrarMaestros3($param1, $param2, $param3);
			}
		}
}

sub RealizarRecomendacion4
{
	#Filtrar PPI.mae segun parametros
	if ( $ARGV[0] eq "-a")
    { print "La opcion -a no puede ir anidada con busquedas\n";  }
  else
    { print " Filtrao de PPI.mae \n";
			print " RealizarRecomendacion 4 parametro \n";
			my($param1, $param2, $param3, $param4) = @_;
			print "parametro 1 $param1 , parametro 2 $param2 , parametro 3 $param3, parametro 4 $param4\n";
			#En este caso sabemos que el parametro 1 tiene que ser si o si -g. Sino tendria un parametro de mas
			if ( $param1 eq "-g")
			{
				$DebeGuardarSalida=1;
				FiltrarMaestros3($param2, $param3, $param4);
			}
			else
			{
				print "Los parametros ingresados no son validos, hay un parametro de mas.\n"
			}
		}
}

sub FiltrarMaestros1()
{
	#Recordar verificar si la opcion $DebeGuardarSalida
	print "Filtrar por 1 parametro.\n";
}

sub FiltrarMaestros2()
{
	#Recordar verificar si la opcion $DebeGuardarSalida
		print "Filtrar por 2 parametro.\n";
}

sub FiltrarMaestros3()
{
	#Recordar verificar si la opcion $DebeGuardarSalida
		print "Filtrar por 3 parametro.\n";
}

sub Mostrar_Ayuda{
	print "\n",
		"Modo de uso:\n",
		"  ReportO.pl [-a | -g] <pais> [<sistema>] [<periodo>] \n",
		"\n",
		"Condiciones de ejecucion:\n",
		"  El sistema debe estar inicializado\n",
		"\n",
		"Argumentos:\n",
		"  -a		Muestra esta ayuda\n",
		"  -g		Si se define, se guardan los resultados en un archivo.\n",
		"			En caso contrario, se muestra por pantalla.\n",
		"\n",
		"  <pais>	(OBLIGATORIO)\n",
		"		Codigo de pais.\n",
		"  <sistema> \n",
		"		Codigo del sistema. Si se omite se consideran todos.\n",
		"  <periodo> \n",
		"		Periodo de tiempo a filtrar (En anios). Ejemplo: 2016-2018.\n",
		"\n";
}

sub Cargar_Parametros_De_Ambiente
{
	$DIR_REPORTES = $ENV{exDIR_REPORTS};
	$DIR_LOGS = $ENV{exDIR_LOGS};
	$DIR_PROC = $ENV{exDIR_PROCESS};
	$DIR_MAE = $ENV{exDIR_MASTER};
}

sub Verificar_Ambiente
{
	my $ambienteOK = $ENV{exINIT_OK};
	die "El ambiente no esta inicializado. No se puede continuar. \n" if $ambienteOK != 1;
}

#La lineas siguiente deberia realizarse si tenemos el sistema levantado
#Verificar_Ambiente();
#Cargar_Parametros_De_Ambiente();
Gestionar_Parametros();
