#!/bin/bash

source ./Logger.sh
grupo=$HOME/Grupo4
logFile="$exDIR_LOGS/ReportO.log"

Verifico_inicializacion()
{
	if [ ! $exINIT_OK ]
	then
		echo "El sistema no esta correctamente inicializado."
		exit 1
	fi
}

Verifico_inicializacion