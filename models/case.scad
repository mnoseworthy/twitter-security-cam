// Intel Galileo v1 3D model
// Pierre Cauchois - 8/30/2014
// http://pierreca.github.io
// http://github.com/pierreca/galileo

pcb_height = 1.75; // z-axis
r_pin = 1.9;
r_hole = 2;
pin_height = 8;
pin_depth = pin_height+1;

/*
* Case parameters
*/
board_x_len = 105;
board_y_len = 12+23+37;
wall_thickness = 2.5;
wall_clearence = 2;
case_x_len = board_x_len+(wall_thickness+wall_clearence)*2;
case_y_len = board_y_len+(wall_thickness+wall_clearence)*2;
standoff_height = 17;
module case_bottom(x,y,z){
	color("gray") translate([x,y,z]) {
		/*
		* Bottom layer - w/ 4 corner holes
		*/
		difference() {
			translate([-(wall_thickness+wall_clearence),-(wall_thickness+wall_clearence),0])
				cube(size=[case_x_len, case_y_len, 2.5]);
			translate([4, 4, -1])cylinder(h = 7, r = 2.1);
			translate([101, 4, -1])cylinder(h = 7, r = 2.1);
			translate([4, 68, -1])cylinder(h = 7, r = 2.1);	
			translate([101, 68, -1])cylinder(h = 7, r = 2.1);
		}
		

		bottom_standoff(4,4,standoff_height/2);
		bottom_standoff(101,4,standoff_height/2);
		bottom_standoff(4,68,standoff_height/2);
		bottom_standoff(101,68,standoff_height/2);
		
		
	}
}

bottom_wall_height = standoff_height+17;
case_slot_width = wall_thickness/2;
case_slot_height = 5;
cutout_clearance = 1;
cutout_offset = wall_thickness+wall_clearence;

module case_bottom_walls(x,y,z) {
	color("red") translate([x,y,z]){
		difference() {
		translate([0,0,-12-2.5])
		linear_extrude(height = bottom_wall_height) {
		difference() {
			square([case_x_len,case_y_len]);
			translate([wall_thickness,wall_thickness,0])
				square([case_x_len-wall_thickness*2,case_y_len-wall_thickness*2]);
		}
		}//linear extrude

		

		//power-cutout
		translate([cutout_offset-1-14, cutout_offset+27.25-cutout_clearance/2, pcb_height])cube(size=[14+cutout_clearance, 9+cutout_clearance, 11+cutout_clearance]);

		//usb host/client cutouts	
		translate([wall_thickness/2 - cutout_clearance,0,-cutout_clearance*2]){
		translate([cutout_offset+47-2, cutout_offset+67-(cutout_clearance + 2)/2+6, pcb_height])cube(size=[8+cutout_clearance*2+2, 6+cutout_clearance*2+2, 3+cutout_clearance*2+2]);
		translate([cutout_offset+61-2, cutout_offset+67-(cutout_clearance + 2)/2+6, pcb_height])cube(size=[8+cutout_clearance*2+2, 6+cutout_clearance*2+2, 3+cutout_clearance*2+2]);
}
		//Ethernet Jack cutout
		translate([cutout_offset+15.5, cutout_offset+49-cutout_clearance/2+6, pcb_height])cube(size=[17+cutout_clearance, 24+cutout_clearance, 11+cutout_clearance]);

		}//difference
	}
}

case_top_height = 20;
case_top_thickness = 2.5;
top_standoff_height = 15+case_top_thickness;


module case_top(x,y,z){
	color("yellow") translate([x,y,z]) {
		/*
		* Bottom layer - w/ 4 corner holes
		*/
		difference() {
			translate([-(wall_thickness+wall_clearence),-(wall_thickness+wall_clearence),0])
				cube(size=[case_x_len, case_y_len, case_top_thickness]);
			
		}

		/*
		* Standoffs with throughholes
		*/
		difference () {		
			translate([4, 4, -top_standoff_height])cylinder($fn = 100, h = top_standoff_height, r = 4);				
			translate([4, 4, -top_standoff_height-1])cylinder($fn = 100, h = pin_depth + 1, r = r_hole);			
		}
		difference () {
			translate([101, 4,  -top_standoff_height])cylinder($fn = 100, h = top_standoff_height, r = 4);			
			translate([101, 4, -top_standoff_height-1])cylinder($fn = 100, h = top_standoff_height+2, r = r_hole);						
		}
		difference () {
			translate([4, 68,  -top_standoff_height])cylinder($fn = 100, h = top_standoff_height, r = 4);
			translate([4, 68, -top_standoff_height-1])cylinder($fn = 100, h = top_standoff_height+2, r = r_hole);
		}	
		difference () {
			translate([101, 68,  -top_standoff_height])cylinder($fn = 100, h = top_standoff_height, r = 4);
			translate([101, 68, -top_standoff_height-1])cylinder($fn = 100, h = top_standoff_height+2, r = r_hole);
		}
	}
}

module board(x, y, z) {
	color("teal") translate([x, y, z]) {
		difference() {
			cube(size=[105, 12, pcb_height]);
			translate([4, 4, -0.10])cylinder(h = 2, r = 2);
			translate([101, 4, -0.10])cylinder(h = 2, r = 2);
		}
		difference() {
			translate([0, 49, 0]) cube(size=[105, 23, pcb_height]);
			translate([4, 68, -0.10])cylinder(h = 2, r = 2);
			translate([101, 68, -0.10])cylinder(h = 2, r = 2);
		}
		hull() {
			translate([0, 12, 0]) cube(size=[105, 37, pcb_height]);
			translate([105, 14, 0]) cube(size=[2, 33, pcb_height]);
		}
	}
}

module ethernet_connector(x, y, z) {
	color("silver") translate([x, y, z]) {
		cube(size=[17, 24, 11]);
	}
}

module power_connector(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[14, 9, 11]);
	}
}

module sdcard(x, y, z) {
	color("silver") translate([x, y, z]) {
		cube(size=[15.5, 12, 2]);
	}
}

module audio_connector(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[7, 14, 6]);
	}
}
module usb_connector(x, y, z) {
	color("silver") translate([x, y, z]) {
		cube(size=[8, 6, 3]);
	}
}

module female_header(x, y, z, length) {
	color("black") translate([x, y, z]) {
		cube(size=[length, 2.5, 8.5]);
	}
}

module icsp_connector(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[5, 7.5, 9]);
	}
}

module white_connector(x, y, z) {
	color("white") translate([x, y, z]) {
		cube(size=[10, 5, 9]);
	}
}

module jumper_3pins(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[7.5, 2.5, 9]);
	}
}

module jumper_2pins(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[5, 2.5, 9]);
	}
}

module jtag_connector(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[13, 5, 5]);
	}
}

module quark(x, y, z) {
	translate([x, y, z]) {
		color("darkgreen") cube(size=[15, 15, 0.5]);
		color("dimgrey") translate([4.5, 4.5, 0.5]) cube(size=[6, 6, 0.5]);
	}
}

module bottom_connector1(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[29, 6, 9]);
		translate([0, 0, 2]) cube(size=[29, 8, 7]);
	}
}

module bottom_connector2(x, y, z) {
	color("black") translate([x, y, z]) {
		cube(size=[6, 6, 6]);
		translate([6, 1.5, 2]) cube(size=[17.5, 3, 2]);
		translate([23.5, 0, 0]) cube(size=[6, 6, 6]);
		translate([3, 3, 6]) cylinder(h = 4, r1 = 1, r2 = 0);
		translate([26.5, 3, 6]) cylinder(h = 4, r1 = 1, r2 = 0);
	}
}

module tactile_button(x, y, z) {
	translate([x, y, z]) {
		color("silver") cube(size=[4, 3, 1.5]);
		color("white") translate([2, 1, 1.5]) cylinder(h = 0.5, r = 1);
	}
}

module galileo_v1(x, y, z) {
	translate([x, y, z]) {

		board(0,0,0);
		ethernet_connector(15.5, 49, pcb_height);
		power_connector(-1, 27.25, pcb_height);
		sdcard(0, 12, pcb_height);
		audio_connector(36, 60, pcb_height);
		usb_connector(47, 67, pcb_height);
		usb_connector(61, 67, pcb_height);
		female_header(65, 10, pcb_height, 20);
		female_header(87.5, 10, pcb_height, 15);
		female_header(56, 58, pcb_height, 25);
		female_header(83, 58, pcb_height, 20);
		icsp_connector(101, 33, pcb_height);
		white_connector(85, 65, pcb_height);
		jumper_3pins(65, 6, pcb_height);
		jumper_2pins(75, 6, pcb_height);
		jumper_2pins(35, 16, pcb_height);
		rotate([0, 0, 90]) jumper_3pins(63.5, -13.5, pcb_height);
		jtag_connector(18, 1, pcb_height);
		quark(51.5, 25, pcb_height);
		tactile_button(11, 1, pcb_height);
		tactile_button(67, 1, pcb_height);
		bottom_connector1(32.5, 3.5, -9);
		rotate([180, 0, 0]) bottom_connector2(32, -52, 0);

		case_bottom(0,0,-17);
		case_bottom_walls(-wall_thickness-wall_clearence,-wall_thickness-wall_clearence,0);

		case_top(0,0,standoff_height+case_top_thickness);
	}
}

galileo_v1();

module top_standoff(x,y,z){
	translate([x,y,z]){
	rotate(a=[0,180,0])
		/*
		* Standoffs with throughholes
		*/
		difference () {		
			translate([4, 4, -top_standoff_height])cylinder($fn = 100 ,h = top_standoff_height, r = 4);				
			translate([4, 4, -top_standoff_height-1])cylinder($fn = 100 ,h = pin_depth + 1, r = r_hole);			
		}
	}


}
module bottom_standoff(x,y,z){
	translate([x,y,z]){
	rotate(a=[0,0,0])
		/*
		* Standoffs with throughholes
		*/
		union () {		
			translate([0, 0, 0])cylinder($fn = 100 ,h = standoff_height, r = 4, center = true);
			rotate(a=[180,0,0]){ translate([0,0,(-standoff_height/2 -pin_height/2)])pin(pin_height, r_hole, 60); }	
		}
	}
        
}


module pin(height, r, angle){
    color("white") translate([0, 0, 0]) {
      difference(){
         cylinder($fn = 8, r=r, h=pin_height, center = true);
          translate([0,0,2.5-pin_height/2+0.5]){
         for(theta = [0:45:360]){
            
            rotate(a=[0,0,theta]){
            rotate(a=[angle,angle,45/2]){
                translate([r*1.8,-0.2,0])
                cube(size=[3.14152/r,3.14152/r, 2], center = true);
            }}}
        }
        translate([0,0,pin_height])sphere(r = 2);
      }
        }
        
}
