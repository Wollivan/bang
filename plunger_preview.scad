include <plunger_common.scad>

state = "cocked"; // [safe, cocked, fired]
cutaway = false;
show_band = true;

// change where the cutaway is so you can actually see the little nub things position
cut_angle = state == "cocked" ? deg(ramp_s0 + ramp_rest/2) : state_turn(state);
if (cutaway)
    difference() {
        rotate([0, 0, 90 - cut_angle]) assembly(state);
        translate([0, -2*body_h, -2*body_h]) cube(4*body_h);
    }
else {
    assembly(state);
    if (show_band) color("Goldenrod") band(state);
}
