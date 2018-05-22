MAX_NUM_LINEAS=200
LINEAS_A_TOMAR=150
directorioLogs=$grupo/$exDIR_LOGS

LogearMensaje()
{
  #Primer parametro Origen
  #Segundo parametro TipoError
  #Tercer parametro  Mensaje
  #Cuarto parametro Ubicacion de archivo donde guardar el log
  fecha=$(date +"%Y/%m/%d %H:%M:%S")
  echo "$fecha - $USER - $1 - $2 - $3" >> $4

  cantidadDeLineas=$(cat $4 | wc -l)
  if [ $cantidadDeLineas -gt $MAX_NUM_LINEAS ]
    then
      ReducirArchivoDeLog $4
  fi
}

ReducirArchivoDeLog()
{
    tail $1 -n $LINEAS_A_TOMAR > $directorioLogs/temp.log
    mv $directorioLogs/temp.log $1
}
