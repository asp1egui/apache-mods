#!/bin/bash
# apache modifier
#modify the name of the folders and files of the virtual conf to your need
service="apache2"
dirsite="/etc/apache2/sites-available"
webdir="/var/www/html"
modify_apache(){

   if [ ! -f "vhost.conf" ];then
   wget https://raw.githubusercontent.com/asp1egui/apache-mods/master/vhost.conf
      if [ ! -w "vhost.conf" ];then
         chmod o+w vhost.conf
	 echo "Need Permissions"
	 sudo mv vhost.conf /etc/apache2/sites-available
	 sudo a2ensite vhost.conf
      fi   
   fi

   cd "$dirsite"
   if [ ! -f "changes.txt" ];then
      echo "Need Permissions"   
      sudo touch changes.txt
      sudo chmod o+w changes.txt
   fi

   if [ ! -d "$webdir/python" ];then
       echo "Need Permissions"
       sudo mkdir "$webdir/python"
       cd
       wget https://raw.githubusercontent.com/asp1egui/apache-mods/master/flaskapp.py
       sudo mv flaskapp.py "$webdir/python/"
       cd "$dirsite" 
   fi

#takes the answer from parts and check if it has the same value
   if [ "$1" == "server" ]
   then
       echo "Insert server name"
       read svname
     
       if  grep -q "servername" changes.txt 
       then
	   oldsvname="$(grep 'servername' changes.txt | cut -d '=' -f2)"  
	   sudo sed -i "s/$oldsvname/$svname/" vhost.conf    
           sudo sed -i "/servername/ s/servername.*/servername=$svname/" changes.txt
	   again 
       else
           sudo sed -i "s/localhost/$svname/" vhost.conf
           sudo echo "servername =$svname" >> changes.txt
	   again
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
           again     
       else
           sudo sed -i "/Serv.*Admin/ s/web.*com/$emailvar/" vhost.conf
           sudo echo "emailname =$emailvar" >> changes.txt
	   again
       fi
       
   elif [ "$1" == "root" ]
   then
       echo "Insert name to directory root"
       read pathvar

       if  grep -q "rootdirectory" changes.txt 
       then
	   olddir="$(grep "rootdirectory" changes.txt | cut -d "=" -f2)"
	   sudo sed -i "s@$olddir@$pathvar@" vhost.conf    
           sudo sed -i "/rootdirectory/ s@rootdirectory.*@rootdirectory=$pathvar@" changes.txt
	   again
       else
           sudo sed -i "s@python@$pathvar@" vhost.conf
           sudo echo "rootdirectory=$pathvar" >> changes.txt
	   again
       fi

   elif [ "$1" == "wsgi" ]
   then
       cd "$webdir"
       dir="wsgiscripts"
       #check if a directory doesnt exist
       if [ ! -d "$dir" ]; then
	  echo "Permission to create a wsgi folder"     
          sudo mkdir $dir
          if [ -d "$dir" ]; then
             echo "Folder made"
          fi 
       fi
             
       cd "$dirsite"      

       echo "Insert the name of the wsgi file"
       read wsgi_script
       if grep -q "wsgifile" changes.txt 
       then
	   oldwsgi="$( grep 'wsgifile' changes.txt | cut -d '=' -f2)"  
	   sudo sed -i "s/$oldwsgi/$wsgi_script/" vhost.conf    
           sudo sed -i "/wsgifile/ s/wsgifile.*/wsgifile=$wsgi_script/" changes.txt
           echo "you have changed the name of the wsgi file"
	   echo "check if it has the same name "
           again       
       else
           sudo sed -i "s/myapp/$wsgi_script/" vhost.conf
           sudo echo "wsgifile = $wsgi_script" >> changes.txt
	   echo "you have changed the name of the wsgi file"
	   echo "check if it has the same name"
	   again
       fi 
   fi
}

again(){
       echo "again?"
       read again1
       if [ "$again1" == "yes" ] || [ "$again1" == "y" ]
       then
           parts
       else
           sudo systemctl reload apache2
	   #check if the user has a gui or not
           if xhost >& /dev/null
	      then
	           xdg-open http://localhost
            else 
		  w3m http://localhost 
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


