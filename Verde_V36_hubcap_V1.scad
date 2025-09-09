// Written by Chris Mickelson 2025 in about 4 hours, integrated complex mathematical formulas with help from ChatGPT.
// Hubcap for Verde V36 wheels - for 3D printing replacements(units in mm)
// Hightly detailed so open with 2025 current build of OpenSCAD, ver. 2021 is too slow for highly detailed models
    // Parameters
    outer_diameter = 157;// 157 mm wide
    height = 25; // 25 mm high
    inner_flat_diameter = 53; 

    //how much detail 40 to 360-ish
    $fn = 180;

    //creates a flattened pill-shape
    module thumbpress(option) {
        if (option == 0) {//subtracted shape on top surface
            hull() {
                scale([1, 1, 0.5])sphere(15);
                translate([45, 0, 0])scale([1, 1, 0.5])sphere(19);
            }
        } else {//non-zero = wider thumbpress under to keep material thickness
            hull() {
                scale([1.0, 1.12, 0.5])translate([0, 0, 1])sphere(15);
                translate([45, 0, 0])scale([1.0, 1.12, 0.5])translate([0, 0, 1])sphere(19);
            }
        }
    }

    // Module: spherical dome
    // base_diameter = diameter of the circular base
    // height = height of the dome at the center
    module dome(base_diameter, height) {
        a = base_diameter / 2;                       // base radius
        R = (a * a + height * height) / (2 * height);      // sphere radius
        sphere_radius = R;

        // Cut the spherical cap to height
        difference() {
            // Full sphere
            translate([0, 0, -R + height])  // move sphere so dome height is correct
            sphere(r = sphere_radius, $fn = $fn);

            // Remove the bottom half below the base plane
            translate([-R * 2, -R * 2, -R * 2])
            cube([R * 4, R * 4, R * 2],center = false);
        }
    }

    // Compute virtual tip z of a truncated cone - used to position thumbpress modules in line with slope
    // z0 = bottom Z position
    // h  = height of the cone
    // d1 = bottom diameter
    // d2 = top diameter
    // slope dr/dz
    function cone_tip_z(z0, h, d1, d2) = let(r0 =d1/2, r1 =d2/2, z1 =z0+h, m  =(r1-r0) /(z1 -z0)) z0 -r0/m;
    // intersection where r=0

    //set virtual tip of cone position for positioning thumbpress objects
    z_tip = cone_tip_z(3,height-2, inner_flat_diameter, outer_diameter+5)+3;

    //here the "option" variable adjusts the shape for top surface or bottom surface differences
    //option should only equal 0(top) or 1(underside)
    module base_shape(option) {
        // Base cylinder
        difference() {
            // Outer solid
            //(outer diameter + 0.1 if underside to remove z-fighting/artifacting)
            cylinder(h = height * 2, d = outer_diameter + (option / 10.0), $fn = $fn, center = true);

            union() {
                // Carved-out truncated cone
                //the 3, -2 and +5 are for adjusting the cut-out cone shape to align with upper edge of cylinder
                translate([0, 0, 3])
                cylinder(h = height - 2,
                        d1 = inner_flat_diameter,  // bottom (flat area, 53)
                        d2 = outer_diameter + 5,       // top matches outer diameter
                        $fn = $fn);
                //5 "thumbpress" shapes at an angle of -23 degrees
                for (ang = [0 :72 :(72 * 5)])//72 = 360deg / 5 spokes
                    rotate([0, -20, ang])translate([0, 0, z_tip])translate([48, 0, 1])thumbpress(option);

                //5 cone-shaped thumbpresses just the same, but offset 36 deg between the others
                for (ang = [0 :72 :(72 * 5)])//72 = 360deg / 5 spokes
                    rotate([0, -20, ang + 36])translate([0, 0, z_tip])translate([48, 0, 0])
                    rotate([0, -118, 0])translate([4, 0, -38])cylinder(h = 35, r1 = 35, r2 = 1, center = false);
            }//end union
        }//end difference
    }//end module base_shape

    //dewit!
    difference() {
        //top surface
        union() {
            base_shape(0);
            translate([0, 0, 3])dome(53, 2.5);
        }
        //subtract bottom surface
        union() {
            translate([0, 0, -3])base_shape(1);
            translate([0, 0, -0.1])dome(53, 2.5);
        }
    }
