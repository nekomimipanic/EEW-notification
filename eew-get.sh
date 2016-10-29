#!/bin/bash
:
EEWURL="http://www.kmoni.bosai.go.jp/new/webservice/hypo/eew/"`date "+%Y%m%d%H%M%S"`".json"
EQGET=`wget $EEWURL --timeout=1 -q -O -`
PRMT=`echo $EQGET | jq -r .result.message`
#echo $EQGET

if [ "$PRMT" = "" ]
        then
        EQR1=(`echo $EQGET | jq -r '.result.status, .report_time, .longitude, .is_cancel, .depth, .is_training, .latitude, .origin_time, .magunitude, .report_num, .report_id, .alertflg'`)
	if [ "${EQR1[0]}" = "success" ]
	then
	        EQR2=()
	        EQR2+=( 01 )
	
	        if [ "${EQR1[4]}" = "true" ]
	                then
	                EQR2+=( 3910 )
	                EQR2+=( `echo ${EQR1[1]}${EQR1[2]} | sed -e 's/\///g' -e 's/://g' -e 's/^..//'` )
	                EQR2+=( `echo ${EQR1[8]} | sed -e 's/^..//'` )
	                EQR2+=( `echo "ND"${EQR1[11]}"0"` )
	                EQR2+=( `printf %02d ${EQR1[10]}` )
	                EQR2+=( "///////////////////" )
	        else
	                EQR2+=( 3X00 )
	                EQR2+=( `echo ${EQR1[1]}${EQR1[2]} | sed -e 's/\///g' -e 's/://g' -e 's/^..//'` )
	                EQR2+=( `echo ${EQR1[8]} | sed -e 's/^..//'` )
	                EQR2+=( `echo "ND"${EQR1[11]}"0"` )
	                EQR2+=( `printf %02d ${EQR1[10]}` )
                        LATI=`echo "scale=0; ${EQR1[7]} * 10" | bc`
                        EQR2+=( `echo "N"${LATI%.*}` )
                        LNGI=`echo "scale=0; ${EQR1[3]} * 10" | bc`
                        EQR2+=( `echo "E"${LNGI%.*}` )
	                KM=`echo ${EQR1[5]} |sed -e "s/km//"`
	                EQR2+=( `printf %03d $KM` )
	                MAG=`echo "scale=0; ${EQR1[9]} * 10" | bc`
	                EQR2+=( `printf %02d ${MAG%.*}` )
	        	if [ "${EQR1[12]}" = "警報" ]
			then
        		        EQR2+=( XXXXE )
			else
        		        EQR2+=( XXXXX )
			fi
		fi
        	echo ${EQR2[@]} | sed -e 's/ //g'

	fi
        elif [ "$PRMT" = "データがありません" ]
        then
        echo "OK"
fi
if [ "$PRMT" = "" ]
        then
        echo "ERR"
fi

