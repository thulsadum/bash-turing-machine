#!/bin/bash
#turing.sh V0.21
# This is an turing machine implemented in Bash.


if [ -z "$1" ]; then
	echo "You should specify an input file!" 1>&2
	exit 1
fi
oldIFS=$IFS
state=0
line=0
endless=1

bandwidth=79
pos=0
alpha[0]=" "
alpha[1]="1"
alpha[2]="0"
alphasize=2

#Init Band

IFS=$'\n'
echo "# opening: $1"
for l in $(cat $1 |sed "s/\#.*//g"|sed "/^\s*$/d"|sed "s/^\s*//g"|sed "s/\s*$//g")
do
	p=0
	cor=0
	((line+=1))
	echo -n "$line: "
        echo $l>&2
	case ${l:0:1} in
		"<"|"I")
		it=""
		for i in `seq 2 ${#l}`; do
			c=${l:(($i-1)):1}
			cok=0
			for j in $(seq 0 $alphasize)
			do
				if [ "$cok" -eq "0" ]; then
					if [ "$c" == "${alpha[$j]}" ]; then
						cok=1
					fi
				fi
			done
			if [ "$cok" == "1" ]; then
				band[(($p-$cor))]=$c
				it="$it$c"
			else
				echo "# Ignoring character '$c' @$line:$pos." >&2
				((cor+=1))
			fi
			((p+=1))	
		done
		echo "# (I@    0)  $it">&2

		;;
	"!"|"S")
		state=${l:1}
		echo "# S:  $state"
		;;
	"."|"P")
		pos=${l:1}
		echo "# P:  $pos"
		;;
	"L")
		bandwidth=$((${l:1}-1))
		echo "# L:  $bandwidth"
		;;
	"@"|"A")
		p=1
		al=""
		alphasize=$((${#l}-1))
		for i in $(seq 2 ${#l})
		do
			c=${l:(($i-1)):1}
			alpha[$p]=$c
			al="$al$c"

			((p+=1))
		done
		echo "# A:  $al ($alphasize symbols)"
	;;
	*)
		IFS=","
		a=($l)
		count=0
		while [ -n "${a[$count]}" ]
		do
			((count+=1))
		done
		
		if [ "$count" -ne "5" ]; then
			echo "# Missformed Statedescription @$line -- ignoring (program will not work properly)" >&2
			echo "#   Statedescribtion looks like: State,Symbol expected,Symbol to write,Headdirection,Next State">&2
		else
			stat="${a[0]}"
			expect="${a[1]}"
			write="${a[2]}"
			move="${a[3]}"
			next="${a[4]}"
			#echo "# State: $stat"
			#echo "#   expecting:  $expect"
			#echo "#   write:      $write"
			#echo "#   move to:    $move"
			#echo "#   next state: $next"
			if [ "$next" == "F" ]; then
				endless=0
			fi
			index=$(($stat*($alphasize+1)))

			#case $expect in
			#	# " "->((index+=0))->dumm
			#	"0")
			#		((index+=1))
			#	;;
			#	"1")
			#		((index+=2))
			#	;;
			#esac

			ok=0
			off=0
			wok=0
			#echo $alphasize
			IFS=$oldIFS#$"\n"
			for i in $(seq 0 $alphasize)
			do
				#echo "\$i=\"$i\""
				#echo "\$alpha[$i]=${alpha[$i]}"
				if [ "$ok" -ne "1" ]; then
					if [ "$expect" == "" -o "$expect" == "${alpha[$i]}" ]; then
						((index+=$off))
						ok=1
					fi
				fi
				if [ "$wok" -eq "0" ]; then
					if [ "${alpha[$i]}"=="$write" ]; then
						wok=1
					fi
				fi
				((off+=1))
			done

			if [ "$ok" -eq "0" ]; then
				echo "# Unspecified symbol '$expect' expected @$line">&2
				exit 1
			fi
			if [ "$wok" -eq "0" ]; then
				echo "# Should write unspecified symbol '$write' @$line">&2
				exit 1
			fi

			eval "states_write[$index]=\"$write\""
			eval "states_move[$index]=\"$move\""
			eval "states_next[$index]=\"$next\""
		fi
		IFS=$oldIFS
	esac
done

echo P: $pos

if [ "$endless" -eq "1" ]; then 
	echo -n "## This seems to be an endless turing machine. Do you realy want to start it? [y/N] ">&2
	read -n 1 ant
	echo >&2
	if [ "$ant" != "y" ]; then
		exit 0
	fi
fi

echo $state
cycles=0
until [ "$state" == "F" ]
do
	((cycles+=1))
	echo -n "# ($state@$(echo $cycles|gawk '{ printf "%5d\n", $1 }'))  "
	for i in $(seq 0 $bandwidth)
	do
		if [ "$i" -eq "$pos" ]; then
			echo -n "_${band[$i]}_"
		else
			echo -n "${band[$i]}"
		fi
	done
	echo

	#Read
	data=${band[$pos]}
	#echo "$state*($alphasize+1)"
	index=$(($state*($alphasize+1)))
	ok=0
	off=0
	IFS=$oldIFS
	#echo "# Data: $data@$pos"
	for i in $(seq 0 $alphasize)
	do
		if [ "$ok" -ne "1" ]; then
			#echo "\"$data\"==\"${alpha[$i]}\""
			if [ "$data" == "" -o "$data" == "${alpha[$i]}" ]; then
				#echo "# Found ${alpha[$i]}@$i+$off"
				((index+=$off))
				ok=1
			fi
		fi
		((off+=1))
	done
	if [ "$ok" -eq "0" ]; then
		echo "# Unspecified symbol '$data'!">&2
		exit 1;
	fi

	#case $data in
	#	"0")
	#		((index+=1))
	#	;;
	#	"1")
	#		((index+=2))
	#	;;
	#esac
	
	#Write
	#echo "## Writing: ${states_write[$index]}@$index"
	if [ -z "${states_write[$index]}" ]; then
		echo "## State: ($state,$data) is not defined! Halted.">&2
		exit 1
	fi
	band[$pos]=${states_write[$index]}

	#Move Head
	case ${states_move[$index]} in
		"<")
			((pos-=1))
		;;
		">")
			((pos+=1))
		;;
	esac
	if [ "$pos" -lt "0" ]; then
		pos=$bandwidth
	fi
	if [ "$pos" -gt "$bandwidth" ]; then
		pos=0
	fi

	#jump to next state
	#echo "$index: ${states_next[$index]}"
	state=${states_next[$index]}

	if [ "$state" == "F" ]; then
		((cycles+=1))
		echo -n "# ($state@$(echo $cycles|gawk '{printf "%5d",$1}'))  ">&2
		for i in $(seq 0 $bandwidth)
		do
			echo -n "${band[$i]}">&2
		done
		echo>&2
		echo "# Reached final state. Needed $cycles cycles">&2
	fi
	#t=$(($state * ($alphasize+1)))
	
	#for i in $(seq 0 $alphasize)
	#do
	#	if  [ -z "${states_write[$(($t+$i))]}" ]; then
	#		echo "## State '$state' is not well defined!">&2
	#		exit 1;
	#	fi	
	#done
done

echo "### END ###"
exit 0
