import os,sys

#virtual environment python
#uncomment if you use a virtual environment
#os.system('/bin/bash --rfile /home/user/virtualenv/bin/activate')

sys.path.insert(0,'/var/www/html/python')
os.chdir('/var/www/html/python')

from pyprogram import app as application
