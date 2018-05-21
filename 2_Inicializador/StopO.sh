pidRecordFile="./pidRecord.dat"
bin_Inicializador=IniciO.sh
source ./Logger.sh
logFile="../dirconf/StopO.log"

# Params: string mensajeEspecifico, string funcionOrigen
Log_Info()
{
	LogearMensaje "StopO" "INF" "$1" "$logFile"
	echo "$1"
}

if [ -f $pidRecordFile ]
then
	PID=
	read -r PID < $pidRecordFile
	PID_PS=$(ps -fo pid,args -p $PID | grep ".*$PID./$bin_Inicializador$" | cut -f1 -d' ')
	if [ "$PID" == "$PID_PS" -a "$PID_PS" != "" ]
	then
		Log_Info "Se detiene el detector de novedades." ""
	fi
fi