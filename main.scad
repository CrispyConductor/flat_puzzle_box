
// Size of interior cavity of inner box.  The opening faces -X
inner_box_inner_size = [ 80, 100, 10 ];

num_sliders = 5;

// Array of string labels to use for numeric slider positions
numeric_positions = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ];
// Array, indexed by slider number, of arrays of positions for that slider.
slider_positions = [ for (i = [ 0 : num_sliders ]) numeric_positions ];

// Inner box wall thicknesses
inner_box_wall_thick = 1.5;
inner_box_bottom_thick = 1.5;
inner_box_top_thick = 1.5;
// Calculated inner box main outer dimensions, not including rails and pins on the top, or handle on the front.
inner_box_main_outer_size = [
    inner_box_inner_size.x + inner_box_wall_thick,
    inner_box_inner_size.y + 2 * inner_box_wall_thick,
    inner_box_inner_size.z + inner_box_bottom_thick + inner_box_top_thick
];

// The amount of sliding play/clearance the inner box has inside the outer box in the Y dimension
inner_box_play_y = 0.4;

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
pin_wing_clearance = 0.2;

outer_box_top_thick = 2.5;
// Thickness of the top wing
slider_top_wing_thick = (1/3) * outer_box_top_thick;

// Size of inner cavity in outer box.
outer_box_inner_size = inner_box_main_outer_size + [
    0,
    inner_box_play_y,
    inner_box_pin_height + pin_wing_clearance + slider_top_wing_thick + slider_wing_play_z
];
outer_box_wall_thick = 1.5;
outer_box_bottom_thick = 1.5;
outer_box_outer_size = outer_box_inner_size + [ outer_box_wall_thick, 2 * outer_box_wall_thick, outer_box_bottom_thick + outer_box_top_thick ];

// The clearance between the tops of the rails on the inner box and the bottom of the outer box lid.
inner_box_top_rail_play_z = 0.2;
// The height of the top rails on the inner box.
inner_box_top_rail_height = outer_box_inner_size.z - inner_box_main_outer_size.z - inner_box_top_rail_play_z;
// Width of the top rails on the inner box
inner_box_top_rail_depth = 3;

// Space between sliders
slider_spacing = (outer_box_outer_size.x - outer_box_wall_thick) / (num_sliders + 1);
// The X coordinate of each of the sliders, centered on the slider.
sliders_x = [ for (i = [ 0 : num_sliders-1 ]) outer_box_wall_thick + (i + 1) * slider_spacing ];

// Length of the connector between the top and bottom parts of the slider.  Larger values are stronger but reduce travel length and compress symbols.  The multiplier is arbitrarily chosen.  This is the main parameter to tweak for altering travel distance.
slider_connector_length = (1/12) * outer_box_outer_size.y;

// The length of the part of the slot that the slider travels in
slot_travel_length = (1/3) * outer_box_outer_size.y + (2/3) * slider_connector_length;
// The distance that the slider can travel
slider_travel_length = slot_travel_length - slider_connector_length;
// Offset from the slot to the edge of the box
slot_edge_offset = (1/3) * (outer_box_outer_size.y - slider_connector_length);
// Length/depth of the top wing/plate on the slider
slider_top_wing_length = (2/3) * (outer_box_outer_size.y - slider_connector_length) + slider_connector_length;

// Width of the 'connector' portion of the slider, the part that rides in the slots.  The multiplier here is arbitrarily chosen.
slider_connector_width = (1/6) * inner_box_main_outer_size.x / num_sliders;
// Amount of play the slider has in the X dimension
slider_play_x = 0.3;
// The width of the slots in the box
slot_width = slider_connector_width + slider_play_x;
// Play of the slider top wing in its slot in the x dimension
slider_depression_play_x = 0.4;

// TODO - make sure the geometry makes sense with the gate fin running into the rails and whatnot with respect to this travel distance.  I think it'll be fine.

// Amount of clearance in the Y dimension between adjacent slider top wings
inter_slider_top_wing_clearance = 0.4;
// Width of the top plate on the slider
slider_top_wing_width = slider_spacing - inter_slider_top_wing_clearance;
// Amount the handle on the slider protrudes
slider_handle_bump_height = 1;
// Diameter of the handle bump
slider_handle_bump_diameter = slider_top_wing_width / 2;
// Height of connecting piece of slider TODO: Need to add indent in box top for slider to ride in
slider_connector_height = outer_box_top_thick - slider_top_wing_thick + slider_wing_play_z;
// Width of bottom wing right-of-center.
slider_bottom_wing_width_right = slider_top_wing_width / 2;
// Width of bottom wing left-of-center.
slider_bottom_wing_width_left = slider_bottom_wing_width_right / 3;


module InnerBox() {
    difference() {
        union() {
            // Outer solid
            cube(inner_box_main_outer_size);
            // Top rails
            cube([ inner_box_main_outer_size.x, inner_box_top_rail_depth, inner_box_main_outer_size.z + inner_box_top_rail_height ]);
            translate([ 0, inner_box_main_outer_size.y - inner_box_top_rail_depth, 0 ])
                cube([ inner_box_main_outer_size.x, inner_box_top_rail_depth, inner_box_main_outer_size.z + inner_box_top_rail_height ]);
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
            translate([ x - slot_width/2, -10, outer_box_outer_size.z - outer_box_top_thick - 5 ])
                // TODO: Fix z to be appropriate height so slider can enter
                cube([ slot_width, slot_edge_offset + slot_travel_length + 10, outer_box_top_thick + 10 ]);
        // Depressions in top for the sliders
        for (x = sliders_x)
            translate([ x - (slider_top_wing_width + slider_depression_play_x) / 2, -10, outer_box_outer_size.z - slider_top_wing_thick ])
                cube([ slider_top_wing_width + slider_depression_play_x, slot_edge_offset + slot_travel_length + 10, slider_top_wing_thick + 10 ]);
        // Fill in tiny protrusions between depressions.  (Comment this out if space between sliders is increased much)
        translate([ sliders_x[0], -10, outer_box_outer_size.z - slider_top_wing_thick ])
            cube([ sliders_x[len(sliders_x) - 1] - sliders_x[0], slot_edge_offset + slot_travel_length + 10, slider_top_wing_thick + 10 ]);
    };
};

//InnerBox();
OuterBox();





module Slider() {
};



