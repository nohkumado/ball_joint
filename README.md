# ball joint
an openscad library to generated ball joints, remix from  Gael Lafond's solution
he had a separate lib for the helix part, since i only use his lib with the ball joint i merged them.

## Inherited README's
### Helix library for OpenSCAD by gaellafond on (Thingiverse)[https://www.thingiverse.com/thing:2200395]

#### Summary

Yet another OpenSCAD library to create helices.

There is plenty of libraries out there, but most of them are unpredictable. The height, width, angle, etc are not respected, making it very hard to create precise model.

This library is very precise, flexible and easy to use. It takes a 2D polygon and extrude it just like linear\_extrude and rotate\_extrude.

2018-02-24: Added a default value for the number of segments (precision) when $fn is not defined.
Issues

Using hull() to join polygons has some downsides:

    Polygons needs to be extruded into 3D shape for hull to work properly.

    Concave polygons are made convex.

    Hull is overkill for what I'm doing, it takes too long to render.

The only way I can see to fix this without changing the API is to iterate through points of the polygon, and create the polyhedron manually. Unfortunately, this is not possible with the current version of OpenSCAD.

I could change the API and expect an array of points representing the polygon, but I don't like that idea. I want it to works like the other extrude functions.

A workaround for the concave issue is to create a convex polygon and extrude it with helix\_extrude. Then create another polygon, extrude it with helix\_extrude and create a difference between the two helices.

##### Usage

```
include <helix\_extrude.scad>
helix_extrude()
    translate([10, 0, 0])
        circle(r=3);
```




## Universal Ball Jointv by gaellafond on (Thingiverse)[https://www.thingiverse.com/thing:5136665]

This is intended to be used as a library in other projects.

Example:

```
    use <balljoint.scad>;
    balljoint_ball();
    balljoint_seat();
    balljoint_nut();
```

If you need a smaller or larger ball joint, use "scale".

Example:

```
    use <balljoint.scad>;
    scale(2) balljoint_ball();
    scale(2) balljoint_seat();
    scale(2) balljoint_nut();
```

The ball joint was tested using the defined dimensions. Changing the dimensions may generate disfunctional parts. If you need to change the dimensions, import the library using "include" instead of "use" and overwrite the appropriate variables.

Example:

```
    include <balljoint.scad>;
    balljoint_ball_dia = 30;
    balljoint_ball();
    balljoint_seat();
    balljoint_nut();
```

Inspired from:

    (Universal Ball Joint by MORONator)[https://www.thingiverse.com/thing:5020323]

Unit: millimetres.
