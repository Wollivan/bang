/* [Body] */
body_d = 33;
// Bottom face to rim
body_h = 39;
floor_t = 5;
// 45° chamfer on the bottom (bed) edge; rounded top edges
bed_chamfer = 0.8;
round_r = 1.5;

/* [Ring cap: measure yours with calipers] */
// Diameter of the circle through the cup centres
cap_pitch_d = 19;
// Inside diameter of a cup, measured at the open (underside) end
cup_id = 3;
// Outside diameter of a cup
cup_od = 5;
// Inside depth of a cup, from the open end to the compound
cup_depth = 3.4;
// Overall height: flat underside of the ring to the cup tops
cap_height = 6.5;
// Ring centre hole
ring_id = 13;
// Ring outside diameter
ring_od = 24;
// Web thickness (preview only)
ring_web = 0.8;

/* [Trigger] */
// How far the band drives the plunger onto the caps
stroke = 7;
// Plunger face height above the caps when safe
safe_lift = 5;
// Slope of the ramp down into each slot. Steeper is twitchier
ramp_angle = 0;
// How far each tab rests onto its ramp when cocked. Shorter is twitchier
ramp_rest = 4;
// Hump between ramp and pocket: height above the ramp top, and width
hump_h = 1;
hump_w = 1.5;
// Plain rim height above the hump tops (the stops)
stop_h = 2;

/* [Tabs] */
tab_w = 4;
// How far the tabs reach out from the centre (inside body_d/2)
tab_r = 16;
// Thickness above the 45° seat
tab_t = 2;
// Clearance around a tab in its slot and pocket
tab_clear = 0.8;
// How far below the fired tabs the slots go
slot_extra = 1.5;

/* [Plunger] */
// Radial clearance in the bore
plunger_clear = 0.4;
head_d = 25.2;
head_h = 9.6;

/* [Firing] */
// Strikers on the plunger face, one over each cup
striker_d = 3;
striker_h = 1;
// Pin cones: base this much thinner than cup_id, narrowing by pin_taper
// to the tip, so they lead into the cups and are stout at the root
pin_clearance = 0.2;
pin_taper = 0.8;
// Pins are this much longer than cup_depth, so load goes through the
// compound instead of the ring web resting on the floor
pin_lift = 0.6;
// Pin ring turned off the band groove line, which crosses the floor
pin_rot = 22.5;

/* [Rubber band] */
// Direction of the band across both ends; in the plain rim between tracks
band_angle = 88;
// Direction of the head groove when fired. Short of band_angle, to take some
// twist off the catch when cocked
head_groove_angle = 84;
// Width of the V grooves across the ends (depth is half this)
groove_w = 6;
// Side grooves down the body, ending in a notch through the rim edge, so
// each strand is held off the tab tracks
side_groove_w = 3;
side_groove_d = 1.5;

/* [Vents: round holes in straight rows, like an M84] */
vent_d = 5.5;
vent_z = [3.25, 10, 16.75];
vents_per_row = 6;
// Columns sit midway between the band grooves
vent_rot = band_angle + 30;

$fn = 96; //2187 ... RAY!

// ---- layout (z = 0 on the floor the cap sits on, plunger fired) ----
body_r = body_d / 2;
bore_r = ring_od/2 + 1;
plunger_r = bore_r - plunger_clear;
pin_d = cup_id - pin_clearance;
pin_h = cup_depth + pin_lift;
gap = pin_lift + cap_height + striker_h;   // plunger face height when fired
// Uneven so two plain stretches of rim sit opposite each other for the band.
// Every gap is under 180° so the three seats still carry the plunger.
tab_angles = [0, 105, 210];

z_rim = body_h - floor_t;
hump_top = z_rim - stop_h;
ramp_rise = ramp_rest * tan(ramp_angle);
z_cock = hump_top - hump_h - ramp_rise;    // tab seat height at the bore edge, cocked
z_safe = z_cock - stroke + safe_lift;      // pocket floor
z_tab = z_cock - stroke;                   // same, fired
slot_floor = z_tab - slot_extra;

// Track lengths are arc lengths at the middle of the tab
r_mid = (bore_r + tab_r) / 2;
function deg(s) = s * 180 / (PI * r_mid);
slot_w = tab_w + tab_clear;
pocket_w = tab_w + tab_clear;
ramp_s0 = slot_w / 2;
hump_s0 = ramp_s0 + ramp_rest;
pocket_s0 = hump_s0 + hump_w;
stop_s0 = pocket_s0 + pocket_w;
// Plunger turn from fired. Cocked: the tab's anticlockwise edge against the
// hump. Safe: the tab against the pocket's clockwise wall.
cock_deg = deg(hump_s0 - tab_w/2);
safe_deg = deg(pocket_s0 + tab_w/2);

shaft_top = z_rim + 0.5;
head_r = head_d / 2;
head_z0 = shaft_top + (plunger_r - head_r);
top_z = head_z0 + head_h;
seat_top = z_tab + (tab_r - bore_r) + tab_t; // flat top of the tabs

echo(str("body ", body_d, " x ", body_h,
         ", overall fired ", top_z + floor_t, ", cocked ", top_z + floor_t + stroke,
         ", cock turn ", cock_deg, "°, safe turn ", safe_deg, "°"));

assert(body_r - tab_r >= 0.3, "tabs stick out of the body: raise body_d or lower tab_r");
assert(body_r - bore_r >= 2.5, "body wall too thin");
assert(tab_r - bore_r >= 2, "tabs too short to bear on the rim");
assert(ramp_rest <= tab_w, "ramp_rest can't be longer than the tab");
assert(safe_lift < stroke - 1, "safe pockets must sit below the cocked ramps");
// Band strands must clear every track, side groove width included
band_half = asin(side_groove_w/2 / body_r);
assert(deg(stop_s0) < band_angle - band_half - 2, "band crosses a tab track: change band_angle");
assert(band_angle + band_half < tab_angles[1] - deg(slot_w/2) - 2, "band runs into a slot: change band_angle");
assert(band_angle + 180 - band_half > tab_angles[2] + deg(stop_s0) + 2, "far strand crosses a tab track: change band_angle");
assert(band_angle + 180 + band_half < 360 - deg(slot_w/2) - 2, "far strand runs into a slot: change band_angle");
assert(body_r - side_groove_d - bore_r >= 1.5, "wall too thin under the side grooves");
assert(floor_t - groove_w/2 >= 1.5, "floor too thin over the band groove");
assert(vent_z[len(vent_z)-1] + vent_d/2 < slot_floor - 1, "top vent row runs into the slots");
assert(vent_z[0] - vent_d/2 >= 0, "bottom vent row cuts into the floor");
assert(head_h - groove_w/2 >= 3, "head too short for its band groove");
assert(head_r <= plunger_r, "head wider than the plunger");
assert(striker_d <= cup_od, "strikers wider than the cups");
assert(cap_pitch_d/2 + striker_d/2 < plunger_r - 0.6, "strikers run off the plunger face");

// ---- helpers ----
// Solid between radii r0 and r1, above a floor that follows prof, a list of
// [angle, height at the bore edge] in increasing angle, up to height top at
// r0 and top1 at r1. The floor rises 45° outward (the seat cone). Vertical
// steps are two points a hair apart. Triangulated so helical floors stay valid.
module sector(prof, r0, r1, top, top1) {
    n = len(prof);
    pts = [for (p = prof) let(c = cos(p[0]), s = sin(p[0]), h0 = p[1] + r0 - bore_r, h1 = p[1] + r1 - bore_r) each
           [[r0*c, r0*s, h0], [r1*c, r1*s, h1], [r1*c, r1*s, top1], [r0*c, r0*s, top]]];
    function P(i, j) = 4*i + j;
    function tri(q) = [[q[0], q[1], q[2]], [q[0], q[2], q[3]]];
    faces = concat(
        [for (i = [0 : n-2]) each concat(
            tri([P(i,0), P(i,1), P(i+1,1), P(i+1,0)]),    // floor
            tri([P(i,1), P(i,2), P(i+1,2), P(i+1,1)]),    // outer
            tri([P(i,0), P(i+1,0), P(i+1,3), P(i,3)]),    // inner
            tri([P(i,3), P(i+1,3), P(i+1,2), P(i,2)]))],  // top
        tri([P(0,0), P(0,3), P(0,2), P(0,1)]),
        tri([P(n-1,0), P(n-1,1), P(n-1,2), P(n-1,3)]));
    polyhedron(pts, faces);
}

e = 0.01;
ramp_steps = 6;
// One tab's rim track, angles from its slot centre, covering 120°
track = concat(
    [[-60, z_rim], [deg(-slot_w/2), z_rim], [deg(-slot_w/2) + e, slot_floor],
     [deg(ramp_s0), slot_floor]],
    [for (i = [0 : ramp_steps]) [deg(ramp_s0 + ramp_rest*i/ramp_steps) + (i == 0 ? e : 0),
                                 z_cock + ramp_rise*i/ramp_steps]],
    [[deg(hump_s0) + e, hump_top], [deg(pocket_s0), hump_top], [deg(pocket_s0) + e, z_safe],
     [deg(stop_s0), z_safe], [deg(stop_s0) + e, z_rim], [60 + e, z_rim]]);

// Tab seat: plain, then rising at ramp_angle over its last stretch so it sits
// flush on the ramp when cocked. The stretch stops short of the whole tab
tab_deg = deg(tab_w);
tab_slope = min(ramp_rest, tab_w - 0.5);
tab_floor = concat(
    [[-tab_deg/2, z_tab]],
    [for (i = [0 : ramp_steps]) [deg(tab_w/2 - tab_slope + tab_slope*i/ramp_steps),
                                 z_tab + tab_slope*tan(ramp_angle)*i/ramp_steps]]);

// Outer profile with a 45° bed chamfer and a rounded top edge
module rounded_cylinder(r, z0, z1, ch, rr) {
    rotate_extrude() polygon(concat(
        [[0, z0], [r - ch, z0], [r, z0 + ch]],
        [for (a = [0 : 15 : 90]) [r - rr + rr*cos(a), z1 - rr + rr*sin(a)]],
        [[0, z1]]));
}

// 45° V groove across the face at height z, cut toward dir (+1 up into a
// bottom face, -1 down into a top face)
module v_groove(z, dir, angle = band_angle) {
    rotate([0, 0, angle]) translate([-body_r - 5, 0, z - dir*0.01])
        rotate([90, 0, 90]) linear_extrude(2*body_r + 10)
            polygon([[-groove_w/2, 0], [groove_w/2, 0], [0, dir*groove_w/2]]);
}

module hole_x(d, x0, x1) {
    translate([x0, 0, 0]) rotate([0, 90, 0]) cylinder(d = d, h = x1 - x0, $fn = 48);
}

module pin_positions() {
    for (i = [0 : 7]) rotate([0, 0, pin_rot + i*45]) translate([cap_pitch_d/2, 0, 0]) children();
}

module pins() {
    c = 0.3; // entry chamfer
    r0 = pin_d / 2;
    r1 = r0 - pin_taper / 2;
    pin_positions() rotate_extrude($fn = 48)
        polygon([[0, -0.5], [r0, -0.5], [r0, 0], [r1, pin_h - c], [r1 - c, pin_h], [0, pin_h]]);
}

// ---- parts (assembled coordinates, plunger fired) ----
module body() {
    difference() {
        rounded_cylinder(body_r, -floor_t, z_rim, bed_chamfer, round_r);
        cylinder(r = bore_r, h = body_h);
        translate([0, 0, z_rim - 0.5]) cylinder(r1 = bore_r, r2 = bore_r + 0.6, h = 0.51);  // lead-in
        for (a = tab_angles) rotate([0, 0, a]) sector(track, bore_r - 1, body_r + 2, z_rim + 10, z_rim + 10);
        for (z = vent_z, k = [0 : vents_per_row - 1])
            rotate([0, 0, vent_rot + k * 360 / vents_per_row])
                translate([0, 0, z]) hole_x(vent_d, bore_r - 1, body_r + 1);
        v_groove(-floor_t, 1);
        for (a = [band_angle, band_angle + 180]) rotate([0, 0, a])
            translate([body_r - side_groove_d, -side_groove_w/2, -floor_t - 1]) cube([5, side_groove_w, body_h + 2]);
    }
    pins();
}

// 45° cone seat underneath, 45° slope on top falling toward the tip, so it
// prints head-down without support
module tab() {
    r0 = plunger_r - 1;
    sector(tab_floor, r0, tab_r, seat_top + tab_r - r0, seat_top);
}

module plunger() {
    difference() {
        rotate_extrude() polygon(concat(
            [[0, gap], [plunger_r - 0.6, gap], [plunger_r, gap + 0.6], [plunger_r, shaft_top]],
            // The top edge rounds to 45°, then runs straight to the bed
            [for (a = [0 : 15 : 45]) [head_r - round_r + round_r*cos(a), top_z - round_r + round_r*sin(a)]],
            [[head_r - round_r + round_r*cos(45) - round_r*(1 - sin(45)), top_z], [0, top_z]]));
        v_groove(top_z, -1, head_groove_angle);
    }
    for (a = tab_angles) rotate([0, 0, a]) tab();
    pin_positions() translate([0, 0, gap - striker_h]) cylinder(d = striker_d, h = striker_h + 0.5, $fn = 48);
}

// Quick print to check cap fit before committing to the full body
module gauge() {
    translate([0, 0, -2]) cylinder(d = ring_od + 4, h = 2);
    pins();
}

module ring_cap() {
    translate([0, 0, pin_lift]) difference() {
        union() {
            difference() {
                cylinder(d = ring_od, h = ring_web);
                translate([0, 0, -1]) cylinder(d = ring_id, h = ring_web + 2);
            }
            pin_positions() cylinder(d = cup_od, h = cap_height);
        }
        pin_positions() translate([0, 0, -1]) cylinder(d = cup_id, h = cup_depth + 1);
    }
}

// ---- print orientation ----
module body_print() { translate([0, 0, floor_t]) body(); }
module plunger_print() { translate([0, 0, top_z]) rotate([180, 0, 0]) plunger(); }
plate_spacing = body_d + 6;

// ---- states ----
function state_lift(state) = state == "cocked" ? stroke : state == "safe" ? safe_lift : 0;
function state_turn(state) = state == "cocked" ? cock_deg : state == "safe" ? safe_deg : 0;
module place_plunger(state) {
    translate([0, 0, state_lift(state)]) rotate([0, 0, state_turn(state)]) children();
}

module assembly(state = "cocked") {
    color("DimGray") body();
    color("Red") ring_cap();
    color("Gray") place_plunger(state) plunger();
}

// ---- band (preview only) ----
module band(state = "cocked") {
    lift = state_lift(state);
    turn = state_turn(state);
    side_r = body_r - side_groove_d + 1.25;
    function P(a, r, z) = [r*cos(a), r*sin(a), z];
    pts = [P(band_angle, side_r, -floor_t + 1), P(band_angle, side_r, z_rim),
           P(head_groove_angle + turn, head_r, top_z + lift), P(head_groove_angle + 180 + turn, head_r, top_z + lift),
           P(band_angle + 180, side_r, z_rim), P(band_angle + 180, side_r, -floor_t + 1)];
    for (i = [0 : len(pts) - 1])
        hull() {
            translate(pts[i]) sphere(d = 2.5, $fn = 8);
            translate(pts[(i + 1) % len(pts)]) sphere(d = 2.5, $fn = 8);
        }
}
