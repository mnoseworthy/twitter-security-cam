#!/usr/bin/python

#GLOBALS
max_number_pictures = 100 #Max number pictures allowed to be stored in /pics
master_upload_timeout = 30 #Number of seconds allowed between uploads

#Comparators
last_uploaded = ' '
last_upload_time = 0

#Hide this
APP_KEY = 'lJqqQAIywQVX0auWKq6wWemWc'
APP_SECRET = 'GXjsn3F7iw4XzMSVKIEfIGmwlpXk4Wgs9fz04fX22w8fMjIB25'
OAUTH_TOKEN = '536767139-CpBCtNkSiZ6IdGOD3IYj3SKKPM8gfK4gh3CX8gE0'
OAUTH_TOKEN_SECRET = 'S6CJWSxu0G5f4LHHoKGz1G0zAMvg2ugHZxcqXIq1VKxdA'

import glob
import os
import sys
import time

#oAuth0 via twitter API wrapped by twython
from twython import Twython
try:
	print("handle_pictures: Auth0 attempt")
	twitter = Twython(APP_KEY, APP_SECRET,
					  OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

except Exception as e:
	print("handle_pictures: Could not authenticate")
	os.system("python ../inet_man/handle_wifi.py")
	exit();
	
#report to console					  
print("handle_pictures: Authentication Success !")

#get filename from command line arg
def upload( filename ):
	#Import global variables
	global last_uploaded
	global last_upload_time
	global master_upload_timeout
	global max_number_pictures
	
	if( last_upload_time == 0 or (filename != last_uploaded and time.time() - last_upload_time > master_upload_timeout ) ):	
		try:
			file = open(filename, 'rb')
			response = twitter.upload_media(media=file)
			twitter.update_status(status='Fully automated capture and upload using only webcam for motion detection', media_ids=[response['media_id']])
			#file.close()
			
			#update global index
			last_uploaded = filename
			last_upload_time = time.time()
			
			#report to console
			print("handle_pictures: Uploaded  " + filename +" to twitter")	
			
		except Exception as e:
			print("handle_pictures: Could not upload to twitter, starting handle_wifi")
			os.system("python ../inet_man/handle_wifi.py")
			print("handle_pictures: resuming")
			pass
		
		
	return


#Reads of list of all pictures in the pic folder
filelist_glob = glob.glob("/pics/*")
filelist = sorted(filelist_glob)
print("handle_pictures: Waiting for new frame...")

#Loop forever and handle pictures until the end of time
while True:
	if glob.glob("/pics/*") != filelist_glob:
		
		#Report to console 
		print("handle_pictures: New frame found")
		
		#Wait for file to finish writing
		time.sleep(1)
		
		#Update glob and filelist
		filelist_glob = glob.glob("/pics/*")
		filelist = sorted(filelist_glob)
		
		#Uploads the newest Picture
		upload(filelist[len(filelist) - 1])

		#Check if number of pictures on SD card is more than threshold
		num_files = len(filelist)
		if num_files > max_number_pictures:
			#if it is, remove half of them.
			print "handle_pictures: stored picture count threshold met...\n"
			i = 0		
			while num_files - i > max_number_pictures/2:
					print "handle_pictures: Removing old picture " + filelist[i]	
					os.remove( filelist[i] )
					i = i + 1
	
			print("\n")




