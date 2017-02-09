#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <opencv2/imgproc/imgproc.hpp>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include "/usr/include/python2.7/Python.h"

using namespace cv;
 
 /*
 * Globals
 */
 const string filepath = "/pics";
 const string file_prefix = "frame_";
 const string extension = ".jpg";
 const int min_capture_delay = 5;
 

 
/*
* Saves image to SD card
*/
int incr = 0;
bool save_frame(Mat output)
{
    time_t seconds;
    struct tm * timeinfo;
    char TIME[80];
    time (&seconds);
    // Get the current time
    timeinfo = localtime (&seconds);
	
	// Create name for the image
    strftime (TIME,80,"%d%h%Y_%H%M%S",timeinfo);

	// Report to console
	string filename = filepath + "/" + file_prefix + TIME + extension ;
	
	//Write file
	imwrite(filename , output);
	std::cerr << "frame_cap: Wrote "<< filename << std::endl;
	
	// Trigger twitter upload	
    return true;
}
 
//Returns a frame from the camera
/* NEED TO OPTIMISE DELAY FOR CAPTURE */
Mat get_frame()
{
	Mat frame;
	
	//Start the camera
	VideoCapture cap(0);
	
	// Get the frame
	int i = 7;
	while(i > 0)
	{	
		cap >> frame;				
		i--;
	}
	 
	return frame;
	
}

// Check if there is motion in the result matrix
// count the number of changes and return.
inline int detectMotion(const Mat & motion, Mat & result, Mat & result_cropped,
                 int x_start, int x_stop, int y_start, int y_stop,
                 int max_deviation,
                 Scalar & color)
{
    // calculate the standard deviation
    Scalar mean, stddev;
    meanStdDev(motion, mean, stddev);
    // if not to much changes then the motion is real (neglect agressive snow, temporary sunlight)
    if(stddev[0] < max_deviation)
    {
        int number_of_changes = 0;
        int min_x = motion.cols, max_x = 0;
        int min_y = motion.rows, max_y = 0;
        // loop over image and detect changes
        for(int j = y_start; j < y_stop; j+=2){ // height
            for(int i = x_start; i < x_stop; i+=2){ // width
				//std::cerr << i << "  :  " << j << std::endl;
                // check if at pixel (j,i) intensity is equal to 255
                // this means that the pixel is different in the sequence
                // of images (prev_frame, current_frame, next_frame)
                if(static_cast<int>(motion.at<uchar>(j,i)) == 255)
                {
                    number_of_changes++;
                    if(min_x>i) min_x = i;
                    if(max_x<i) max_x = i;
                    if(min_y>j) min_y = j;
                    if(max_y<j) max_y = j;
                }
            }
        }
       
        return number_of_changes;
    }
    return 0;
}

long int unix_timestamp()  
{
    time_t t = time(0);
    long int now = static_cast<long int> (t);
    return now;
}

//Compare two frames and decide if there was motion
Mat core_loop()
{
	//report to console
		std::cerr << "frame_cap: initializing first three frames" << std::endl;
		
	//Capture Three frames
		Mat prev_frame = get_frame();
		Mat current_frame = get_frame();
		Mat next_frame = get_frame();
		Mat output = next_frame;
	
	//report to console
		std::cerr << "frame_cap: converting frames to grayscale" << std::endl;
	
	//Convert all three to grayscale
		cv::cvtColor(prev_frame, prev_frame, cv::COLOR_BGR2GRAY);
		cv::cvtColor(current_frame, current_frame, cv::COLOR_BGR2GRAY);
		cv::cvtColor(next_frame, next_frame, cv::COLOR_BGR2GRAY);
	
	//report to console
		std::cerr << "frame_cap: building data structs" << std::endl;
	
	// d1 and d2 for calculating the differences
    // result, the result of and operation, calculated on d1 and d2
    // number_of_changes, the amount of changes in the result matrix.
    // color, the color for drawing the rectangle when something has changed.
    Mat d1, d2, result, output_cropped;
	 int number_of_changes, number_of_sequence = 0;
    Scalar mean_, color(0,255,255); // yellow

    // Detect motion in window
    int x_start = 10, x_stop = current_frame.cols-11;
    int y_start = 40, y_stop = 500;

    // If more than 'there_is_motion' pixels are changed, we say there is motion
    // and store an image on disk
    int motion_threshold = 5;

    // Maximum deviation of the image, the higher the value, the more motion is allowed
    int max_deviation = 100;
	
	// Erode kernel
    Mat kernel_ero = getStructuringElement(MORPH_RECT, Size(2,2));
	
	// Time of last capturable screen
	long int last_trigger_time = 0;
	
	//report to console
		std::cerr << "frame_cap: setup complete" << std::endl;
		
	while(1)
	{
		//Take new frame and shift variables
		prev_frame = current_frame;
		current_frame = next_frame;
		next_frame = get_frame();
		output = next_frame;
		cv::cvtColor(next_frame, next_frame, cv::COLOR_BGR2GRAY);
		
		//Take differences between images and then use bitwise-AND
		absdiff(prev_frame, next_frame, d1);
		absdiff(next_frame, current_frame, d2);
		bitwise_and(d1, d2, result);
		threshold(result, result, 35, 255, CV_THRESH_BINARY);
		erode(result, result, kernel_ero);	
		
		//Check number of changes
		number_of_changes = detectMotion(result, output, output_cropped,  x_start, x_stop, y_start, y_stop, max_deviation, color);
		
		if(number_of_changes >= motion_threshold)
		{
			//report to console
				std::cerr << "frame_cap: * Motion detected *" << std::endl;
			//Check time since last capturable frame
			if( unix_timestamp() - last_trigger_time > min_capture_delay  || last_trigger_time == 0)
			{
				//Dont save or process first trigger
				if(last_trigger_time != 0)
				{
					//save frame, this will also trigger upload to twitter
					save_frame(output);	
				}
				
				//update trigger timestamp
				last_trigger_time = unix_timestamp();
								
			}
		}

	}
	return result;
}



int main( int argc, char** argv )
{	
	/*
	*	Triggers capture of three images, and comparason between them. Then
	*	a single frame is captured , and compared against the set. This is looped
	*	with each iteration having its comparason output to a function which
	*	checks how many pixels contain a change in color. If this meets threshold,
	*   motion is detected and an image is saved to the SD card.
	*/
	//Mat frame = core_loop();
	Mat frame = get_frame();
	save_frame(frame);					
}



















//reference
//https://blog.cedric.ws/opencv-simple-motion-detection