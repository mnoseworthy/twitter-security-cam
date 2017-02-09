import socket
import os
import os.path
import time
import sys
import subprocess

#Ensure the inital state of file is false
flag = open("/wifi_flag/flag.txt","r+")
flag.write("0");
flag.close();

#Open wifi flag file to update throughout execution
while not os.path.exists("/wifi_flag/flag.txt"):
	time.sleep(1)
if(os.path.isfile("/wifi_flag/flag.txt")):
	flag = open("/wifi_flag/flag.txt","r+")

#The different possible wireless connections to attempt
home_connection = "connmanctl connect  wifi_001dd94e801e_526f676572733333303639_managed_psk";
mjn_phone_connection = "connmanctl connect wifi_001dd94e801e_6950686f6e65_managed_psk";
mwb_phone_connection = "connmanctl connect wifi_001dd94e801e_5a544520_managed_psk";
current_connection = mjn_phone_connection;

#Command to get available connection points
scan_wifi = "connmanctl scan wifi"


#Function to ping googles nameserver to check for connection
def internet(host="8.8.8.8", port=53, timeout=3):
	try:
		socket.setdefaulttimeout(timeout)
		socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host,port))
		return True
	except Exception as ex:
		print ex.message
		return False

#attempt to connect to a possible access point
def connect():
	global current_connection
	print("handle_wifi: attempting to reconnect...")
	os.system(scan_wifi)
	os.system(current_connection)
	return

#Main loop	
while True:		
	if internet():
		print("\n handle_wifi: success, exiting.")
		flag.write("1")
		exit()
	else:	
		if current_connection == mwb_phone_connection:
			current_connection = mjn_phone_connection;
		else:
			current_connection = mwb_phone_connection;	
	
		connect()
		time.sleep(15)
		
