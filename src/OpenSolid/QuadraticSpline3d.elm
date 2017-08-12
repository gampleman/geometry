module OpenSolid.QuadraticSpline3d
    exposing
        ( bezier
        , bisect
        , controlPoints
        , derivative
        , endDerivative
        , endPoint
        , evaluate
        , mirrorAcross
        , placeIn
        , point
        , pointOn
        , projectInto
        , projectOnto
        , relativeTo
        , reverse
        , rotateAround
        , scaleAbout
        , splitAt
        , startDerivative
        , startPoint
        , translateBy
        )

{-| <img src="https://opensolid.github.io/images/geometry/icons/quadraticSpline3d.svg" alt="QuadraticSpline3d" width="160">

A `QuadraticSpline3d` is a quadratic [Bézier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve)
in 3D defined by three control points. This module contains functionality for

  - Evaluating points and derivatives along a spline
  - Scaling, rotating, translating or mirroring a spline
  - Converting a spline between local and global coordinates in different
    reference frames

Splines can be constructed by passing a tuple of control points to the
`QuadraticSpline3d` constructor, for example

    exampleSpline =
        QuadraticSpline3d
            ( Point3d ( 1, 1, 1 )
            , Point3d ( 3, 2, 1 )
            , Point3d ( 3, 3, 3 )
            )


# Constructors

@docs bezier


# Accessors

@docs controlPoints, startPoint, endPoint, startDerivative, endDerivative


# Evaluation

@docs pointOn, point, derivative, evaluate


# Transformations

@docs reverse, scaleAbout, rotateAround, translateBy, mirrorAcross, projectOnto


# Coordinate frames

@docs relativeTo, placeIn


# Sketch planes

@docs projectInto


# Subdivision

@docs bisect, splitAt

-}

import OpenSolid.Geometry.Types exposing (..)
import OpenSolid.Point3d as Point3d
import OpenSolid.Vector3d as Vector3d


{-| Construct a spline from its three control points. This is the same as just
using the `QuadraticSpline3d` constructor directly;

    QuadraticSpline3d.bezier p1 p2 p3

is equivalent to

    QuadraticSpline3d ( p1, p2, p3 )

-}
bezier : Point3d -> Point3d -> Point3d -> QuadraticSpline3d
bezier firstPoint secondPoint thirdPoint =
    QuadraticSpline3d ( firstPoint, secondPoint, thirdPoint )


{-| Get the control points of a spline as a tuple.

    ( p1, p2, p3 ) =
        QuadraticSpline3d.controlPoints exampleSpline


    --> p1 = Point3d ( 1, 1, 1 )
    --> p2 = Point3d ( 3, 2, 1 )
    --> p3 = Point3d ( 3, 3, 3 )

-}
controlPoints : QuadraticSpline3d -> ( Point3d, Point3d, Point3d )
controlPoints (QuadraticSpline3d controlPoints_) =
    controlPoints_


{-| Get the start point of a spline. This is equal to the spline's first control
point.

    QuadraticSpline3d.startPoint exampleSpline
    --> Point3d ( 1, 1, 1 )

-}
startPoint : QuadraticSpline3d -> Point3d
startPoint (QuadraticSpline3d ( p1, _, _ )) =
    p1


{-| Get the end point of a spline. This is equal to the spline's last control
point.

    QuadraticSpline3d.endPoint exampleSpline
    --> Point3d ( 3, 3, 3 )

-}
endPoint : QuadraticSpline3d -> Point3d
endPoint (QuadraticSpline3d ( _, _, p3 )) =
    p3


{-| Get the start derivative of a spline. This is equal to twice the vector from
the spline's first control point to its second.

    QuadraticSpline3d.startDerivative exampleSpline
    --> Vector3d ( 4, 2, 0 )

-}
startDerivative : QuadraticSpline3d -> Vector3d
startDerivative spline =
    let
        ( p1, p2, _ ) =
            controlPoints spline
    in
    Vector3d.from p1 p2 |> Vector3d.scaleBy 2


{-| Get the end derivative of a spline. This is equal to twice the vector from
the spline's second control point to its third.

    QuadraticSpline3d.endDerivative exampleSpline
    --> Vector3d ( 0, 2, 4 )

-}
endDerivative : QuadraticSpline3d -> Vector3d
endDerivative spline =
    let
        ( _, p2, p3 ) =
            controlPoints spline
    in
    Vector3d.from p2 p3 |> Vector3d.scaleBy 2


{-| Get a point along a spline, based on a parameter that ranges from 0 to 1. A
parameter value of 0 corresponds to the start point of the spline and a value of
1 corresponds to the end point.

    QuadraticSpline3d.pointOn exampleSpline 0
    --> Point3d ( 1, 1, 1 )

    QuadraticSpline3d.pointOn exampleSpline 0.5
    --> Point3d ( 2.5, 2, 1.5 )

    QuadraticSpline3d.pointOn exampleSpline 1
    --> Point3d ( 3, 3, 3 )

-}
pointOn : QuadraticSpline3d -> Float -> Point3d
pointOn spline t =
    let
        ( p1, p2, p3 ) =
            controlPoints spline

        q1 =
            Point3d.interpolateFrom p1 p2 t

        q2 =
            Point3d.interpolateFrom p2 p3 t
    in
    Point3d.interpolateFrom q1 q2 t


{-| DEPRECATED: Alias for `pointOn`, kept for compatibility. Use `pointOn`
instead.
-}
point : QuadraticSpline3d -> Float -> Point3d
point =
    pointOn


{-| Get the deriative value at a point along a spline, based on a parameter that
ranges from 0 to 1. A parameter value of 0 corresponds to the start derivative
of the spline and a value of 1 corresponds to the end derivative.

    QuadraticSpline3d.derivative exampleSpline 0
    --> Vector3d ( 4, 2, 0 )

    QuadraticSpline3d.derivative exampleSpline 0.5
    --> Vector3d ( 2, 2, 2 )

    QuadraticSpline3d.derivative exampleSpline 1
    --> Vector3d ( 0, 2, 4 )

Note that the derivative interpolates linearly from end to end.

-}
derivative : QuadraticSpline3d -> Float -> Vector3d
derivative spline =
    let
        ( p1, p2, p3 ) =
            controlPoints spline

        v1 =
            Vector3d.from p1 p2

        v2 =
            Vector3d.from p2 p3
    in
    \t -> Vector3d.interpolateFrom v1 v2 t |> Vector3d.scaleBy 2


{-| Evaluate a spline at a given parameter value, returning the point on the
spline at that parameter value and the derivative with respect to that parameter
value;

    QuadraticSpline3d.evaluate spline t

is equivalent to

    ( QuadraticSpline3d.pointOn spline t
    , QuadraticSpline3d.derivative spline t
    )

but is more efficient.

-}
evaluate : QuadraticSpline3d -> Float -> ( Point3d, Vector3d )
evaluate spline t =
    let
        ( p1, p2, p3 ) =
            controlPoints spline

        q1 =
            Point3d.interpolateFrom p1 p2 t

        q2 =
            Point3d.interpolateFrom p2 p3 t
    in
    ( Point3d.interpolateFrom q1 q2 t
    , Vector3d.from q1 q2 |> Vector3d.scaleBy 2
    )


mapControlPoints : (Point3d -> Point3d) -> QuadraticSpline3d -> QuadraticSpline3d
mapControlPoints function spline =
    let
        ( p1, p2, p3 ) =
            controlPoints spline
    in
    QuadraticSpline3d ( function p1, function p2, function p3 )


{-| Reverse a spline so that the start point becomes the end point, and vice
versa.

    QuadraticSpline3d.reverse exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 3, 3, 3 )
    -->     , Point3d ( 3, 2, 1 )
    -->     , Point3d ( 1, 1, 1 )
    -->     )

-}
reverse : QuadraticSpline3d -> QuadraticSpline3d
reverse spline =
    let
        ( p1, p2, p3 ) =
            controlPoints spline
    in
    QuadraticSpline3d ( p3, p2, p1 )


{-| Scale a spline about the given center point by the given scale.

    QuadraticSpline3d.scaleAbout Point3d.origin 2 exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 2, 2, 2 )
    -->     , Point3d ( 6, 4, 2 )
    -->     , Point3d ( 6, 6, 6 )
    -->     )

-}
scaleAbout : Point3d -> Float -> QuadraticSpline3d -> QuadraticSpline3d
scaleAbout point scale =
    mapControlPoints (Point3d.scaleAbout point scale)


{-| Rotate a spline counterclockwise around a given axis by a given angle (in
radians).

    QuadraticSpline3d.rotateAround Axis3d.z (degrees 90) exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( -1, 1, 1 )
    -->     , Point3d ( -2, 3, 1 )
    -->     , Point3d ( -3, 3, 3 )
    -->     )

-}
rotateAround : Axis3d -> Float -> QuadraticSpline3d -> QuadraticSpline3d
rotateAround axis angle =
    mapControlPoints (Point3d.rotateAround axis angle)


{-| Translate a spline by a given displacement.

    displacement =
        Vector3d ( 2, 3, 1 )

    QuadraticSpline3d.translateBy displacement exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 3, 4, 2 )
    -->     , Point3d ( 5, 5, 2 )
    -->     , Point3d ( 5, 6, 4 )
    -->     )

-}
translateBy : Vector3d -> QuadraticSpline3d -> QuadraticSpline3d
translateBy displacement =
    mapControlPoints (Point3d.translateBy displacement)


{-| Mirror a spline across a plane.

    QuadraticSpline3d.mirrorAcross Plane3d.xy exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 1, 1, -1 )
    -->     , Point3d ( 3, 2, -1 )
    -->     , Point3d ( 3, 3, -3 )
    -->     )

-}
mirrorAcross : Plane3d -> QuadraticSpline3d -> QuadraticSpline3d
mirrorAcross plane =
    mapControlPoints (Point3d.mirrorAcross plane)


{-| Project a spline onto a plane.

    QuadraticSpline3d.projectOnto Plane3d.xy exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 1, 1, 0 )
    -->     , Point3d ( 3, 2, 0 )
    -->     , Point3d ( 3, 3, 0 )
    -->     )

-}
projectOnto : Plane3d -> QuadraticSpline3d -> QuadraticSpline3d
projectOnto plane =
    mapControlPoints (Point3d.projectOnto plane)


{-| Take a spline defined in global coordinates, and return it expressed in
local coordinates relative to a given reference frame.

    localFrame =
        Frame3d.at (Point3d ( 1, 2, 3 ))

    QuadraticSpline3d.relativeTo localFrame exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 0, -1, -2 )
    -->     , Point3d ( 2, 0, -2 )
    -->     , Point3d ( 2, 1, 0 )
    -->     )

-}
relativeTo : Frame3d -> QuadraticSpline3d -> QuadraticSpline3d
relativeTo frame =
    mapControlPoints (Point3d.relativeTo frame)


{-| Take a spline considered to be defined in local coordinates relative to a
given reference frame, and return that spline expressed in global coordinates.

    localFrame =
        Frame3d.at (Point3d ( 1, 2, 3 ))

    QuadraticSpline3d.placeIn localFrame exampleSpline
    --> QuadraticSpline3d
    -->     ( Point3d ( 2, 3, 4 )
    -->     , Point3d ( 4, 4, 4 )
    -->     , Point3d ( 4, 5, 6 )
    -->     )

-}
placeIn : Frame3d -> QuadraticSpline3d -> QuadraticSpline3d
placeIn frame =
    mapControlPoints (Point3d.placeIn frame)


{-| Project a spline into a given sketch plane. Conceptually, this
projects the spline onto the plane and then expresses the projected
spline in 2D sketch coordinates.

    QuadraticSpline3d.projectInto SketchPlane3d.yz exampleSpline
    --> QuadraticSpline2d
    -->     ( Point2d ( 1, 1 )
    -->     , Point2d ( 2, 1 )
    -->     , Point2d ( 3, 3 )
    -->     )

-}
projectInto : SketchPlane3d -> QuadraticSpline3d -> QuadraticSpline2d
projectInto sketchPlane spline =
    let
        ( p1, p2, p3 ) =
            controlPoints spline

        project =
            Point3d.projectInto sketchPlane
    in
    QuadraticSpline2d ( project p1, project p2, project p3 )


{-| Split a spline into two roughly equal halves. Equivalent to `splitAt 0.5`.

    QuadraticSpline3d.bisect exampleSpline
    --> ( QuadraticSpline3d
    -->     ( Point3d ( 1, 1, 1 )
    -->     , Point3d ( 2, 2.5 )
    -->     , Point3d ( 3, 2.5 )
    -->     )
    --> , QuadraticSpline3d
    -->     ( Point3d ( 3, 2.5 )
    -->     , Point3d ( 4, 2.5 )
    -->     , Point3d ( 3, 3, 3 )
    -->     )
    --> )

-}
bisect : QuadraticSpline3d -> ( QuadraticSpline3d, QuadraticSpline3d )
bisect =
    splitAt 0.5


{-| Split a spline at a particular parameter value (in the range 0 to 1),
resulting in two smaller splines.

    QuadraticSpline3d.splitAt 0.75 exampleSpline
    --> ( QuadraticSpline3d
    -->     ( Point3d ( 1, 1, 1 )
    -->     , Point3d ( 2, 1.5, 1 )
    -->     , Point3d ( 2.5, 2, 1.5 )
    -->     )
    --> , QuadraticSpline3d
    -->     ( Point3d ( 2.5, 2, 1.5 )
    -->     , Point3d ( 3, 2.5, 2 )
    -->     , Point3d ( 3, 3, 3 )
    -->     )
    --> )

-}
splitAt : Float -> QuadraticSpline3d -> ( QuadraticSpline3d, QuadraticSpline3d )
splitAt t spline =
    let
        ( p1, p2, p3 ) =
            controlPoints spline

        q1 =
            Point3d.interpolateFrom p1 p2 t

        q2 =
            Point3d.interpolateFrom p2 p3 t

        r =
            Point3d.interpolateFrom q1 q2 t
    in
    ( QuadraticSpline3d ( p1, q1, r )
    , QuadraticSpline3d ( r, q2, p3 )
    )
