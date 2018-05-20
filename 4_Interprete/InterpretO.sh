grupo=$HOME/Grupo4
fnoc=$grupo/dirconf/fnoc.conf

###Busco directorio de maestros en el archivo de configuracion
lineaMaestros=$(grep '^Maestros-' $fnoc)
directorioMaestros=$(echo $lineaMaestros | cut -d '-' -f2)
archivoT1=$grupo/$directorioMaestros/T1.tab
archivoT2=$grupo/$directorioMaestros/T2.tab
archivops=$grupo/$directorioMaestros/p-s.mae

###Busco todos los archivos a procesar
cd $grupo/acep
archivosAProcesar=$(ls)


###Por cada archivo a procesar, busco sus delimitadores
for archivo in $archivosAProcesar
do
	pais=$(echo $archivo | cut -c1)
	sistema=$(echo $archivo | cut -c3)

	SIS_ID=$sistema
	FECHA=$(date +"%d/%m/%Y")

	###Busco el nombre del pais en el archivo p-s.mae
	paisSistema=$(grep "^$pais-..*-$sistema" $archivops)
	nombrePais=$(echo $paisSistema | cut -d '-' -f2)

	###Busco los separadores de campos y decimal en el archivo T1
	regex=$(grep "$pais-$sistema" $archivoT1)
	delimitador_campos=$(echo $regex | cut -c5)
	delimitador_decimal=$(echo $regex | cut -c7)


	cantidadCampos=$(grep -c "$pais-$sistema" $archivoT2)
	###No se por que el while no lee la ultima linea del archivo
	while read -r linea
	do
		let contador=1
		while [ $contador -le $cantidadCampos ]
		do
			campo=$(echo $linea | cut -d ';' -f $contador)
			lineaT2=$(grep "$pais-$sistema-.*-$contador-" $archivoT2)
			nombreCampo=$(echo $lineaT2 | cut -d '-' -f3)
			posicionCampo=$(echo $lineaT2 | cut -d '-' -f4)
			tipoCampo=$(echo $lineaT2 | cut -d '-' -f5)
			case $nombreCampo in
				CTB_FE)
					CTB_FE=$campo
					CTB_FE_tipo=$tipoCampo ;;
				CTB_ESTADO)
					CTB_ESTADO=$campo
					CTB_ESTADO_tipo=$tipoCampo ;;
				PRES_ID)
					PRES_ID=$campo
					PRES_ID_tipo=$tipoCampo ;;
				MT_PRES)
					MT_PRES=$campo
					MT_PRES_tipo=$tipoCampo ;;
				MT_IMPAGO)
					MT_IMPAGO=$campo
					MT_IMPAGO_tipo=$tipoCampo ;;
				MT_INDE)
					MT_INDE=$campo
					MT_INDE_tipo=$tipoCampo ;;
				MT_INNODE)
					MT_INNODE=$campo
					MT_INNODE_tipo=$tipoCampo ;;
				MT_DEB)
					MT_DEB=$campo
					MT_DEB_tipo=$tipoCampo ;;
				PRES_CLI_ID)
					PRES_CLI_ID=$campo
					PRES_CLI_ID_tipo=$tipoCampo ;;
				PRES_CLI)
					PRES_CLI=$campo
					PRES_CLI_tipo=$tipoCampo ;;
			esac
			let contador=contador+1
		done
	#done < $archivo

	longitudFecha=$(echo $CTB_FE_tipo | cut -c7,8)
	if [ $longitudFecha = "10" ]
	then
		tieneSeparador=true
	else
		tieneSeparador=false
	fi

	primerosCaracteres=$(echo $CTB_FE_tipo | cut -c1,2)

	if [ $tieneSeparador = true ]
	then
		if [ $primerosCaracteres = "dd" ]
		then
			CTB_DIA=$(echo $CTB_FE | cut -c1,2)
			CTB_MES=$(echo $CTB_FE | cut -c4,5)
			CTB_ANIO=$(echo $CTB_FE | cut -c7-10)
		elif [ $primerosCaracteres = "yy" ]
		then
			CTB_ANIO=$(echo $CTB_FE | cut -c1-4)
			CTB_MES=$(echo $CTB_FE | cut -c6,7)
			CTB_DIA=$(echo $CTB_FE | cut -c9,10)
		fi
	else
		if [ $primerosCaracteres = "dd" ]
		then
			CTB_DIA=$(echo $CTB_FE | cut -c1,2)
			CTB_MES=$(echo $CTB_FE | cut -c3,4)
			CTB_ANIO=$(echo $CTB_FE | cut -c5-8)
		elif [ $primerosCaracteres = "yy" ]
		then
			CTB_ANIO=$(echo $CTB_FE | cut -c1-4)
			CTB_MES=$(echo $CTB_FE | cut -c5,6)
			CTB_DIA=$(echo $CTB_FE | cut -c7,8)
		fi
	fi

	#MT_REST=$MT_PRES+$MT_IMPAGO+$MT_INDE+$MT_INNODE–$MT_DEB
	MT_REST=$MT_PRES\+$MT_IMPAGO
	echo "mt_rest es: $MT_REST"

	###el nuevo archivo va a tener 16 campos
	echo "$SIS_ID;$CTB_ANIO;$CTB_MES;$CTB_DIA;$CTB_ESTADO;$PRES_ID;$MT_PRES;$MT_IMPAGO;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$PRES_CLI_ID;$PRES_CLI;$FECHA;$USER" >> $grupo/proc/PRESTAMOS.$nombrePais   ###en proc debe ir el directorio creado para los archivos procesados
	done < $archivo
done

