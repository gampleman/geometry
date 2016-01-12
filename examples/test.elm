import Html exposing (Html, div, text)
import Time exposing (Time, fps)
import Signal exposing (Signal)
import Svg.Attributes exposing (stroke, strokeWidth)
import OpenSolid.Interval as Interval exposing (Interval)
import OpenSolid.Vector2d as Vector2d exposing (Vector2d)
import OpenSolid.Point2d as Point2d exposing (Point2d)
import OpenSolid.Direction2d as Direction2d exposing (Direction2d)
import OpenSolid.LineSegment2d as LineSegment2d exposing (LineSegment2d)
import OpenSolid.Transformation2d as Transformation2d exposing (Transformation2d)
import OpenSolid.Box2d as Box2d exposing (Box2d)
import OpenSolid.Svg as Svg exposing (svg)


line: String -> a -> Html
line label value =
  div [] [text (label ++ ": " ++ toString value)]


transform: LineSegment2d -> LineSegment2d
transform =
  LineSegment2d.transformedBy (Transformation2d.rotationAbout Point2d.origin (degrees 45))


lines: Html
lines =
  let
    intervalWidth = Interval.width (Interval 2 3)
    vectorLength = Vector2d.length (Vector2d 1 1)
    pointDifference = Point2d.minus Point2d.origin (Point2d 1 2)
    rotation = Transformation2d.rotationAbout Point2d.origin (degrees 45)
    lineSegment = LineSegment2d (Point2d 1 0) (Point2d 2 0)
    transformedSegment = LineSegment2d.transformedBy rotation lineSegment
    transformedSegment2 = transform lineSegment
    mixedDotProduct = Vector2d.dot Direction2d.x (Vector2d 2 3)
    rotatedDirection = Direction2d.transformedBy rotation Direction2d.x
    angledDotProduct = Vector2d.dot rotatedDirection (Vector2d 2 3)
  in
    div []
      [ line "Interval width" intervalWidth
      , line "Vector length" vectorLength
      , line "Point difference" pointDifference
      , line "Transformed line segment" transformedSegment
      , line "Transformed line segment 2" transformedSegment2
      , line "Mixed dot product" mixedDotProduct
      , line "Rotated direction" rotatedDirection
      , line "Angled dot product" angledDotProduct
      ]


angularSpeed: Float
angularSpeed =
  -pi / 8


update: Time -> Float -> Float
update deltaTime angle =
  angle + angularSpeed * (deltaTime / Time.second)


view: Float -> Html
view angle =
  let
    lineSegment = LineSegment2d (Point2d 5 0) (Point2d 10 0)
    segments =
      List.map
        ( (\index -> angle + index * degrees 15) >>
          (\angle -> Transformation2d.rotationAbout Point2d.origin angle) >>
          (\rotation -> LineSegment2d.transformedBy rotation lineSegment) )
        [0..18]
    elements = List.map (Svg.lineSegment [stroke "blue", strokeWidth "0.05"]) segments
  in
    div [] [lines, svg 500 500 (Box2d (Interval -10 10) (Interval -10 10)) elements]


main: Signal Html
main =
  Signal.foldp update 0.0 (fps 120) |> Signal.map view
