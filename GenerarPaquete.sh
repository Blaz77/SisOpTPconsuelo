#!/bin/bash

# Esto se ejecuta y te crea el paquete, el tar y el gz

DIFERENCIAL="."
DIR_PAQUETE="6_Paquete"
DIR_METADATOS="Misc/metadatos"
DIR_DATOSPRUEBA="Misc/datosPrueba"

echo
echo " ██████╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗███████╗██╗      ██████╗ "
echo "██╔════╝██╔═══██╗████╗  ██║██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗"
echo "██║     ██║   ██║██╔██╗ ██║███████╗██║   ██║█████╗  ██║     ██║   ██║"
echo "██║     ██║   ██║██║╚██╗██║╚════██║██║   ██║██╔══╝  ██║     ██║   ██║"
echo "╚██████╗╚██████╔╝██║ ╚████║███████║╚██████╔╝███████╗███████╗╚██████╔╝"
echo " ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ "
echo
echo

echo "Eliminando paquete anterior..."

rm -rf $DIFERENCIAL/$DIR_PAQUETE

echo "Creando directorios"

mkdir $DIFERENCIAL/$DIR_PAQUETE
mkdir $DIFERENCIAL/$DIR_PAQUETE/Grupo4
mkdir $DIFERENCIAL/$DIR_PAQUETE/Grupo4/dirconf
mkdir $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package
mkdir $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/archivostp
mkdir $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts

echo "Copiando archivos..."

cp $DIFERENCIAL/$DIR_METADATOS/* $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/archivostp
cp $DIFERENCIAL/$DIR_DATOSPRUEBA/* $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/archivostp
cp $DIFERENCIAL/"1_Instalador"/"InstalO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4
cp $DIFERENCIAL/"2_Inicializador"/"IniciO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts
cp $DIFERENCIAL/"2_Inicializador"/"StopO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts
cp $DIFERENCIAL/"3_Demonio"/"DetectO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts
cp $DIFERENCIAL/"4_Interprete"/"InterpretO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts
cp $DIFERENCIAL/"5_Reportes"/"ReportO.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts
cp $DIFERENCIAL/"Logger.sh" $DIFERENCIAL/$DIR_PAQUETE/Grupo4/package/scripts

echo "Generando tgz..."

PWDBack=$PWD
cd $DIFERENCIAL/$DIR_PAQUETE
tar cvfz $PWDBack/$DIFERENCIAL/"Paquete.tgz" * > /dev/null
cd $PWDBack

echo "Listo."
read -en 1
