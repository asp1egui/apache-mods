#!/bin/bash
#practice bash skills
# apache modifier
#modify the name of the folders and files of the virtual conf to your need
service="apache2"

modify_apache(){
   #takes the argument $1  and check if it has the same value
   cd /etc/apache2/sites-enabled/
   echo "Need Permissions"
   sudo touch changes.txt
   sudo chmod o+w changes.txt
   sudo chmod o+w 000-default.conf

   if [ "$1" == "server" ]
   then
       echo "Insert server name"
       read svname

       if  [ -f changes.txt ]
       then
	   oldsvname= grep "servername" changes.txt | cut -d "=" -f2 > /dev/null 
	   sudo sed -i "/ServerName/ s/$oldsvname/$svname/" 000-default.conf    
           sudo  sed -i "/servername/ s/servername.*/servername=$svname/" changes.txt
	   source changes.txt
       else
       	       
       sudo sed -i "s/localhost/$svname/" 000-default.conf
       sudo echo "servername =$svname" >> changes.txt

       fi

   elif [ "$1" == "email" ]
   then
       echo "Insert an email name"
       read emailvar 
       if  [ -f changes.txt ]

       then
	   #old email contains emailname=value then cut gets only the value part
	   oldemail= grep "emailname" changes.txt | cut -d "=" -f2 > /dev/null 
	   sudo sed -i "Serv.*Admin/ s/$oldemail/$emailvar/" 000-default.conf    
           sudo sed -i "/emailname/ s/email.*/emailname=$emailvar/" changes.txt
	   source changes.txt
       
       else
       #search a string that starts with Serv and finish with Admin 
       #replace string that starts with web and finish wih host with the var
       sudo sed -i "/Serv.*Admin/ s/web.*host/$emailvar/" 000-default.conf
       sudo echo "emailname =$emailvar" >> changes.txt
       fi
       
   elif [ "$1" == "root" ]
   then
       echo "Insert path to directory root"
       read pathvar

       #@ will accept / on the input
       if [ -f changes.txt ]
       then
	   olddir= grep "roodirectory" changes.txt | cut -d "=" -f2 > /dev/null 
	   sudo sed -i "s@$olddir@$pathvar@" 000-default.conf    
           sudo sed -i "/rootdirectory/ s/rootdirectory.*/rootdirectory=$pathvar/" changes.txt
	   source changes.txt
       else
       sudo sed  "s@flaskapp@$pathvar@" 000-default.conf
       sudo echo "rootdirectory = $pathvar" >> changes.txt
       fi

   elif [ "$1" == "wsgi" ]
   then
       cd /var/www/html/
       dir="wsgiscripts"
       #check if a directory doesnt exist
       if [ ! -d "$dir" ]; then
	  echo "Permission to create folder"     
          sudo mkdir $dir
	  
          if [ -d "$dir" ]; then
             echo "Folder made"
          fi 
       fi
             
       cd /etc/apache2/sites-enabled       

       echo "Insert the name of your wsgi file "
       read wsgi_script
       if [ -f changes.txt ]
       then
	   oldwsgi= grep "oldwsgi" changes.txt | cut -d "=" -f2 > /dev/null 
	   sudo sed -i "/myapp/ s/$oldwsgi/$wsgi_script/" 000-default.conf    
           sudo sed -i "/wsgifile/ s/wsgifile.*/wsgifile=$wsgi_script/" changes.txt
	   source changes.txt
       else
       sudo sed "s/myapp/$wsgi_script/" 000-default.conf
       sudo echo "wsgifile = $wsgi_script" >> changes.txt
       fi 
   fi
}

if pgrep -x "$service" > /dev/null
then
    echo "do you want to modify something of apache?"
    echo "Most operations will need the root password in order to work"
    read answer 
    if [ "$answer"  == "yes" ] || [ "$answer" == "y" ]
    then
	echo "what part do you want to modify"
        read answer3
	modify_apache $answer3 
    fi 
else
    echo "Apache was not found"	
    echo "Would you like to install it?"
    read answer2
    
    if [ "$answer2" == "yes" ] || [ "$answer2" == "y" ] 
    then 
	    sudo apt install apache2
	    sudo apt install libapache2-mod-wsgi 
    else
        echo "Abort"
	
    fi 	    
fi

