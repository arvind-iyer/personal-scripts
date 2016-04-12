#!/bin/bash

PRINT_QUEUE_ROOT="http://itscapps.ust.hk/pqueue/printers/api/"

#check wget and curl program
if [ "$(type -P wget)" = "" -a "$(type -P curl)" = "" ]; then
	echo "Please install wget or curl first."
	exit 1
fi

#check lpstat and lpadmin
if [ "$(type -P lpstat)" = "" ]; then
	echo "Please install cups and cups-client first."
	exit 1
fi

if [ "$(type -P lpadmin)" = "" ]; then
	echo "Please install cups and cups-client first."
	exit 1
fi

#check if cups is running
if [ "$(systemctl status cups.service  2> /dev/null | grep running | wc -l )" -lt 2 ]; then
	echo "Attempting to start CUPS service"
	if systemctl start cups.service ; then 
		echo "CUPS service started"
	else
		echo "Please install cups and cups-client or start the cups service"
	fi
fi

#if no curl, use wget instead
curl="curl -sS"
if [ "$(type -P curl)" == "" ]
then
	curl="wget -qO-"
fi

echo "Downloading HKUST Print Queue List From Print Server..."
echo

#get print queue lists
SATELLITE_PRINTERS=$(${curl} ${PRINT_QUEUE_ROOT}"satellite_raw")
BARN_PRINTERS=$(${curl} ${PRINT_QUEUE_ROOT}"barn_raw")
ALL_PRINTERS=$(echo "${SATELLITE_PRINTERS}" ; echo "${BARN_PRINTERS}")

function print_action {
	while :
	do
		clear
		echo "                                                                        "
		echo "                      HKUST Unix Print Queue Tool                       "
		echo "                                                                        "
		echo "       **********************************************************       "
		echo "       * Please select an action.                               *       "
		echo "       * 1. Install Print Queue                                 *       "
		echo "       * 2. Un-install Print Queue                              *       "
		echo "       * e. Exit                                                *       "
		echo "       **********************************************************       "
		echo "                                                                        "
		read -p "Action>" action
		case $action in
			"1")
				do_action_1
				;;
			"2")
				do_action_2
				;;
			"e")
				exit 1
				;;
			*)
				echo "Incorrect action."
				echo "Please press [Enter] to continue."
				read
				;;
		esac
	done
}

function do_action_1 {
	while :
	do
		clear
		echo "                                                                        "
		echo "                      HKUST Unix Print Queue Tool                       "
		echo "                                                                        "
		echo "       **********************************************************       "
		echo "       * Please type a number to select a category for printers.*       "
		echo "       * 1. All                                                 *       "
		echo "       * 2. Satellite                                           *       "
		echo "       * 3. Barn                                                *       "
		echo "       * e. Exit                                                *       "
		echo "       **********************************************************       "
		echo "                                                                        "
		read -p "Category>" category
		case $category in
			"1")
				do_category "$ALL_PRINTERS"
				;;
			"2")
				do_category "$SATELLITE_PRINTERS"
				;;
			"3")
				do_category "$BARN_PRINTERS"
				;;
			"e")
				break
				;;
			*)
				echo "Incorrect category."
				echo "Please press [Enter] to continue."
				read
				;;
		esac
	done
}

function do_action_2 {
	while :
	do
		printers=$(lpstat -p 2>/dev/null | grep printer | cut -d' ' -f2)

		if [ "$printers" == "" ]; then
			echo "No Printer is installed in this machine."
			echo "Please press [Enter] to continue."
			read
			break
		fi

		clear
		echo "                                                                        "
		echo "                      HKUST Unix Print Queue Tool                       "
		echo "                                                                        "
		echo "       **********************************************************       "
		echo "       * Please select a printer to un-install.                 *       "
		
		IFS=$'\n'
		for i in $(echo "$printers" | nl -nln -w2 -s'. ' | sed 's/^/       * /g')
		do
			printf '%-64s*' $i
			echo
		done
		unset IFS

		echo "       * e . Exit                                               *       "
		echo "       **********************************************************       "
		echo "                                                                        "
		read -p "Printer Number>" number
		remove_printer "$printers" $number
	done
}

function do_category {
	while :
	do
		clear
		line=$(echo "$1" | wc -l)
		echo "                                                                        "
		echo "                      HKUST Unix Print Queue Tool                       "
		echo "                                                                        "
		echo "       **********************************************************       "
		echo "       * Please Select a Print Queue.                           *       "
		
		IFS=$'\n'
		for i in $(echo "$1" | cut -f1 | nl -nln -w2 -s'.   ' | sed 's/^/       * /g')
		do
			printf '%-64s*' $i
			echo
		done
		unset IFS

		echo "       * e . Exit                                               *"
		echo "       **********************************************************       "
		echo "                                                                        "
		read -p "Print Queue Number>" number
		select_printer "$1" $number
	done
}

function select_printer {
	#exit if user type e
	if [ "$2" == "e" ]; then
		break
		return 1
	fi
	
	#number is not in range
	ret=$(echo "$2" | sed 's/[0-9]//g')
	if [ "$ret" = "$2" ]; then
		echo "Please enter correct print queue number."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi
	
	if [ ! 1 -le "$2" -o ! "$2" -le $(echo "$1" | wc -l) ]; then 
		echo "Please enter correct print queue number."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi

	printer=$(echo "$1" | sed -n ${2}p)
	queue=$(echo "$printer" | cut -f3,4 | sed 's/	/\//g' | sed 's/\\\\//g' )
	driver=$(echo "$printer" | cut -f5)
	label=$(echo "$printer" | cut -f4 | sed 's/[ \\]//g')
	location=$(echo "$printer" | cut -f2 | sed 's/[ \\]//g')
	
	#no driver available
	if [ "$driver" == "" ]; then
		echo "No Driver Available."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi
	
	$curl ${PRINT_QUEUE_ROOT}"drivers/"$driver >/tmp/$driver
	
	#no correct driver download
	if [ ! -f "/tmp/$driver" ]; then
		echo "No correct driver downloaded."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi
	
	#check if the printer is installed
	if [ $(printer_is_installed "$label") -eq 1 ]; then
		echo "Printer $label is already installed"
		echo "Please press [Enter] to continue."
		read
		return 1
	fi
	
	echo "Please enter your ITSC account."
	read -p "Username: " username
	read -s -p "Password: " password
	echo
	echo "Mounting print queue $queue..."
	echo
	
	#install the printer
	lpadmin -p "$label" -v smb://HKUST\\${username}:${password}@${queue} -P "/tmp/${driver}" -L "$location" -o Duplex=DuplexNoTumble -o Media=A4 -o PageSize=A4 -o Option16=True -E 2>/dev/null
	#check if this operation require root permission
	if [ $? -ne 0 ]; then
		echo "Install Print Queue $label requiring root permission."
		sudo lpadmin -p "$label" -v smb://HKUST\\${username}:${password}@${queue} -P "/tmp/${driver}" -L "$location" -o Duplex=DuplexNoTumble -o Media=A4 -o PageSize=A4 -o Option16=True -E 2>/dev/null
	fi
	
	#remove printer driver
	rm "/tmp/$driver"
	
	#check if the printer is mounted
	if [ $(printer_is_installed "$label") -eq 1 ]; then
		echo "The process is completed."
		echo "Printer $label is installed."
		echo "Please press [Enter] to continue."
	else
		echo "The process is failed."
		echo "Please press [Enter] to continue."
	fi

	read
}

function remove_printer {
	#exit if user type e
	if [ "$2" == "e" ]; then
		break
		return 1
	fi

	#number is not in range
	ret=$(echo "$2" | sed 's/[0-9]//g')
	if [ "$ret" = "$2" ]; then
		echo "Please enter correct print queue number."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi	

	if [ ! 1 -le "$2" -o ! "$2" -le $(echo "$1" | wc -l) ]; then 
		echo "Please enter correct print queue number."
		echo "Please press [Enter] to continue."
		read
		return 1
	fi

	label=$(echo "$1" | sed -n ${2}p)
	lpadmin -x "$label" 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "Un-install Print Queue $label requiring root permission."
		sudo lpadmin -x "$label"
	fi

	#check if printer is un-install
	if [ $(printer_is_installed "$label") -eq 1 ]; then
		echo "The process is failed."
		echo "Please press [Enter] to continue."
	else
		echo "The process is completed."
		echo "Printer $label is un-installed."
		echo "Please press [Enter] to continue."
	fi

	read
}

function printer_is_installed {
	if [ 1 -le $(lpstat -p 2>/dev/null | grep "$1" | wc -l) ]; then
		echo "1"
	else
		echo "0"
	fi
}

print_action
