#!/bin/bash
#practice bash skills
# apache modifier
#modify the name of the folders and files of the virtual conf to your need
service="apache2"

modify_apache(){
   #takes the argument $1  and check if it has the same value
   cd /etc/apache2/sites-enabled/
   echo "Need Permission"
   if [ ! -f "changes.txt" ];then
      sudo touch changes.txt
      sudo chmod o+w changes.txt
   fi
   
   if [ ! -w "vhost.conf" ];then
      sudo chmod o+w vhost.conf
   fi

   if [ "$1" == "server" ]
   then
       echo "Insert server name"
       read svname
       cd /etc/apache2/sites-enabled/
       #touch won't destroy your file if exists already
       sudo touch changes.txt
       if  grep -q "servername" changes.txt 
       then
	   oldsvname="$(grep 'servername' changes.txt | cut -d '=' -f2)"  
	   sed -i "s/$oldsvname/$svname/" vhost.conf    
           sed -i "/servername/ s/servername.*/servername=$svname/" changes.txt
	   source changes.txt
       else
           sudo sed -i "s/localhost/$svname/" vhost.conf
           sudo echo "servername =$svname" >> changes.txt
       fi

   elif [ "$1" == "email" ]
   then
       echo "Insert an email name"
       read emailvar 
       if  grep -q "emailname" changes.txt 

       then
	   #old email contains emailname=value then cut gets only the value part
	   oldemail="$(grep "emailname" changes.txt | cut -d "=" -f2)" 
	   sudo sed -i "s/$oldemail/$emailvar/" vhost.conf    
           sudo sed -i "/emailname/ s/email.*/emailname=$emailvar/" changes.txt
       
       else
       #search a string that starts with Serv and finish with Admin 
       #replace string that starts with web and finish wih host with the var
           sudo sed -i "/Serv.*Admin/ s/web.*com/$emailvar/" vhost.conf
           sudo echo "emailname =$emailvar" >> changes.txt
       fi
       
   elif [ "$1" == "root" ]
   then
       echo "Insert name to directory root"
       read pathvar

       #@ will accept / on the input
       if  grep -q "rootdirectory" changes.txt 
       then
	   olddir="$(grep "rootdirectory" changes.txt | cut -d "=" -f2)"
	   sudo sed -i "s@$olddir@$pathvar@" vhost.conf    
           sudo sed -i "/rootdirectory/ s@rootdirectory.*@rootdirectory=$pathvar@" changes.txt
       else
           sudo sed -i "s@python@$pathvar@" vhost.conf
           sudo echo "rootdirectory=$pathvar" >> changes.txt
       fi

   elif [ "$1" == "wsgi" ]
   then
       cd /var/www/html/
       dir="wsgiscripts"
       #check if a directory doesnt exist
       if [ ! -d "$dir" ]; then
	  echo "Permission to create a wsgi folder"     
          sudo mkdir $dir
          if [ -d "$dir" ]; then
             echo "Folder made"
          fi 
       fi
             
       cd /etc/apache2/sites-enabled       

       echo "Insert the name of the wsgi file"
       read wsgi_script
       if grep -q "wsgifile" changes.txt 
       then
	   oldwsgi="$( grep 'wsgifile' changes.txt | cut -d '=' -f2)"  
	   sudo sed -i "s/$oldwsgi/$wsgi_script/" vhost.conf    
           sudo sed -i "/wsgifile/ s/wsgifile.*/wsgifile=$wsgi_script/" changes.txt
       else
           sudo sed -i "s/myapp/$wsgi_script/" vhost.conf
           sudo echo "wsgifile = $wsgi_script" >> changes.txt
       fi 
   fi
}

parts(){
	echo "what part do you want to modify"
        read answer4
	modify_apache $answer4 
}

if pgrep -x "$service" > /dev/null
then
    echo "do you want to modify something about apache?"
    echo "Most operations will need the root password in order to work"
    read answer 
    if [ "$answer"  == "yes" ] || [ "$answer" == "y" ]
    then
	parts 
    fi 
else
    echo "Apache was not found"	
    echo "Would you like to install it?"
    read answer2
    
    if [ "$answer2" == "yes" ] || [ "$answer2" == "y" ] 
    then 
	    sudo apt install apache2
	    sudo apt install libapache2-mod-wsgi
	    echo "do you want to modify something about apache"
	    read answer5
	    
	    if [ "$answer5" == "yes" ] || [ "$answer5" == "y" ]
            then
                parts		
	    else
	        echo "exit"	    
	    fi  
    else
        echo "Abort"
	
    fi 	    
fi


