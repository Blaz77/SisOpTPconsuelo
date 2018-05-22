#!/usr/bin/perl

system("clear");

my $ambienteOK = $ENV{exINIT_OK}
die "El ambiente no esta inicializado. No se puede continuar." if $ambienteOK != 1;

print "Bienvenido al sistema de reportes Elija el tipo de reporte que desea realizar:\n";
print "(1) - Recomendacion.\n";
print "(2) - Listar Divergencias en porcentaje.\n";
print "(3) - Listar Divergencias en monto.\n";

