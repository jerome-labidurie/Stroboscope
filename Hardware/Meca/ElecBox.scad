/** Box fort electronic pojects
 * Licence: CC-BY-SA
 */

/* [Parameters] */

// Wich object to create ?
Object = "Both"; // [Box, Lid, Both]
// Inner box length (mm)
InnerBoxLength = 110;
// Inner box width (mm)
InnerBoxWidth = 40;
// Inner box height (mm)
InnerBoxHeight = 35;
// Walls thickness (mm)
BoxThick = 2;
// Screw diameter (mm)
ScrewSize = 3;

// Resolution
$fn = 60;

/* [Hidden] */
 // wall size around screw
ScrewWall = 2;
// internal variables
BoxLength = InnerBoxLength + ScrewSize + ScrewWall;
BoxWidth = InnerBoxWidth + ScrewSize + ScrewWall;
BoxHeight = InnerBoxHeight;

use <fablab.scad>

/** Customize the Lid
 * Starting point is bottom left, when lid is seen from top
 */
module CustomLid () {
	/** rotary encoder */
	translate ([15,InnerBoxWidth-12,0]) rotate ([0,0,90])
		union () {
			cylinder (d=8, h=BoxThick); // shaft
			translate ([-10, 8, 0]) cylinder (d=4, h=BoxThick); // screw
			translate ([-10, 8, BoxThick/2]) cylinder (d=5.5, h=BoxThick/2); // screw head
			translate ([6.5, 8, 0]) cylinder (d=4, h=BoxThick); // screw
			translate ([6.5, 8, BoxThick/2]) cylinder (d=5.5, h=BoxThick/2); // screw head
		}

	/** screen 1602A */
	translate ([30,(InnerBoxWidth-31.4)/2,0])
		union() {
			// screw holes
			ys = 31.4; // inter holes y
			xs = 75.4; // inter holes x
			cylinder (d=4.5, h=BoxThick);
			translate ([0,ys,0])
				cylinder (d=4.5, h=BoxThick);
			translate ([xs,ys,0])

				cylinder (d=4.5, h=BoxThick);
			translate ([xs,0,0])
				cylinder (d=4.5, h=BoxThick);
			translate ([2.35,3.8,0])
				cube ([72,25,BoxThick]); // screen
		}
}

/** Customize the front face of the Box
 * Starint point is bottom left when Box is seen from front.
 */
module CustomFace () {
	/** Pot hole */
	translate ([10, 10, 0])
		cylinder (d=8, h=BoxThick);
	/** in hole */
	translate ([InnerBoxLength - 10, 10, 0]) {
		translate ([-3,5,BoxThick/2])
			linear_extrude(BoxThick/2) {
				text ("IN", font="Liberation Sans:style=Bold", size=4);
			}
		cylinder (d=8, h=BoxThick);
	}
	/** Out hole */
	translate ([InnerBoxLength - 30, 10, 0]) {
		translate ([-5,5,BoxThick/2])
			linear_extrude(BoxThick/2) {
				text ("OUT", font="Liberation Sans:style=Bold", size=4);
			}
		cylinder (d=8, h=BoxThick);
	}
	translate ([InnerBoxLength - 25,7,BoxThick/2])
		linear_extrude(BoxThick/2) {
			text ("12V", font="Liberation Sans:style=Bold", size=4);
		}
}

/** Customize the back face of the Box
 * Starint point is bottom left when Box is seen from front.
 */
module CustomFace2 () {
	/** logo fablab */
	translate ([InnerBoxLength/2,InnerBoxHeight/2,BoxThick/2])
		resize ([30,0,BoxThick/2], auto=true)
			logo_fablab(BoxThick/2, 1.0);
}

/** Internal Code */

/* Box */
module FullBox () {
	difference () {
		union () {
			difference () {
				minkowski () { // main body
					cube ([BoxLength, BoxWidth, BoxHeight], center=true);
					sphere (r = BoxThick);
				}
				// remove inside hole
				cube ([BoxLength, BoxWidth, BoxHeight], center=true);
			}
			// screw terminals
			for ( x = [-1,1] ) {
				for ( y = [-1,1] ) {
					translate ([x * (BoxLength-BoxThick)/2, y * (BoxWidth-BoxThick)/2, 0]) {
						cylinder (d=ScrewSize + ScrewWall, h=BoxHeight, center=true);
					}
				}
			}
		}
		// screw holes
		for ( x = [-1,1] ) {
			for ( y = [-1,1] ) {
				translate ([x * (BoxLength-BoxThick)/2, y * (BoxWidth-BoxThick)/2, BoxThick/2]) {
					cylinder (d=ScrewSize, h=BoxHeight+BoxThick, center=true);
				}
			}
		}
	}
}

module Box () {
	difference () {
		FullBox();
		// remove Lid
		translate ([0,0,BoxHeight])
			cube ([BoxLength+2*BoxThick, BoxWidth+2*BoxThick, BoxHeight], center=true);
		// add (ie:remove) customiztion 1
		translate ([-InnerBoxLength/2, -(BoxWidth)/2, -BoxHeight/2])
			rotate ([90,0,0])
				CustomFace();
		// add (ie:remove) customiztion 2
		translate ([InnerBoxLength/2, (BoxWidth)/2, -BoxHeight/2])
			rotate ([270,180,0])
				CustomFace2();
	}
}

module Lid () {
	difference () {
		FullBox();
		// remove Box
		translate ([0,0,-BoxThick/2])
			cube ([BoxLength+2*BoxThick, BoxWidth+2*BoxThick, BoxHeight+BoxThick], center=true);
		// add (ie: remove) customization
		translate ([-(InnerBoxLength)/2,-InnerBoxWidth/2,BoxHeight/2]) {
			CustomLid();
		}
	}
}

module Both() {
	translate ([-(BoxLength+3*BoxThick)/2, 0, 0]) Box();
	translate ([ (BoxLength+3*BoxThick)/2, 0, -(BoxHeight+BoxThick)]) Lid();
}

if (Object == "Box") {
	Box();
} else if (Object == "Lid") {
	Lid();
} else {
	Both();
}
