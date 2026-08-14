// TapTime NFC wall checkpoint — printable MVP
// Units: millimetres. Export `face_shell()` and `wall_plate()` separately.
$fn = 64;
W = 60; H = 60; R = 8;

module rounded_box(w,h,d,r) {
  linear_extrude(d) offset(r=r) square([w-2*r,h-2*r], center=true);
}

module face_shell() {
  difference() {
    rounded_box(W,H,8,R);
    // Hollow rear, leaving 2 mm face and 2.4 mm walls
    translate([0,0,2]) rounded_box(W-4.8,H-4.8,7,R-2.4);
    // 25.5 mm NFC sticker pocket, 1.2 mm deep behind face
    translate([0,0,0.8]) cylinder(h=1.3,d=25.5);
    // Four receiving sockets for wall-plate pegs
    for(x=[-22,22], y=[-22,22]) translate([x,y,1.8]) cylinder(h=6.4,d=3.45);
  }
}

module wall_plate() {
  difference() {
    union() {
      rounded_box(54.6,54.6,4,5.5);
      for(x=[-22,22], y=[-22,22]) translate([x,y,4]) cylinder(h=3.2,d1=3.2,d2=3.0);
    }
    // Two countersunk wall screw holes
    for(y=[-16,16]) {
      translate([0,y,-0.1]) cylinder(h=4.2,d=4.2);
      translate([0,y,2]) cylinder(h=2.2,d1=4.2,d2=8.2);
    }
    // Adhesive-tape relief / removal notch
    translate([0,-27,1.5]) cube([14,8,5],center=true);
  }
}

// Preview assembly. Comment one part and export the other as STL.
color("#078f98") translate([0,0,4]) face_shell();
color("#e8e7df") wall_plate();
