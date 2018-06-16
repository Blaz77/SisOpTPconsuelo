#!/usr/bin/perl
use feature qw(switch);
no warnings 'experimental';

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

sub Gestionar_Parametros
{
	$num_args = $#ARGV + 1;
  given($num_args){
    when(0) { print "Debe ingresar al menos un argumento\n"; }
    when(1) {
      given($ARGV[0]){
        when("-a") { Mostrar_Ayuda(); }
        when("-g") { print "Debe ingresar un filtro para poder grabar la salida \n"; }
        default { print "Aca deberia hacerse la recomendacion con el pais ingresado\n";  }
        }
      }
    when(2) {  RealizarBusqueda();}
    when(3) {  RealizarBusqueda();}
    when(4) {  RealizarBusqueda();  }
    default { print "El ingreso maximo de parametros es 4.\n";  }
  }
}

sub RealizarBusqueda
{
  if ( $ARGV[0] eq "-a")
    { print "La opcion -a no puede ir anidada con busquedas\n";  }
  else
    { print "RealizarBusqueda. Crear metodo. \n";}
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

sub Verificar_Ambiente
{
	my $ambienteOK = $ENV{exINIT_OK};
	die "El ambiente no esta inicializado. No se puede continuar. \n" if $ambienteOK != 1;
}

Verificar_Ambiente();
Gestionar_Parametros();
