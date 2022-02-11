

// Size of interior cavity of inner box.  The opening faces -X
inner_box_inner_size = [ 50, 60, 5 ];

num_sliders = 5;

// Array of string labels to use for numeric slider positions
numeric_positions = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ];
alpha_positions = [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" ];
// Array, indexed by slider number, of arrays of positions for that slider.
//slider_positions = [ for (i = [ 0 : num_sliders ]) numeric_positions ];
slider_positions = [ for (i = [ 0 : num_sliders ]) alpha_positions ];

// Inner box wall thicknesses
inner_box_wall_thick = 1.2;
inner_box_bottom_thick = 0.95;
inner_box_top_thick = 1.5;
inner_box_end_plate_thick = 2; // thickness of base plate and handles on inner box
inner_box_side_handle_protrusion = 1.5; // amount handles protrude to the side of the inner box
// Calculated inner box main outer dimensions, not including rails and pins on the top, or handle on the front.
inner_box_main_outer_size = inner_box_inner_size + [
    0, // main width of inner box is open at both ends; the end plate caps off one of these ends
    2 * inner_box_wall_thick,
    inner_box_bottom_thick + inner_box_top_thick
];

// The amount of sliding play/clearance the inner box has inside the outer box in the Y dimension
inner_box_play_y = 0.6;

// Minimum height of intersection between pins on inner box and gate fins on the sliders.
gate_pin_contact_height = 1.5;
// Thickness of the bottom wings
slider_bottom_thick = 1.5;
// Amount of play/clearance between slider wings and the slot it rides in.
slider_wing_play_z = 0.2;
// The minimum amount of clearance between the gates on the bottom of the sliders, and the top of the inner box.
gate_inner_box_top_clearance_z = 0.2;
// Height that the pins rise above the top of the inner box.
inner_box_pin_height = gate_pin_contact_height + gate_inner_box_top_clearance_z + slider_wing_play_z;
// Minimum clearance between the tops of the pins on the inner box and the bottoms of the slider wings & detent arm
pin_wing_clearance_z = 0.2;

// Depth of scale markings
scale_mark_height = 0.3;
// Width/thickness of scale marking lines
scale_mark_width = 0.4;

// Minimum thickness at thinnest point of outer box top
outer_box_min_top_thick = 1.7;
// Thickess of the slider top wing plate
slider_top_wing_thick = 1.2;
// Depth of the detent hole
detent_height = 0.7;
// Thickness of the outer box top at its thickest point
outer_box_top_thick = outer_box_min_top_thick + max(slider_top_wing_thick + detent_height, scale_mark_height);
// Thickness of the bottom wing; thicker values are stiffer but bulkier
slider_bottom_wing_thick = 1.5;

// Size of inner cavity in outer box.
outer_box_inner_size = inner_box_main_outer_size + [
    0,
    inner_box_play_y,
    inner_box_pin_height + pin_wing_clearance_z + slider_bottom_wing_thick + slider_wing_play_z
];
outer_box_wall_thick = 1.5;
outer_box_bottom_thick = 0.95;
outer_box_outer_size = outer_box_inner_size + [ outer_box_wall_thick, 2 * outer_box_wall_thick, outer_box_bottom_thick + outer_box_top_thick ];

// The clearance between the tops of the rails on the inner box and the bottom of the outer box lid.
inner_box_top_rail_play_z = 0.3;
// The height of the top rails on the inner box.
inner_box_top_rail_height = outer_box_inner_size.z - inner_box_main_outer_size.z - inner_box_top_rail_play_z;

// Clearance between each slider and either the adjacent slider or the slot wall in the X dimension
slider_top_wing_clearance_x = 0.3;

// Width of margins on the +x and -x sides of the box topa
outer_box_top_margins_x_min = outer_box_outer_size.x / 10; // can be an arbitrary number
outer_box_top_margins_x = max(outer_box_top_margins_x_min, outer_box_wall_thick);

// Effective width on the top of the outer box that can be used for sliders.
effective_slider_area_width = outer_box_outer_size.x - 2*outer_box_top_margins_x - 2*slider_top_wing_clearance_x;
// The target width of the walls between sliders.  This is arbitrary, and can be 0.
target_between_slider_wall_width = (1/30) * effective_slider_area_width;
// Minimum wall width.  If target is below the minimum, walls will be removed entirely.
min_between_slider_wall_width = 2;
// The chosen width of walls in between sliders, or 0 to indicate no walls.
between_slider_wall_width = target_between_slider_wall_width >= min_between_slider_wall_width ? target_between_slider_wall_width : 0;
echo("Between Slider Wall Width", between_slider_wall_width);

// The amount of X space in between the top wings of adjacent sliders.  Depends on whether or not there are walls between.
slider_top_wing_width_between = between_slider_wall_width > 0 ? (between_slider_wall_width + 2*slider_top_wing_clearance_x) : slider_top_wing_clearance_x;
// Space between sliders
slider_spacing = (effective_slider_area_width - slider_top_wing_width_between * (num_sliders - 1)) / num_sliders + slider_top_wing_width_between;
// Width of the top plate on the slider
slider_top_wing_width = slider_spacing - slider_top_wing_width_between;
// The X coordinate of each of the sliders, centered on the slider.
sliders_x = [ for (i = [ 0 : num_sliders-1 ]) outer_box_top_margins_x + slider_top_wing_clearance_x + slider_top_wing_width/2 + i * slider_spacing ];
echo("First/Last Slider Edge Distances", sliders_x[0], outer_box_outer_size.x - sliders_x[len(sliders_x) - 1]);
//assert(sliders_x[0] == outer_box_outer_size.x - sliders_x[len(sliders_x) - 1]); // first and last slider are equidistant from their nearest edge

// Length of the connector between the top and bottom parts of the slider.  Larger values are stronger but reduce travel length and compress symbols.  The multiplier is arbitrarily chosen.  This is the main parameter to tweak for altering travel distance vs slider stabilization in this dimension.
slider_connector_length = (1/12) * outer_box_outer_size.y;

// The length of the part of the slot that the slider travels in
slot_travel_length = (1/3) * outer_box_outer_size.y + (2/3) * slider_connector_length;
// The distance that the slider can travel
slider_travel_length = slot_travel_length - slider_connector_length;
// Offset from the slot to the outer edge of the box
slot_edge_offset = (1/3) * (outer_box_outer_size.y - slider_connector_length);
// Length/depth of the top wing/plate on the slider
slider_top_wing_length = (2/3) * (outer_box_outer_size.y - slider_connector_length) + slider_connector_length;

// Width of the 'connector' portion of the slider, the part that rides in the slots.  The multiplier here is arbitrarily chosen.
slider_connector_width = (1/5) * slider_spacing;
// Amount of play the slider has in the X dimension
slider_play_x = 0.3;
// The width of the slots in the box
slot_width = slider_connector_width + slider_play_x;


// Amount the handle on the slider protrudes
slider_handle_height = 1.5;
// Diameter of the handle bump
slider_handle_depth = slider_top_wing_length / 8;
// Height of connecting piece of slider
slider_connector_height = outer_box_top_thick - slider_top_wing_thick + slider_wing_play_z;
// Width of bottom wing right-of-center.
slider_bottom_wing_width_right = slider_top_wing_width / 2;
// Width of bottom wing left-of-center.  Can be reduced so long as it doesn't drop below half the connector width.
slider_bottom_wing_width_left = max(slider_bottom_wing_width_right / 2.5, slider_connector_width / 2);


// The Y coordinate corresponding to the center of the slider [connector segment] in its near position.  (In coordinate space of outer box)
slider_positions_y_begin = slot_edge_offset + slider_connector_length / 2;
// The Y coordinate corresponding to the center of the slider [connector segment] in its far position
slider_positions_y_end = outer_box_outer_size.y - slider_positions_y_begin;
echo("Slider travel length compare", slider_positions_y_end - slider_positions_y_begin, slider_travel_length);
//assert(slider_positions_y_end - slider_positions_y_begin == slider_travel_length);  // Make sure the slider travel length equals the spacing between first and last position
// Space between positions of the slider for each slider
slider_positions_spacing = [ for (i = [ 0 : num_sliders - 1 ]) (slider_positions_y_end - slider_positions_y_begin) / (len(slider_positions[i]) - 1) ];
// Y coordinates corresponding to the center of the slider for each slider position for each slider.  The first position is slider_positions_y_end and positions are evenly spaced.
slider_positions_y = [
    for (i = [ 0 : num_sliders - 1 ])
        [ for (j = [ len(slider_positions[i]) - 1 : -1 : 0 ])
            slider_positions_y_begin + j * slider_positions_spacing[i]
        ]
];
// Minimum opening span of the slider gates
min_gate_opening = 2.5;
// Size of openings in the slider gate
slider_gate_opening = [ for (i = [ 0 : num_sliders - 1 ]) max(min_gate_opening, slider_positions_spacing[i]) ];
// Depth (Y dimension/length) of gate at bottom of slider
slider_gate_depth = max([ for (i = [ 0 : num_sliders - 1 ]) slider_positions_y[i][0] - slider_positions_y[i][len(slider_positions_y[i]) - 1] + slider_gate_opening[i] ]);
// Width of slider gate.  Value is arbitrary and partly controls strength of gates versus strength of pins.
slider_gate_width = 0.5 * slider_bottom_wing_width_right;
assert(slider_gate_width < slider_bottom_wing_width_left + slider_bottom_wing_width_right - slider_gate_width);
// Extra clearance between bottom of slider gate and top of inner box, in addition to existing plays and clearances.
slider_gate_inner_box_top_clearance_extra = 0;
// Height of the gate component of the slider
slider_gate_height = outer_box_inner_size.z - inner_box_main_outer_size.z - slider_bottom_wing_thick - slider_wing_play_z - inner_box_top_rail_play_z - slider_gate_inner_box_top_clearance_extra;
echo("slider_bottom_wing_width_right", slider_bottom_wing_width_right);
echo("slider_bottom_wing_width_left", slider_bottom_wing_width_left);
echo("slider_gate_depth", slider_gate_depth);
echo("slider_positions_y[0][0]", slider_positions_y[0][0]);
echo("slider_positions_y[0][len(slider_positions_y[0]) - 1]", slider_positions_y[0][len(slider_positions_y[0]) - 1]);
echo("slider_gate_opening", slider_gate_opening);

// Clearances around box front cutouts for inserting sliders
outer_box_front_slider_cutout_clearance = 0.2;
// Clearance between bottom wing of slider and the top rails in the first and last positions
bottom_wing_top_rail_clearance = 0.2;
// Width of the top rails on the inner box
inner_box_top_rail_depth = slider_positions_y_begin - slider_gate_depth / 2 - outer_box_wall_thick - bottom_wing_top_rail_clearance;

// Amount of clearance in the X dimension between a pin and its gate when the box is closed.
pin_gate_closed_clearance_x = 0.2;
// Size of pin in X dimension.  This is calculated to fit underneath the individual slider's top wing footprint.
inner_box_pin_width = slider_top_wing_width / 2 + slider_bottom_wing_width_right - slider_gate_width - pin_gate_closed_clearance_x;
// Extra clearance (in addition to inner_box_play_y) between pins and gates in Y dimension
pin_gate_clearance_y_extra = 0.2;
// Size of pins in Y dimension
inner_box_pin_depth = min(slider_gate_opening) - inner_box_play_y - 2 * pin_gate_clearance_y_extra;

// Max size of the detent peg in Y dimension so prevent detent sockets from overlapping
max_detent_peg_size_y_by_slider = [ for (posar = slider_positions) slider_travel_length / (len(posar) - 1) ];
max_detent_peg_size_y = min(max_detent_peg_size_y_by_slider);
// Size of the detent peg in the Y dimension (depth)
detent_peg_size_y = min(detent_height * 2, max_detent_peg_size_y);
// Minimum Y distance from the Y center of the detent pin on the slider to the edge of the top wing
detent_peg_edge_dist_min = detent_peg_size_y / 2;
// Maximum distance.  Multiplier is arbitrary and determines the range of how close to the edge the detent peg must be.
detent_peg_edge_dist_max = 0.3 * ((slider_top_wing_length - slider_connector_length) / 2 - detent_peg_size_y/2);
assert(detent_peg_edge_dist_max > detent_peg_edge_dist_min);

// For each slider, determine whether the slider can have 2 detent pins, or just one.
// This is determined by: If there are 2 detent pins, they must be a whole multiple of the position distance apart.  Check if there's such a multiple that fits the constraints on detent pin edge positioning.
// The maximum number of detent positions that can fit within the working area of the slider
max_detent_positions_by_slider = [ for (i = [ 0 : num_sliders - 1 ]) floor((slider_top_wing_length - 2 * detent_peg_edge_dist_min) / slider_positions_spacing[i]) ];
// The amount of space (Y) between the dual detent pins on a slider.  This may be 0 or negative in some cases where dual pins aren't possible.
detent_peg_spacing_by_slider = [ for (i = [ 0 : num_sliders-1 ]) (max_detent_positions_by_slider[i] - 1) * slider_positions_spacing[i] ];
// For each slider, whether or not the sliders positions would allow dual detent pegs.
can_have_dual_detent_peg_by_slider = [ for (i = [ 0 : num_sliders-1 ]) detent_peg_spacing_by_slider[i] >= 0 && (slider_top_wing_length - detent_peg_spacing_by_slider[i]) / 2 <= detent_peg_edge_dist_max ];
// Returns true if all elements in the input array are true
function all_true (ar, i=0) = len(ar) < i ? (ar[i] ? all_true(ar, i+1) : false) : true;
// Single flag for whether sliders should have dual detent pegs
dual_detent_pegs = all_true(can_have_dual_detent_peg_by_slider);
// The distance of the detent peg(s) from the edge of the slider
detent_peg_edge_dist_by_slider = [ for (i = [ 0 : num_sliders-1 ]) dual_detent_pegs ? (slider_top_wing_length - detent_peg_spacing_by_slider[i]) / 2 : detent_peg_edge_dist_min ];
echo("Has dual detent pegs", dual_detent_pegs);
echo("Detent edge dist by slider", detent_peg_edge_dist_by_slider);
echo("Detent peg spacing by slider", detent_peg_spacing_by_slider);
echo("Max detent positions by slider", max_detent_positions_by_slider);
echo("Slider positions spacing", slider_positions_spacing);

// How far the false gate impressions are inset
false_gate_indent_width = slider_gate_width / 5;
// Distance to extend slot length by to give a more positive detent click
slot_end_extra_clearance_y = 0.4;

scale_left_margin_type = "compact";
scale_left_margin_slider = 0;
scale_right_margin_type = "compact";
scale_right_margin_slider = 0;

function to_binary_array_helper(n, placeval) = placeval == 1 ? [ n ] : concat([ floor(n / placeval) ], to_binary_array_helper( n - floor(n / placeval) * placeval, placeval / 2));
function to_binary_array(n, max_n) = to_binary_array_helper(n, 2 ^ (floor(log(max_n) / log(2))));
module BinaryPips(n, max_n, width, depth) {
    // Generates a subtractive geometry that will mark a surface with the number in binary.  Surface size is specified as widthxdepth
    // The numeric digits go from left to right along the X axis, centered on the origin.
    // The Y dimension is centered on the origin.
    // The Z dimension is the depth of the marking, configured here.
    mark_depth = 0.2;
    mark_width = 0.5;
    digits = to_binary_array(n, max_n);
    spacing = width / (len(digits) + 1);
    for (digitnum = [ 0 : len(digits) - 1 ])
        translate([ (digitnum + 1) * spacing - width/2, 0, 0 ])
            if (digits[digitnum] == 0)
                translate([ -mark_width/2, -mark_width/2, -mark_depth ])
                    cube([ mark_width, mark_width, mark_depth ]);
            else
                translate([ -mark_width/2, -depth/2, -mark_depth ])
                    cube([ mark_width, depth, mark_depth ]);
};


// Negative cutouts for position tick marks
module ScaleTickMarks(slider_num, width) {
    for (y = slider_positions_y[slider_num])
        translate([ -width/2, y - scale_mark_width/2, -scale_mark_height ])
            cube([ width, scale_mark_width, scale_mark_height ]);
};


// Determine the font point size such that a character will fit inside the given rectangle.  This is a guesstimate.
font_width_to_height_ratio = 0.85;
font_height_to_point_size_multiplier = 0.9;
function font_size_within_rect(w, h) = min(h * font_height_to_point_size_multiplier, w / font_width_to_height_ratio * font_height_to_point_size_multiplier);

// Full scale with symbol for each position
module ScaleFull(slider_num, scale_width, scale_align="right") {
    // Tick marks
    tick_width = scale_width / 5; // arbitrary multiplier
    if (scale_align == "right")
        translate([ scale_width / 2 - tick_width / 2, 0, 0 ])
            ScaleTickMarks(slider_num, tick_width);
    if (scale_align == "left")
        translate([ -scale_width / 2 + tick_width / 2, 0, 0 ])
            ScaleTickMarks(slider_num, tick_width);
    // Symbols
    font_size = font_size_within_rect(scale_width - tick_width, slider_positions_spacing[slider_num]);
    for (i = [ 0 : len(slider_positions[slider_num])-1 ])
        translate([ scale_align == "right" ? -tick_width/2 : tick_width/2, slider_positions_y[slider_num][i], -scale_mark_height ])
            linear_extrude(scale_mark_height)
                text(slider_positions[slider_num][i], size=font_size, halign="center", valign="center");
};

// Compact scale with only first and last positions marked with symbol
module ScaleCompact(slider_num, scale_width, scale_align="right") {
    // Tick marks
    tick_width = scale_width / 2; // arbitrary multiplier
    if (scale_align == "right")
        translate([ scale_width / 2 - tick_width / 2, 0, 0 ])
            ScaleTickMarks(slider_num, tick_width);
    if (scale_align == "left")
        translate([ -scale_width / 2 + tick_width / 2, 0, 0 ])
            ScaleTickMarks(slider_num, tick_width);
    // Symbols
    font_size = font_size_within_rect(scale_width, slider_positions_y_begin);
    translate([ 0, slider_positions_y_end + font_size/2 + slider_positions_spacing[slider_num] / 2, -scale_mark_height ])
        linear_extrude(scale_mark_height)
            text(slider_positions[slider_num][0], size=font_size, halign="center", valign="center");
    translate([ 0, slider_positions_y_begin - font_size/2 - slider_positions_spacing[slider_num] / 2, -scale_mark_height ])
        linear_extrude(scale_mark_height)
            text(slider_positions[slider_num][len(slider_positions[slider_num])-1], size=font_size, halign="center", valign="center");

};


module Scale(slider_num, width, scale_type, scale_align="center") {
    if (scale_type == "ticks")
        ScaleTickMarks(slider_num, width);
    else if (scale_type == "full")
        ScaleFull(slider_num, width, scale_align);
    else if (scale_type == "compact")
        ScaleCompact(slider_num, width, scale_align);
    else
        assert(false);
};

module LeftMarginScale() {
    translate([ outer_box_top_margins_x/2, 0, outer_box_outer_size.z ])
        Scale(scale_left_margin_slider, outer_box_top_margins_x, scale_left_margin_type, "right");
};

module RightMarginScale() {
    translate([ outer_box_outer_size.x - outer_box_top_margins_x/2, 0, outer_box_outer_size.z ])
        Scale(scale_right_margin_slider, outer_box_top_margins_x, scale_right_margin_type, "left");
};

module IntraSliderScale(slider_num) {
    difference() {
        ScaleTickMarks(slider_num, slider_spacing);
        translate([ -(slider_top_wing_width + 2*slider_top_wing_clearance_x)/2, 0, -(scale_mark_height + 10) ])
            cube([ slider_top_wing_width + 2*slider_top_wing_clearance_x, outer_box_outer_size.y + 10, scale_mark_height + 10 ]);
        if (slider_num == 0)
            translate([ -slider_spacing/2, 0, -(scale_mark_height + 10) ])
                cube([ slider_spacing/2, outer_box_outer_size.y + 10, scale_mark_height + 10 ]);
        if (slider_num == num_sliders - 1)
            translate([ 0, 0, -(scale_mark_height + 10) ])
                cube([ slider_spacing/2, outer_box_outer_size.y + 10, scale_mark_height + 10 ]);
    };
};


module DetentPeg(width, extraheight=0) {
    // Triangular detent peg.  Top flush with XY plane at z=0.  Extends to given width over X, centered at x=0
    translate([ -width/2, 0, 0 ])
    rotate([ 90, 0, 90 ])
    linear_extrude(width)
    polygon([
        [ detent_peg_size_y / 2, 0 ],
        [ 0, -(detent_height + extraheight) ],
        [ -detent_peg_size_y / 2, 0 ]
    ]);
};


module Slider(slider_num, position_num) {
    
    module SliderHandle() {
        difference() {
            translate([ -slider_top_wing_width/2, -slider_handle_depth/2, 0 ])
                cube([ slider_top_wing_width, slider_handle_depth, slider_handle_height ]);
            // Index mark
            translate([ -(slider_top_wing_width + 10)/2, -scale_mark_width/2, slider_handle_height - scale_mark_height ])
                cube([ slider_top_wing_width + 10, scale_mark_width, 10 ]);
        };
    };
    
    module SliderTopWing() {
        translate([ -slider_top_wing_width/2, -slider_top_wing_length/2, 0 ])
            cube([ slider_top_wing_width, slider_top_wing_length, slider_top_wing_thick ]);
        // Detent pegs
        translate([ 0, -slider_top_wing_length/2 + detent_peg_edge_dist_by_slider[slider_num], 0 ])
                DetentPeg(slider_top_wing_width, slider_wing_play_z);
        if (dual_detent_pegs) {
            translate([ 0, slider_top_wing_length/2 - detent_peg_edge_dist_by_slider[slider_num], 0 ])
                DetentPeg(slider_top_wing_width, slider_wing_play_z);
        }
    };
    
    module SliderConnector() {
        translate([ -slider_connector_width/2, -slider_connector_length/2, 0 ])
            cube([ slider_connector_width, slider_connector_length, slider_connector_height ]);
    };
    
    module SliderBottomWing() {
        translate([ -slider_bottom_wing_width_left, -slider_gate_depth/2, 0 ])
            difference() {
                // Bottom wing
                cube([ slider_bottom_wing_width_left + slider_bottom_wing_width_right, slider_gate_depth, slider_bottom_wing_thick ]);
                // Markings for slider and position
                if (slider_num != undef && position_num != undef) {
                    translate([ 0, slider_gate_depth * (3/4), slider_bottom_wing_thick/2 ])
                        rotate([ 0, -90, 0 ])
                            rotate([ 0, 0, -90 ])
                                BinaryPips(slider_num, num_sliders-1, slider_gate_depth/2, slider_bottom_wing_thick);
                    translate([ 0, slider_gate_depth * (1/4), slider_bottom_wing_thick/2 ])
                        rotate([ 0, -90, 0 ])
                            rotate([ 0, 0, -90 ])
                                BinaryPips(position_num, len(slider_positions[slider_num])-1, slider_gate_depth/2, slider_bottom_wing_thick);
                }
            };
    };
    
    module SliderGate() {
        translate([ slider_bottom_wing_width_right - slider_gate_width, 0, 0 ])
            difference() {
                // Body of gate
                translate([ 0, slider_gate_depth/2, 0 ])
                    rotate([ 90, 0, 0 ])
                        linear_extrude(slider_gate_depth)
                            polygon([
                                [ slider_gate_width, 0 ],
                                [ 0, 0 ],
                                [ -slider_gate_height, slider_gate_height ],
                                [ slider_gate_width, slider_gate_height ]
                            ]);
                // Cutout
                if (position_num != undef)
                    translate([ -100, outer_box_outer_size.y/2 - slider_positions_y[slider_num][position_num] - slider_gate_opening[slider_num]/2, -5 ])
                        cube([ slider_gate_width + 200, slider_gate_opening[slider_num], slider_gate_height + 10 ]);
                // Fake cutouts
                fake_cutout_interval_modulo = max(ceil(slider_gate_opening[slider_num] / (slider_gate_depth / len(slider_positions[slider_num])) * 2.5), 3);
                if (position_num != undef)
                    for (p = [ position_num % fake_cutout_interval_modulo : fake_cutout_interval_modulo : len(slider_positions[slider_num]) - 1 ])
                        translate([ false_gate_indent_width, outer_box_outer_size.y/2 - slider_positions_y[slider_num][p] + slider_gate_opening[slider_num]/2, 0 ])
                            rotate([ 90, 0, 0 ])
                                linear_extrude(slider_gate_opening[slider_num])
                                    polygon([
                                        [ 0, 0 ],
                                        [ -slider_gate_height, slider_gate_height ],
                                        [ -100, slider_gate_height ],
                                        [ -100, 0 ]
                                    ]);
            };
    };
    
    SliderGate();
    translate([ 0, 0, slider_gate_height ])
        SliderBottomWing();
    translate([ 0, 0, slider_gate_height + slider_bottom_wing_thick ])
        SliderConnector();
    translate([ 0, 0, slider_gate_height + slider_bottom_wing_thick + slider_connector_height ])
        SliderTopWing();
    translate([ 0, 0, slider_gate_height + slider_bottom_wing_thick + slider_connector_height + slider_top_wing_thick ])
        SliderHandle();
    
};

module SliderFrontCutout() {
    difference() {
        translate([ 0, outer_box_wall_thick, 0 ])
            rotate([ 90, 0, 0 ])
                linear_extrude(outer_box_wall_thick + 10)
                    offset(r=outer_box_front_slider_cutout_clearance)
                        translate([ 0, -slider_gate_height - slider_bottom_wing_thick ])
                            projection()
                                rotate([ -90, 0, 0 ])
                                    Slider(0, undef);
        translate([ 0, 0, 100 ])
            cube([ 200, 200, 200 ], center=true);
    };
};


module InnerBox() {
    module Pin() {
        translate([ 0, inner_box_pin_depth/2, 0 ])
        rotate([ 90, 0, 0 ])
        linear_extrude(inner_box_pin_depth)
            if (inner_box_pin_width > inner_box_pin_height) {
                // Pin shape is rectangle next to triangle
                polygon([
                    [ 0, 0 ],
                    [ -inner_box_pin_height, inner_box_pin_height ],
                    [ -inner_box_pin_width, inner_box_pin_height ],
                    [ -inner_box_pin_width, 0 ]
                ]);
            } else {
                // Pin shape is just triangle
                polygon([
                    [ 0, 0 ],
                    [ -inner_box_pin_width, inner_box_pin_width ],
                    [ -inner_box_pin_width, 0 ]
                ]);
            }
    };

    module EndPlate() {
        // Plate at right end of box.  Also includes handles to pull.
        translate([ inner_box_end_plate_thick, 0, 0 ])
            rotate([ 0, -90, 0 ])
                linear_extrude(inner_box_end_plate_thick)
                    union() {
                        square([ outer_box_outer_size.z, outer_box_outer_size.y ]);
                        for (y = [ 0, outer_box_outer_size.y ])
                            translate([ outer_box_outer_size.z/2, y ])
                                scale([ outer_box_outer_size.z / inner_box_side_handle_protrusion / 2, 1.0 ])
                                    circle(r=inner_box_side_handle_protrusion, $fn=50);
                    };
    };

    difference() {
        union() {
            // Outer solid
            cube(inner_box_main_outer_size);
            // End Plate
            translate([ inner_box_main_outer_size.x, -(outer_box_outer_size.y - inner_box_main_outer_size.y) / 2, -outer_box_bottom_thick - inner_box_top_rail_play_z/2 ])
                EndPlate();
            // Top rails
            cube([ inner_box_main_outer_size.x, inner_box_top_rail_depth, inner_box_main_outer_size.z + inner_box_top_rail_height ]);
            translate([ 0, inner_box_main_outer_size.y - inner_box_top_rail_depth, 0 ])
                cube([ inner_box_main_outer_size.x, inner_box_top_rail_depth, inner_box_main_outer_size.z + inner_box_top_rail_height ]);
            // Pins
            for (slider_x = sliders_x) // note: this is relative to the outer box so needs to be offset
                translate([ slider_x - outer_box_wall_thick + slider_bottom_wing_width_right - slider_gate_width, inner_box_main_outer_size.y / 2, inner_box_main_outer_size.z ])
                    Pin();
        };
        // Inner cavity
        translate([ -10, inner_box_wall_thick, inner_box_bottom_thick ])
            cube(inner_box_inner_size + [ 10, 0, 0 ]);
    };
};

module OuterBox() {
    difference() {
        // Outer solid
        cube(outer_box_outer_size);
        // Inner cavity
        translate([ outer_box_wall_thick, outer_box_wall_thick, outer_box_bottom_thick ])
            cube(outer_box_inner_size + [ 10, 0, 0 ]);
        // Slots in top
        for (x = sliders_x)
            translate([ x - slot_width/2, -10 + slot_end_extra_clearance_y, outer_box_outer_size.z - outer_box_top_thick - 0.1 ])
                cube([ slot_width, slot_edge_offset + slot_travel_length + 10, outer_box_top_thick + 10 ]);
        // Slots in front so sliders can be inserted
        for (i = [ 0 : num_sliders - 1 ])
            translate([ sliders_x[i], 0, outer_box_outer_size.z - outer_box_top_thick ])
                SliderFrontCutout();
        // Depressions in top for the sliders
        for (x = sliders_x)
            translate([ x - (slider_top_wing_width + 2*slider_top_wing_clearance_x) / 2, -5, outer_box_outer_size.z - slider_top_wing_thick ])
                cube([ slider_top_wing_width + 2*slider_top_wing_clearance_x, outer_box_outer_size.y + 10, outer_box_top_thick + 1 ]);
        // Detent sockets
        for (slidernum = [ 0 : num_sliders - 1 ])
            for (posnum = [ 0 : len(slider_positions[slidernum]) - 1 ])
                translate([ sliders_x[slidernum], slider_positions_y[slidernum][posnum], outer_box_outer_size.z - slider_top_wing_thick ])
                    union() {
                        translate([ 0, -slider_top_wing_length/2 + detent_peg_edge_dist_by_slider[slidernum], 0 ])
                            DetentPeg(slider_top_wing_width + 2*slider_top_wing_clearance_x);
                        translate([ 0, slider_top_wing_length/2 - detent_peg_edge_dist_by_slider[slidernum], 0 ])
                            DetentPeg(slider_top_wing_width + 2*slider_top_wing_clearance_x);
                    };
        // Scales on walls between sliders
        if (between_slider_wall_width > 0) // if there are walls
            for (i = [ 0 : num_sliders-1 ])
                translate([ sliders_x[i], 0, outer_box_outer_size.z ])
                    IntraSliderScale(i);
        // Scales on margins
        LeftMarginScale();
        RightMarginScale();
    };
};

module InnerBoxPrint() {
    rotate([ 0, 90, 0 ])
        InnerBox();
};

module OuterBoxPrint1() {
    difference() {
        OuterBox();
        translate([ outer_box_wall_thick, -5, outer_box_outer_size.z - outer_box_top_thick ])
            cube([ outer_box_outer_size.x - 2 * outer_box_wall_thick, outer_box_outer_size.y + 10, outer_box_top_thick + 10 ]);
        translate([ -5, outer_box_wall_thick, outer_box_outer_size.z - outer_box_top_thick ])
            cube([ outer_box_outer_size.x + 10, outer_box_outer_size.y - 2 * outer_box_wall_thick, outer_box_top_thick + 10 ]);
    };
    
    //rotate([ 90, 0, 0 ])
        //OuterBox();
};

module OuterBoxPrint2() {
    difference() {
        OuterBox();
        OuterBoxPrint1();
    };
};

module SliderPrint(sn, pn) {
    rotate([ 0, 90, 0 ])
        Slider(sn, pn);
};

//InnerBox();
OuterBox();
//Slider(0, 3);

//InnerBoxPrint();
//OuterBoxPrint1();
//OuterBoxPrint2();
//SliderPrint(0, 3);









