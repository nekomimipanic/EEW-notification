#!/bin/bash
RCODE="***"; #地域コード(SNEのみ)
RLATI="**.*"; #経度
RLNGI="***.*"; #緯度
RAMPL="1"; #地盤増幅率
SIE="3.5"; #閾値震度

EEW="0"
EQRAW=$1
EQCN=`echo $EQRAW | cut -c 51`
EQNO=`echo $EQRAW | cut -c 31-46`

if [ ! -f /tmp/EQNO ]
        then
        touch /tmp/EQNO
fi
if [ "$EQCN" = "/" ]
	then
        ./ALART_CLR
        echo "0" > /tmp/EQNO
        echo "0" > /tmp/EQSP
else
	EQNO=`echo $EQRAW | cut -c 31-46`

	if ! [ `cat /tmp/EQNO` = "$EQNO" ]
		then
		echo "0" > /tmp/EQSP
	fi

	EQEMG=${#EQRAW}

###########ここからSNE用処理############
	if [ "$EQEMG" -gt "69" ]
		then
		EQEMR=`echo $EQRAW | cut -c 69-`
		EQEMA=(`echo $EQEMR | fold -w3`)
		for str in "${EQEMA[@]}"
			do
			if [ "$str" = "$RCODE" ]
				then
				EEW="1"
			fi
		done
	fi
###########SNE用処理ここまで############

	EQDEP=`echo $EQRAW | cut -c 59-61`
	EQLAT=`echo $EQRAW | cut -c 51-53`
	EQLGI=`echo $EQRAW | cut -c 55-58`
#	 EQEPL=`echo "scale=5; sqrt( ( ( $EQLAT / 10 - $RLATI ) / 0.0111 ) ^ 2 + ( ( $EQLGI / 10 - $RLNGI ) / 0.0091 ) ^ 2 )" | bc`
	EQLAT=`echo "(($EQLAT / 10) * 4 * a(1)) / 180" | bc -l`
	EQLGI=`echo "(($EQLGI / 10) * 4 * a(1)) / 180" | bc -l`
	RLATI=`echo "($RLATI * 4 * a(1)) / 180" | bc -l`
	RLNGI=`echo "($RLNGI * 4 * a(1)) / 180" | bc -l`
	ART2=`echo "s(($EQLAT - $RLATI) / 2)^2 + c($EQLAT) * c($RLATI) * (s(($EQLGI - $RLNGI) / 2)^2)" | bc -l`
	EQEPL=`echo "a(sqrt($ART2) / sqrt(1 - $ART2)) * 6370 * 2" | bc -l`
	EQLEN=`echo "scale=5; sqrt( $EQEPL ^ 2 + $EQDEP ^ 2 )" | bc -l`
	EQSEQ=`echo "$EQLEN / 3.6" | bc -l`
	EQSEQ=${EQSEQ%.*}
	DATEEQ="${EQRAW:18:12}"
	DATEEQ=`date -d "${DATEEQ:0:2}-${DATEEQ:2:2}-${DATEEQ:4:2} ${DATEEQ:6:2}:${DATEEQ:8:2}:${DATEEQ:10:2} JST" +%s`
	DATEDIST=`echo "$DATEEQ + $EQSEQ" | bc -l`
	EQMAG=`echo $EQRAW | cut -c 62-63`
	EQMAG=`echo "$EQMAG / 10" | bc -l`
	EAMPL=`echo "2.088 * l( $RAMPL ) / l( 10 )" | bc -l`
	EQSIE=`echo "1.36 * $EQMAG - 4.03 * l( $EQLEN + 0.00675 * ( 10 ^ ( 0.5 * $EQMAG ) ) ) / l( 10 ) + 0.0155 * $EQDEP + 2.05 - 0.152 + $EAMPL" | bc -l`
	EQSIE2=`echo "10 * $EQSIE" | bc -l`
	EQSIE2=${EQSIE2%.*}
	if [ "$EQSIE2" -lt  "0" ]
		then
		EQSIE2="0"	
	fi
	##### DEBUG ######
	echo "$EQSIE2 $DATEDIST $EEW"
        echo " $DATEDIST - `date +%s`" | bc -l
	
	if [ `echo "$EQSIE > $SIE" | bc -l` -eq 1 ] || [ "$EEW" = "1" ]
		then
	        if [ `cat /tmp/EQSP` != "1" ] || [ "$EEW" = "1" ]
			then
                        ./ALART $EQSIE2 $DATEDIST $EEW 
			#閾値震度以上でALARTを実行
			#なんか好きなものつくってください。
			#DATEDISTは到達予想のUNIX時間なので各自演算して下さい。
		        ##### DEBUG ######
			echo "$EQSIE2 $DATEDIST $EEW"

			echo $EQNO > /tmp/EQNO
			echo "1" > /tmp/EQSP
		fi
	fi
./INT_SP $EQSIE2 $DATEDIST $EEW
#閾値以下でもなんかしたいとき
fi		
