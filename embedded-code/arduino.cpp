int PIR_PIN = 10;  //PIR sensor pin
int LED_PIN = 12;  // LED pin
int proximity = 0;


void setup()
{
  // In case ip gets reset on board, the following command is used.
  //ip = 169.254.23.235
  system("ifconfig  > /dev/ttyGS0 2>&1");
  
  /*
   *  Begin by starting python modules
   *   - python script will trigger upload daemon ( Python )
   *   - set I/O pins for PIR sensor 
   */

   //Set pin modes
   pinMode(PIR_PIN, INPUT_PULLUP);

  
   
   
   //Initiallzie python Modules, the system thread will hang until wifi is connected properly
   // Note: the binary file for the wifi script gets reset to zero on script start, thereforeS
   //       removing the possiblity of a false LED illumintion
   system("python /_scripts/inet_man/handle_wifi.py > /dev/ttyGS0 2>&1");
   system("python /_scripts/twitter/handle_pictures.py > /dev/ttyGS0 2>&1  &");
   
}
void loop(){
  /*
  *  Check PIR pin 
  *   -If PIR pin high, trigger capture. The rest of processing is handled by python modules.
  */


    proximity = digitalRead(PIR_PIN); // Read PIR sensor
    if (proximity == HIGH) // If the sensor's output goes high, motion is detected
    {    
      system("bash /_scripts/opencv/capture.sh > /dev/ttyGS0 2>&1");  // Captures a frame from the webcam and stores it in /pics with a timestamp
    }

}