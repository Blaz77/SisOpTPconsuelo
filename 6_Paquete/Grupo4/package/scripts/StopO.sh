pidRecordFile="./pidRecord.dat"
bin_Inicializador=IniciO.sh
grupo=$HOME/Grupo4
source ./Logger.sh

# Params: string mensajeEspecifico, string funcionOrigen
Log_Info()
{
	LogearMensaje "StopO" "INF" "$1" "$logFile"
	echo "$1"
}

if [ "$exINIT_OK" != 1 ]
then
    echo "El ambiente no esta inicializado. No se puede continuar."
    exit
fi

logFile=$exDIR_LOGS

if [ -f $pidRecordFile ]
then
	PID=
	read -r PID < $pidRecordFile
	PID_PS=$(ps -fo pid,args -p $PID | grep ".*$PID.*Grupo4.*\.sh$" | sed -e 's/^[ \t]*//' | cut -f1 -d' ')
	if [ "$PID" == "$PID_PS" -a "$PID_PS" != "" ]
	then
		Log_Info "Se detiene el detector de novedades." ""
        kill -9 $PID
	fi
fi
