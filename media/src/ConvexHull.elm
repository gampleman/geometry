module ConvexHull exposing (..)

import Html exposing (Html)
import Html.Events
import OpenSolid.BoundingBox2d as BoundingBox2d exposing (BoundingBox2d)
import OpenSolid.Point2d as Point2d exposing (Point2d)
import OpenSolid.Polygon2d as Polygon2d
import OpenSolid.Svg as Svg
import Random exposing (Generator)
import Svg
import Svg.Attributes


type alias Model =
    { points : List Point2d
    }


type Msg
    = Click
    | NewRandomPoints (List Point2d)


renderBounds : BoundingBox2d
renderBounds =
    BoundingBox2d.fromExtrema
        { minX = 0
        , maxX = 800
        , minY = 0
        , maxY = 600
        }


pointsGenerator : Generator (List Point2d)
pointsGenerator =
    let
        { minX, maxX, minY, maxY } =
            BoundingBox2d.extrema renderBounds

        pointGenerator =
            Random.map2 (\x y -> Point2d.fromCoordinates ( x, y ))
                (Random.float (minX + 30) (maxX - 30))
                (Random.float (minY + 30) (maxY - 30))
    in
    Random.int 2 32
        |> Random.andThen
            (\listSize -> Random.list listSize pointGenerator)


generateNewPoints : Cmd Msg
generateNewPoints =
    Random.generate NewRandomPoints pointsGenerator


init : ( Model, Cmd Msg )
init =
    ( { points = [] }, generateNewPoints )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Click ->
            ( model, generateNewPoints )

        NewRandomPoints points ->
            ( { model | points = points }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        convexHull =
            Polygon2d.fromConvexHull model.points
    in
    Html.div [ Html.Events.onClick Click ]
        [ Svg.render2d renderBounds <|
            Svg.g []
                [ Svg.polygon2d
                    [ Svg.Attributes.fill "lightblue"
                    , Svg.Attributes.stroke "blue"
                    ]
                    convexHull
                , Svg.g [] <|
                    List.indexedMap
                        (\index point -> Svg.text2d [] point (toString index))
                        (Polygon2d.vertices convexHull)
                , Svg.g [] (List.map (Svg.point2d []) model.points)
                ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }