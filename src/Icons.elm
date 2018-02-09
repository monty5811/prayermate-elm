module Icons
    exposing
        ( cornerUpLeft
        , edit
        , move
        , plus
        , x
        )

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)


-- https://1602.github.io/elm-feather-icons/


svgFeatherIcon : String -> List (Svg msg) -> Html msg
svgFeatherIcon className =
    svg
        [ class <| "feather feather-" ++ className
        , fill "none"
        , height "16"
        , stroke "currentColor"
        , strokeLinecap "round"
        , strokeLinejoin "round"
        , strokeWidth "2"
        , viewBox "0 0 24 24"
        , width "16"
        ]


cornerUpLeft : Html msg
cornerUpLeft =
    svgFeatherIcon "corner-up-left"
        [ Svg.polyline [ points "9 14 4 9 9 4" ] []
        , Svg.path [ d "M20 20v-7a4 4 0 0 0-4-4H4" ] []
        ]


edit : Html msg
edit =
    svgFeatherIcon "edit"
        [ Svg.path [ d "M20 14.66V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h5.34" ] []
        , Svg.polygon [ points "18 2 22 6 12 16 8 16 8 12 18 2" ] []
        ]


plus : Html msg
plus =
    svgFeatherIcon "plus"
        [ Svg.line [ x1 "12", y1 "5", x2 "12", y2 "19" ] []
        , Svg.line [ x1 "5", y1 "12", x2 "19", y2 "12" ] []
        ]


x : Html msg
x =
    svgFeatherIcon "x"
        [ Svg.line [ x1 "18", y1 "6", x2 "6", y2 "18" ] []
        , Svg.line [ x1 "6", y1 "6", x2 "18", y2 "18" ] []
        ]


move : Html msg
move =
    svgFeatherIcon "move"
        [ Svg.polyline [ points "5 9 2 12 5 15" ] []
        , Svg.polyline [ points "9 5 12 2 15 5" ] []
        , Svg.polyline [ points "15 19 12 22 9 19" ] []
        , Svg.polyline [ points "19 9 22 12 19 15" ] []
        , Svg.line [ x1 "2", y1 "12", x2 "22", y2 "12" ] []
        , Svg.line [ x1 "12", y1 "2", x2 "12", y2 "22" ] []
        ]
