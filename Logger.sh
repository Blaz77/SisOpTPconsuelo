LogearMensaje()
{
  #Primer parametro Origen
  #Segundo parametro TipoError
  #Tercer parametro  Mensaje
  #Cuarto parametro Ubicacion de archivo donde guardar el log 
  fecha=$(date +"%Y/%m/%d %H:%M:%S")
  echo "$fecha - $USER - $1 - $2 - $3" >> $4
}
