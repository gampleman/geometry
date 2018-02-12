module Tests.Axis3d
    exposing
        ( directionExample
        , jsonRoundTrips
        , onExamples
        , originPointExample
        , xExample
        , yExample
        , zExample
        )

import Axis2d
import Axis3d
import Direction2d
import Direction3d
import Geometry.Decode as Decode
import Geometry.Encode as Encode
import Geometry.Expect as Expect
import Geometry.Fuzz as Fuzz
import Point2d
import Point3d
import SketchPlane3d
import Test exposing (Test)
import Tests.Generic as Generic


jsonRoundTrips : Test
jsonRoundTrips =
    Generic.jsonRoundTrips Fuzz.axis3d Encode.axis3d Decode.axis3d


xExample : Test
xExample =
    Test.test "Axis3d.x example" <|
        \() ->
            Axis3d.x
                |> Expect.axis3d
                    (Axis3d.with
                        { originPoint = Point3d.origin
                        , direction = Direction3d.x
                        }
                    )


yExample : Test
yExample =
    Test.test "Axis3d.y example" <|
        \() ->
            Axis3d.y
                |> Expect.axis3d
                    (Axis3d.with
                        { originPoint = Point3d.origin
                        , direction = Direction3d.y
                        }
                    )


zExample : Test
zExample =
    Test.test "Axis3d.z example" <|
        \() ->
            Axis3d.z
                |> Expect.axis3d
                    (Axis3d.with
                        { originPoint = Point3d.origin
                        , direction = Direction3d.z
                        }
                    )


originPointExample : Test
originPointExample =
    Test.test "Axis3d.originPoint example" <|
        \() ->
            Axis3d.originPoint Axis3d.x |> Expect.point3d Point3d.origin


directionExample : Test
directionExample =
    Test.test "Axis3d.direction example" <|
        \() ->
            Axis3d.direction Axis3d.y |> Expect.direction3d Direction3d.y


onExamples : Test
onExamples =
    let
        axis2d =
            Axis2d.with
                { originPoint = Point2d.fromCoordinates ( 1, 3 )
                , direction = Direction2d.fromAngle (degrees 30)
                }
    in
    Test.describe "Axis3d.on examples"
        [ Test.test "First example" <|
            \() ->
                Axis3d.on SketchPlane3d.xy axis2d
                    |> Expect.axis3d
                        (Axis3d.with
                            { originPoint =
                                Point3d.fromCoordinates ( 1, 3, 0 )
                            , direction =
                                Direction3d.with
                                    { azimuth = degrees 30
                                    , elevation = 0
                                    }
                            }
                        )
        , Test.test "Second example" <|
            \() ->
                Axis3d.on SketchPlane3d.zx axis2d
                    |> Expect.axis3d
                        (Axis3d.with
                            { originPoint =
                                Point3d.fromCoordinates ( 3, 0, 1 )
                            , direction =
                                Direction3d.with
                                    { azimuth = 0
                                    , elevation = degrees 60
                                    }
                            }
                        )
        ]