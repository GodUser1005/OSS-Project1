#! /bin/bash
if [ $# -ne 3 ]
then
	echo "usage: $0 file1 file2 file3"
	exit 1
fi
file1=teams.csv
file2=players.csv
file3=matches.csv
for file in teams.csv players.csv matches.csv
do
	case "$file" in
	$1 | $2 | $3)
		continue;;
	*)
		echo "Some file is not exist"; exit 1;;
	esac
done
echo "**********OSS1 - Project1**********"
echo "*    StudentID : 12201760         *"
echo "*    Name : Jiho Yeo              *"
echo "***********************************"

choiceNum=0
printMenu(){
	echo ""
	echo '[MENU]'
	echo "1. Get the data of Heung-Min Son's Current Club,Appearance,Goals,Assists in player.csv"
	echo '2. Get the team data to enter a league position in teams.csv'
	echo '3. Get the Top-3 Attendance matches in matches.csv'
	echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"
	read -p "Enter your CHOICE(1~7) : " choiceNum
}

function1(){
	read -p "Do you want to get the Heung-Min Son's data? (y/n) : " choose
	if [ -z $choose ] # No input-data
	then
		echo "Input Error"
		echo "Try Again"
		return 1
	fi
	
	if [ $choose = "y" ]
	then
		cat players.csv | grep "Heung-Min Son" | awk -F, '{printf("Team:%s,Appearance:%s,Goal:%s,Assist:%s\n",$4,$6,$7,$8)}'
		return 0
	elif [ $choose = "n" ]
	then 
		return 0
	else 
		echo "Input Error"
		echo "Try Again"
		return 1
	fi
}

function2(){
	read -p "What do you want to get the team data of league_position[1~20] : " position
	re="^[0-9]+$" # input data only integer
	if [[ $position =~ $re ]]
	then
		if [ $position -ge 1 ]
        	then
                	if [ $position -le 20 ]
                	then
                        	cat teams.csv | awk -F, -v p=$position '$6==p {printf("%s %s %f\n",$6,$1,$2/($2+$3+$4))}'
                        	return 0
                	fi
		fi
	fi
	echo "Input Error"
	echo "Try Again"
	return 1
}

function3(){
	read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " choose
	if [ -z $choose ]
	then
		echo "Input Error"
		echo "Try Again"
		return 1
	fi

	if [ $choose = "y" ]
	then
		echo "***Top-3 Attendance Match***"
		echo ""
		cat matches.csv | sort -r -g -t, -k 2 | head -n 3 | awk -F, '{printf("%s vs %s (%s)\n%s %s\n\n",$3,$4,$1,$2,$7)}'
		return 0
	elif [ $choose = "n" ]
	then
		return 0
	else
		echo "Input Error"
		echo "Try Again"
		return 1
	fi	
}

function4(){
	read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choose
	if [ -z $choose ]
	then
		echo "Input Error"
		echo "Try Again"
		return 1
	fi

	if [ $choose = "y" ]
	then
		echo
		IFS=,
		for var in $(cat teams.csv | awk -F, 'NR!=1 {printf("%d/%s\n",$6,$1)}' | sort -g -k 1 |tr '\n' ',')
	        do 
			teamName=$(echo $var | cut -d/ -f2) 
			player=$(cat players.csv | awk -F, -v tn="$teamName" 'tn~$4 {printf("%s,%d\n",$1,$7)}' | sort -t, -g -r -k 2 | head -n 1 | tr ',' ' ')
		       	echo "$var" | tr '/' ' '
			echo "$player"
			echo
		done
	elif [ $choose = "n" ]
	then
		return 0
	else
		echo "Input Error"
		echo "Try Again"
		return 1
	fi
}

function5(){
	read -p "Do you want to modify the format of date? (y/n) : " choose
	if [ -z $choose ]
	then
		echo "Input Error"
		echo "Try Again"
		return 1
	fi
	if [ $choose = "y" ]
	then
		cat matches.csv | cut -d, -f1 | sed -En -e 's/Jan/01/' -e 's/Feb/02/' -e 's/Mar/03/' -e 's/Apr/04/' -e 's/May/05/' -e 's/Jun/06/' -e 's/Jul/07/' -e 's/Aug/08/' -e 's/Sep/09/' -e 's/Oct/10/' -e 's/Nov/11/' -e 's/Dec/12/' -e 's/(^[0-9]{2}) ([0-9]{2}) ([0-9]{4}) (\-) ([0-9][0-9]?:[0-9]{2}(am|pm))/\3\/\1\/\2 \5/p' | head -n 10
		return 0
	elif [ $choose = "n" ]
	then
		return 0
	else
		echo "Input Error"
		echo "Try Again"
		return 1
	fi

}

function6(){
	IFS=
	teams=$(cat teams.csv | awk -F, 'NR!=1 {printf("%s\n",$1)}' |tr '\n' ',')
	echo
	echo $teams | tr ',' '\n' | awk -F, 'NR<=20 {printf("%d) %s\n",NR,$1)}'
	read -p "Enter your team number : " choose
	re="^[0-9]+$"
	if [[ $choose =~ $re ]]
	then
		if [ $choose -ge 1 ] && [ $choose -le 20 ]  
		then
			team=$(echo $teams | awk -F, -v n=$choose '{print $n}')
			max=$(cat matches.csv | awk -F, -v t=$team 'BEGIN {max=0} t==$3 {if($5-$6 > max){max=$5-$6}} END {print max}')
			echo
			cat matches.csv | awk -F, -v t=$team -v m=$max 't==$3 && m==$5-$6 {printf("%s\n%s %d vs %d %s\n\n",$1,$3,$5,$6,$4)}'
			return 0
		fi
	fi
	echo "Input Error"
	echo "Try Again"
	return 1
}


if [ -z $choiceNum ] 
then
	$choiceNum=0
fi

while [ $choiceNum != 7 ]
do
	printMenu
	case "$choiceNum" in
	1)
		function1
		while [ $? -ne 0 ]
		do
			function1
		done;;	
	2)
		function2
		while [ $? -ne 0 ]
		do
			function2
		done;;
	3)
		function3
		while [ $? -ne 0 ]
		do
			function3
		done;;
	4)
		function4
		while [ $? -ne 0 ]
		do
			function4
		done;;
	5)
		function5
		while [ $? -ne 0 ]
		do
			function5
		done;;
	6)
		function6
		while [ $? -ne 0 ]
		do
			function6
		done;;
	7)
		echo "Bye!"
		exit 0;;
	*)
		echo "You can choose in 1~7"
		echo ""
		choiceNum=0;;
	esac
done

