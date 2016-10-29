#!/bin/bash
CNT1="1"
while true
do
RSLT=`./eew-get.sh`
if [ "$RSLT" = "OK" ]
then
#	echo "$RSLT"
:
elif [ "$RSLT" = "ERR" ]
then
	CHK="ERR"
	while [ "$CHK" = "ERR" ]
	do
		echo -e "\e[31m"`date "+%Y/%m/%d %H:%M:%S"`" Connection Error!""\e[m"
		CHK=`./eew-get.sh`
		sleep 5
	done
else
	./eew-calc.sh $RSLT
fi

sleep 1s

if [ "$CNT1" = "60" ]
then
	echo -e "\e[32mOK\e[m"
	CNT1="1"
fi
#echo $CNT1
CNT1=$((CNT1+1)) 
done
