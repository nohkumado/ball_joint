// --- Default Parameters ---
// These values are used if not specified when calling the modules.
joint_radius = 5;             // Radius of the spherical ball.
joint_neck_r = 3;             // Radius of the cylindrical neck for attachment.
joint_neck_h = 5;             // Height of the cylindrical neck.
wd = 1;                       // Wall thickness of the socket's spherical part.
socket_opening_angle = 70;    // Angle (0-90 degrees) from the Z-axis for the flat top opening.
                              // 0 = no cut (closed top), 90 = hemisphere cut.
socket_width = 2.3*joint_radius;  //width or coverage of the socket
tol = 0.2;                    // Small gap between the ball and the inner socket wall for movement.

// Controls what to display for quick testing ["joint", "socket", "both"]
//show = "socket";
show = "both";

// Parameter for the side slot cut (repurposing your 'w' idea)
// This will define the opening width for a simple clipsable design.
// Interpreted as the absolute width of the cut.
socket_w_abs = .8; // Example value, adjust as needed.

// Global resolution for curved surfaces (adjust for smoother/faster rendering)
$fn = 60; // Number of faces for spheres and cylinders

// ball_joint_library.scad
//
// An OpenSCAD library for creating parametric open ball joints.
// Provides modules for both the spherical 'ball' and the 'socket' that houses it.
//
// Usage:
// To use these modules in your OpenSCAD design, include this file at the top:
// use <ball_joint_library.scad>

if(show == "joint" || show == "both")
{
if(show == "both")

    %rotate([180,0,0])ball_joint_ball(
        ball_radius = joint_radius,
        neck_radius = joint_neck_r,
        neck_height = joint_neck_h
    );
    else ball_joint_ball(
        ball_radius = joint_radius,
        neck_radius = joint_neck_r,
        neck_height = joint_neck_h
    );
    }

if(show == "socket" || show == "both")
    translate([0, 0, (show == "both") ? 0 * joint_neck_h : 0]) // Example: Position the socket above the ball
    ball_joint_socket(
        ball_radius = joint_radius,
        socket_wall_thickness = wd,
        socket_opening_angle = socket_opening_angle,
        neck_radius = joint_neck_r,
        neck_height = joint_neck_h,
        side_slot_ratio = socket_w_abs, // Use the global for the side slot width
        clearance = tol,
        width = socket_width
    );


/**
 * Module for the 'ball' part of an open ball joint.
 *
 * This module creates a spherical ball with a cylindrical neck extending
 * downwards (along the negative Z-axis) for attachment to another part.
 * The ball is centered at [0,0,0].
 *
 * @param ball_radius {Number} The radius of the spherical ball.
 * @param neck_radius {Number} The radius of the cylindrical neck.
 * @param neck_height {Number} The height of the cylindrical neck.
 */
module ball_joint_ball(
    ball_radius = joint_radius,
    neck_radius = joint_neck_r,
    neck_height = joint_neck_h
) {
    union() {
        sphere(r = ball_radius); // The main spherical ball

        // Cylindrical neck extending from the bottom of the ball
        translate([0, 0, -neck_height]) {
            cylinder(h = neck_height, r = neck_radius, center = false);
        }
    }
}


/**
 * Module for the 'socket' part of an open ball joint.
 *
 * This module creates a spherical socket designed to house a ball_joint_ball.
 * It features a flat top opening and a precisely blended cylindrical neck extending downwards
 * (along the negative Z-axis). The internal cavity precisely matches the ball it's designed for.
 * The socket is initially centered at [0,0,0].
 *
 * @param ball_radius {Number} The radius of the ball it's designed to house.
 * @param socket_wall_thickness {Number} The thickness of the socket's spherical wall.
 * @param clearance {Number} The small gap between the ball and the inner socket wall,
 * allowing for free movement.
 * @param neck_radius {Number} The radius of the cylindrical neck for attachment.
 * @param neck_height {Number} The height of the cylindrical neck.
 *
 * @param socket_opening_angle {Number} Angle (in degrees, 0-90) from the Z-axis
 * defining the flat top opening. 0 = almost closed top, 90 = hemisphere.
 *
 * @param side_slot_ratio {Number} The absolute width of the side slot cut from the socket.
 * This creates a basic clipsable opening. Set to 0 or leave out for no side slot.
 */
module ball_joint_socket(
    ball_radius = joint_radius,
    socket_wall_thickness = wd,
    clearance = tol,
    neck_radius = joint_neck_r,
    neck_height = joint_neck_h,
    socket_opening_angle = socket_opening_angle,
    side_slot_ratio = 0.8, // 1 for no side slot unless specified
    width= 5,
) {
    // Calculate the inner and outer radii of the socket
    inner_socket_radius = ball_radius + clearance; // Corrected: clearance applied once
    outer_socket_radius = inner_socket_radius + socket_wall_thickness; // Corrected: thickness applied once

    // Calculate the Z-coordinate where the neck's side touches the outer sphere for seamless blending.
    // This is the negative of the calculated blend depth from the sphere's center.
    neck_outer_blend_z = -sqrt(pow(outer_socket_radius, 2) - pow(neck_radius, 2));

    // Error check: Ensure neck_radius is not too large for blending
    if (neck_radius >= outer_socket_radius) {
        echo("WARNING: Neck radius (", neck_radius, ") is >= outer socket radius (", outer_socket_radius, "). Blending calculation invalid. Neck will extend from bottom pole.");
        neck_outer_blend_z = -outer_socket_radius; // Fallback to avoid NaN, cylinder starts from bottom pole
    }

    // Calculate the Z-coordinate where the INNER neck's side touches the INNER sphere for seamless blending.
    neck_inner_blend_z = -sqrt(pow(inner_socket_radius, 2) - pow(neck_radius, 2)); // Use neck_radius here, assuming inner neck is also this radius
    if (neck_radius >= inner_socket_radius) {
         echo("WARNING: Neck radius (", neck_radius, ") is >= inner socket radius (", inner_socket_radius, "). Inner blending calculation invalid. Inner neck will extend from inner sphere's bottom pole.");
         neck_inner_blend_z = -inner_socket_radius;
    }


    // Calculate the Z-coordinate for the flat top cut plane
    z_cut_plane = outer_socket_radius * cos(socket_opening_angle);
    endangle =180-asin(neck_radius/outer_socket_radius);


    // --- Main socket body using rotate_extrude for efficiency ---
    // This polygon defines the cross-section of the solid socket shell, including the neck.
    // It traces the outer boundary, then the inner boundary.
    socket_profile_points = [
        // 1. Outer profile: From flat top cut, along outer sphere, to outer neck.
        // Iterate points along the outer spherical arc, down to the neck blend point
        // Using $fn resolution for smooth curves
        for (theta = [socket_opening_angle : (180/$fn) : endangle])
            [outer_socket_radius * sin(theta), outer_socket_radius * cos(theta)],
        //neck
        [neck_radius, -outer_socket_radius - neck_height],
        [0, -outer_socket_radius - neck_height],
        //add a bottom layer
        [0, -outer_socket_radius - neck_height+wd],
        //v outcut
        [side_slot_ratio*neck_radius, -inner_socket_radius],
        // return Iterate points along the inner spherical arc, up to the lip
        // Using $fn resolution for smooth curves
        for (theta = [endangle : -(180/$fn) : socket_opening_angle])
            [inner_socket_radius * sin(theta), inner_socket_radius * cos(theta)],
    ];

    seg_angle = 2*asin(width/(2*outer_socket_radius));

        // Main socket body, including the neck and flat top, generated via rotate_extrude
        rotate([0,0,- seg_angle/2])
        rotate_extrude(angle= seg_angle) 
        polygon(socket_profile_points);
        mirror([1,0,0])
        {
        rotate([0,0,- seg_angle/2])
        rotate_extrude(angle= seg_angle) 
        polygon(socket_profile_points);
        }
        translate([0,0,-outer_socket_radius- neck_height])
        cylinder(r=neck_radius, h=wd);

}
