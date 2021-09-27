#!/bin/sh

lf=/tmp/lf.tmp
maxusep=90
countf=5

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


stat(){
echo -e "\nRoot Statistics:"
df -h /
usep=`df -h / | tail -1 | awk '{print $5}'| tr -d ' %'`

#echo -e "\n\nTop most voracious catalogs:"
#du -hsx /* | sort -rh | head -$countf
echo -e "\n\nThe size of the "/var/log" directory:"
du -hs /var/log

echo -e "\n\nTop $countf largest files in /var/log:"
find /var/log -type f -exec ls -alh {} \; | sort -hr -k5 | head -n $countf | awk '{print $5, $9}' > $lf
cat $lf
}


clean(){
echo -e "\nFiles will be deleted:\n"
cat $lf
echo -e "\nDo we continue? (y/n)"
read item
case "$item" in
    y|Y) echo "You entered Y"
    ;;
    n|N) echo "Exit..."
        exit 0
        ;;
    *) echo "I did not understand. Exit..."
        ;;
esac
while read line; do
fsize=$(echo $line | awk $'{print $1}')
fname=$(echo $line | awk $'{print $2}')

echo "dell $fname"
rm -f $fname

done < $lf
}


restart_aster(){
echo -e "\nRestart Asterisk?\n (y/n)"
read item
case "$item" in
    y|Y) fwconsole restart
    ;;
    n|N) echo "Exit..."
        exit 0
        ;;
    *) echo "I did not understand. Exit..."
        ;;
esac
}

stat

if [ "$usep" -ge "$maxusep" ]
then
	echo -e "\nuse disk value >= $maxusep% !!!"
	echo -e "Cleaning needs to be done\n"
	clean
else
	echo -e "\nNo cleaning required\n"
	exit
fi

restart_aster
