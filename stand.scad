Vertical_Length=50;
Extrude=5;
Horizontal=50;
x_axis=50;
wall_thickness=2;

difference()
    {
    translate([((x_axis-Extrude)/2),0,0])
{
    cube([Extrude, Horizontal, Vertical_Length], center=false);
}
       
 translate([0,Horizontal/2,Vertical_Length-40]){
       rotate(a=[0,90,0]){

            cylinder(h=150, r=5.5, center=false);}}

        }



    translate([0,Horizontal-10,0])
        {
        cube([x_axis,10,5]);
        }
    translate([0,0,0])
        {
        cube([x_axis,10,5]);
        }
    
        difference(){
            translate([((x_axis-Extrude)/2)-20,Horizontal-32-wall_thickness,0]){
                cube([20,Horizontal-36+(wall_thickness*2),21.5]);
            }
            translate([((x_axis-Extrude)/2)-20,Horizontal-32,4.5]){
        cube([20,Horizontal-36,15]);
    }
    }
        translate([2.5,Horizontal-30,4.5]){
            cube([2,10,2]);}