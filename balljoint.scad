/*
 * =====================================
 *   This is public Domain Code
 *   Contributed by: Gael Lafond
 *   14 November 2021
 * =====================================
 *
 * Universal ball joint.
 *
 * This is intended to be used as a library
 * in other projects.
 * Example:
 *     use <balljoint.scad>;
 *     balljoint_ball();
 *     balljoint_seat();
 *     balljoint_nut();
 *
 * If you need a smaller or larger ball joint,
 * use "scale".
 * Example:
 *     use <balljoint.scad>;
 *     scale(2) balljoint_ball();
 *     scale(2) balljoint_seat();
 *     scale(2) balljoint_nut();
 *
 * The ball joint was tested using the defined dimensions.
 * Changing the dimensions may generate disfunctional parts.
 * If you need to change the dimensions, import the
 * library using "include" instead of "use" and overwrite
 * the appropriate variables.
 * Example:
 *     include <balljoint.scad>;
 *     balljoint_ball_dia = 30;
 *     balljoint_ball();
 *     balljoint_seat();
 *     balljoint_nut();
 *
 * Inspired from:
 *     Universal Ball Joint by MORONator:
 *     https://www.thingiverse.com/thing:5020323
 *
 * Dependency:
 *     helix_extrude.scad: https://www.thingiverse.com/thing:2200395
 *
 * Unit: millimetres.
 */

use <helix_extrude.scad>;

$fn = 80;

balljoint_ball_dia = 17.5;
balljoint_ball_base_dia = 19;
balljoint_ball_base_height = 12;

balljoint_seat_walls = 1.4;
balljoint_seat_walls_threads_height = balljoint_ball_dia * 0.74;

balljoint_thread_tooth_height = 1.71;
balljoint_thread_tooth_width = 0.4;
balljoint_thread_tooth_base_width = 2.35;


// Load the original STL, to be used as reference.
/*
color([0.5, 0.5, 1]) {
    *translate([-50 + 20, 0, -2.15]) import("../MORONator/Ball.stl");

    *difference() {
        translate([0, 0, -3]) import("../MORONator/Base.stl", convexity = 5);
        translate([-50, -50, 0]) cube([100, 50, 50]);
    }

    //translate([-25, -24.78, -0.015]) import("../MORONator/Screw.stl");
    *rotate([0, 0, 145]) translate([-25, -24.78, -0.015]) import("../MORONator/Screw.stl");
}
*/


*balljoint_demo_ball();
*balljoint_demo_seat();
*balljoint_nut();

difference() {
    rotate([0, 0, 45]) balljoint_demo_assembled();

    translate([-50, -50, -4]) {
        cube([100, 50, 50]);
    }
}


module balljoint_demo_assembled() {
    color([1, 1, 0]) {
        translate([0, 0, balljoint_ball_base_height + balljoint_ball_dia * 62/175 + balljoint_ball_dia/2 + 1.5]) {
            rotate([180, 0, 0]) balljoint_demo_ball();
        }
    }

    color([0, 0, 1]) {
        balljoint_demo_seat();
    }

    color([1, 0, 0]) {
        translate([0, 0, balljoint_ball_dia * 0.82 + (balljoint_ball_dia * 0.82 - balljoint_ball_dia * 0.74) + 1.5]) {
            rotate([180, 0, 0]) balljoint_nut();
        }
    }
}

module balljoint_demo_ball() {
    balljoint_ball();
    translate([0, 0, -3]) {
        balljoint_demo_handle(d = balljoint_ball_base_dia, l = 50);
    }
}

module balljoint_demo_seat() {
    balljoint_seat();
    translate([0, 0, -3]) {
        balljoint_demo_handle(d = balljoint_ball_base_dia * 1.6, l = 70);
    }
}

module balljoint_demo_handle(d, l, h = 3) {
    linear_extrude(h) {
        circle(d = d);
        translate([(l - d)/2, 0]) {
            square([l - d, d], center = true);
        }
        translate([l - d, 0]) {
            circle(d = d);
        }
    }
}

module balljoint_nut() {
    _nut_height = balljoint_ball_dia * 0.82;
    _nut_dia = balljoint_ball_dia * 2;
    _nut_fillet_dia = 4.6;
    _nut_neck_height = 3;
    _nut_neck_hole_dia = balljoint_ball_dia + balljoint_seat_walls;

    _nut_thread_clearance = 0.6;

    _nut_thread_hole_dia = balljoint_ball_dia + balljoint_thread_tooth_height*2 + balljoint_seat_walls*2 + _nut_thread_clearance;

    _nut_grip_hole_dia = 1.4;
    _nut_grip_hole_count = round(_nut_dia * 10/7);

    difference() {
        // Main body - rounded cylinder
        translate([0, 0, _nut_fillet_dia/2]) {
            minkowski() {
                cylinder(h = _nut_height - _nut_fillet_dia, d = _nut_dia - _nut_fillet_dia);
                sphere(d = _nut_fillet_dia);
            }
        }

        // Grip holes
        for (angle = [0 : 360/_nut_grip_hole_count : 360]) {
            rotate([0, 0, angle]) {
                translate([0, _nut_dia/2 + 0.11,0]) {
                    cylinder(d = _nut_grip_hole_dia, h = _nut_height);
                }
            }
        }

        // Thread hole
        translate([0, 0, _nut_neck_height]) {
            cylinder(d = _nut_thread_hole_dia, h = _nut_height);
        }

        // Neck hole
        translate([0, 0, -0.01]) {
            cylinder(d = _nut_neck_hole_dia, h = _nut_neck_height + 0.02);
        }
    }

    // Threads
    difference() {
        helix_extrude(
            height = (12.95 + balljoint_thread_tooth_base_width*2) * 2,
            angle = 5.885 * 360 * 2
        ) {
            translate([_nut_thread_hole_dia/2, 0]) {
                rotate([0, 0, 90]) {
                    balljoint_thread_tooth_profile();
                }
            }
        }

        // Remove extra thread at the bottom
        translate([0, 0, -balljoint_thread_tooth_base_width + _nut_neck_height]) {
            cube([_nut_dia, _nut_dia, balljoint_thread_tooth_base_width*2], center = true);
        }

        // Remove extra threads at the top
        translate([0, 0, _nut_height - _nut_thread_hole_dia/2]) {
            cylinder(d1 = 0, d2 = _nut_dia, h = _nut_dia/2);
        }
        translate([0, 0, _nut_height + 16]) {
            cube([_nut_dia, _nut_dia, 30], center = true);
        }
    }
}

module balljoint_seat() {
    _bottom_thickness = 1;
    _ball_clearance = 0.5;

    _walls_height = balljoint_ball_dia * 0.915;
    _walls_lips = balljoint_ball_dia * 0.033;

    _cushion_large_dia = balljoint_ball_dia * 0.657;
    _cushion_small_dia = balljoint_ball_dia * 0.4;

    _slit_length = balljoint_ball_dia + balljoint_seat_walls*2 + balljoint_thread_tooth_height*2 + 1;
    _slit_width = balljoint_ball_dia * 0.114;
    _slit_height = balljoint_ball_dia * 0.56;

    // Ball
    *translate([0, 0, balljoint_ball_dia/2 + _bottom_thickness + _ball_clearance]) {
        sphere(d = balljoint_ball_dia);
    }

    // Bottom
    cylinder(d = balljoint_ball_dia + balljoint_seat_walls*2, h = _bottom_thickness);

    difference() {
        union() {
            // Cushion
            translate([0, 0, _bottom_thickness]) {
                linear_extrude(_ball_clearance + balljoint_ball_dia/2, convexity = 4) {
                    difference() {
                        circle(d = _cushion_large_dia);
                        circle(d = _cushion_small_dia);
                    }
                }
            }

            // Walls
            rotate_extrude() seat_wall_profile();

            // Threads
            intersection() {
                translate([0, 0, -balljoint_thread_tooth_base_width/2]) {
                    rotate([0, 0, 121]) {
                        helix_extrude(
                            height = (12.95 + balljoint_thread_tooth_base_width*2) *2,
                            angle = 5.885 * 360 * 2
                        ) {
                            translate([balljoint_ball_dia/2 + balljoint_seat_walls, 0]) {
                                rotate([0, 0, -90]) {
                                    balljoint_thread_tooth_profile();
                                }
                            }
                        }
                    }
                }
                _threads_cut = balljoint_ball_dia * 463 / 350;
                cylinder(r1 = _threads_cut, r2 = 0, h = _threads_cut);
            }
        }

        // Ball
        translate([0, 0, balljoint_ball_dia/2 + _bottom_thickness + _ball_clearance]) {
            sphere(d = balljoint_ball_dia);
        }

        // Slits
        for (side = [0, 90]) {
            rotate([0, 0, side]) {
                translate([
                    -_slit_length/2,
                    0,
                    _walls_height - _slit_height
                ]) {
                    translate([0, -_slit_width/2, 0]) {
                        cube([_slit_length, _slit_width, _slit_height + 0.01]);
                    }
                    // Rounded edge at the bottom
                    rotate([0, 90 ,0]) {
                        cylinder(h = _slit_length, d = _slit_width);
                    }
                }
            }
        }
    }

    module seat_wall_profile() {
        polygon([
            [balljoint_ball_dia/2, 0],
            [balljoint_ball_dia/2 + balljoint_seat_walls, 0],
            [balljoint_ball_dia/2 + balljoint_seat_walls, balljoint_seat_walls_threads_height],
            [balljoint_ball_dia/2 + balljoint_seat_walls * 0.35, _walls_height],
            [balljoint_ball_dia/2, _walls_height]
        ]);

        // Lips
        bezier_polygon([
            [
                [balljoint_ball_dia/2, _walls_height],
                [balljoint_ball_dia/2, _walls_height * 0.95],
                [balljoint_ball_dia/2 - _walls_lips, _walls_height * 0.92],
                [balljoint_ball_dia/2 - _walls_lips, _walls_height * 0.85]
            ], [
                [balljoint_ball_dia/2 - _walls_lips, _walls_height * 0.85],
                [balljoint_ball_dia/2 - _walls_lips, _walls_height * 0.78],
                [balljoint_ball_dia/2, _walls_height * 0.73],
                [balljoint_ball_dia/2, _walls_height * 0.6]
            ]
        ]);
    }
}

module balljoint_thread_tooth_profile() {
    polygon([
        [-balljoint_thread_tooth_base_width/2, 0],
        [-balljoint_thread_tooth_width/2, balljoint_thread_tooth_height],
        [balljoint_thread_tooth_width/2, balljoint_thread_tooth_height],
        [balljoint_thread_tooth_base_width/2, 0]
    ]);
}

module balljoint_ball() {
    // Base
    rotate_extrude() {
        ball_base_profile();
    }

    // Ball
    // NOTE: The arbitrary "62/175" ratio is used to move
    //     the ball up just enough to merge well with
    //     the base.
    _ball_height = balljoint_ball_base_height + balljoint_ball_dia * 62/175;
    translate([0, 0, _ball_height]) {
        sphere(d = balljoint_ball_dia);
    }

    module ball_base_profile() {
        // NOTE: All the points of the polygon
        //     are based on ratio of the size of the base
        //     and the size of the ball, so the shape
        //     can automatically adjust if the size of the
        //     base or ball is adjusted.
        _top_dia = balljoint_ball_dia / 3;

        bezier_polygon([
            [
                // 1st point
                [0, 0],
                // 1st point bezier handle to 2nd point
                [0, 0],
                // 2nd point bezier handle to 1st point
                [balljoint_ball_base_dia/2, 0],
                // 2nd point
                [balljoint_ball_base_dia/2, 0]
            ], [
                // 2nd point (duplicate because of OpenSCAD limitations)
                [balljoint_ball_base_dia/2, 0],
                // 2nd point bezier handle to 3rd point
                [balljoint_ball_dia * 0.24, balljoint_ball_base_height/2],
                // 3rd point bezier handle to 2nd point
                [balljoint_ball_dia * 0.24, balljoint_ball_base_height * 0.75],
                // 3rd point
                [_top_dia, balljoint_ball_base_height]
            ], [
                // 3rd point (duplicate)
                [_top_dia, balljoint_ball_base_height],
                // 3rd point bezier handle to 4th point
                [_top_dia, balljoint_ball_base_height],
                // 4th point bezier handle to 3rd point
                [0, balljoint_ball_base_height],
                // 4th point
                [0, balljoint_ball_base_height]
            ]
        ]);
    }
}


/**
 * Stripped down version of "bezier_v2.scad".
 * For full version, see: https://www.thingiverse.com/thing:2170645
 */
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);

function bezier_2D_point(p0, p1, p2, p3, u) = [
    BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
    BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]
];

function bezier_coordinates(points, steps) = [
    for (c = points)
        for (step = [0:steps])
            bezier_2D_point(c[0], c[1], c[2],c[3], step/steps)
];

module bezier_polygon(points) {
    steps = $fn <= 0 ? 30 : $fn;
    polygon(bezier_coordinates(points, steps));
}
