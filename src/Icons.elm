module Icons
    exposing
        ( calendar
        , cornerUpLeft
        , edit
        , move
        , nums
        , plus
        , x
        )

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes as A


-- https://1602.github.io/elm-feather-icons/


svgFeatherIcon : String -> List (Svg msg) -> Html msg
svgFeatherIcon className =
    svg
        [ A.class <| "feather feather-" ++ className
        , A.fill "none"
        , A.height "16"
        , A.stroke "currentColor"
        , A.strokeLinecap "round"
        , A.strokeLinejoin "round"
        , A.strokeWidth "2"
        , A.viewBox "0 0 24 24"
        , A.width "16"
        ]


svgFeatherIconThin : String -> List (Svg msg) -> Html msg
svgFeatherIconThin className =
    svg
        [ A.class <| "feather feather-" ++ className
        , A.fill "none"
        , A.height "16"
        , A.stroke "currentColor"
        , A.strokeLinecap "round"
        , A.strokeLinejoin "round"
        , A.strokeWidth "1"
        , A.viewBox "0 0 24 24"
        , A.width "16"
        ]


cornerUpLeft : Html msg
cornerUpLeft =
    svgFeatherIcon "corner-up-left"
        [ Svg.polyline [ A.points "9 14 4 9 9 4" ] []
        , Svg.path [ A.d "M20 20v-7a4 4 0 0 0-4-4H4" ] []
        ]


edit : Html msg
edit =
    svgFeatherIcon "edit"
        [ Svg.path [ A.d "M20 14.66V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h5.34" ] []
        , Svg.polygon [ A.points "18 2 22 6 12 16 8 16 8 12 18 2" ] []
        ]


plus : Html msg
plus =
    svgFeatherIcon "plus"
        [ Svg.line [ A.x1 "12", A.y1 "5", A.x2 "12", A.y2 "19" ] []
        , Svg.line [ A.x1 "5", A.y1 "12", A.x2 "19", A.y2 "12" ] []
        ]


x : Html msg
x =
    svgFeatherIcon "x"
        [ Svg.line [ A.x1 "18", A.y1 "6", A.x2 "6", A.y2 "18" ] []
        , Svg.line [ A.x1 "6", A.y1 "6", A.x2 "18", A.y2 "18" ] []
        ]


move : Html msg
move =
    svgFeatherIcon "move"
        [ Svg.polyline [ A.points "5 9 2 12 5 15" ] []
        , Svg.polyline [ A.points "9 5 12 2 15 5" ] []
        , Svg.polyline [ A.points "15 19 12 22 9 19" ] []
        , Svg.polyline [ A.points "19 9 22 12 19 15" ] []
        , Svg.line [ A.x1 "2", A.y1 "12", A.x2 "22", A.y2 "12" ] []
        , Svg.line [ A.x1 "12", A.y1 "2", A.x2 "12", A.y2 "22" ] []
        ]


calendar : Html msg
calendar =
    svgFeatherIcon "calendar"
        [ Svg.rect [ A.x "3", A.y "4", A.width "18", A.height "18", A.rx "2", A.ry "2" ] []
        , Svg.line [ A.x1 "16", A.y1 "2", A.x2 "16", A.y2 "6" ] []
        , Svg.line [ A.x1 "8", A.y1 "2", A.x2 "8", A.y2 "6" ] []
        , Svg.line [ A.x1 "3", A.y1 "10", A.x2 "21", A.y2 "10" ] []
        ]


nums : Html msg
nums =
    svgFeatherIconThin "nums"
        [ Svg.text_ [ A.x "3", A.y "12", A.fontFamily "Verdana", A.fontSize "10" ] [ Svg.text "1" ]
        , Svg.text_ [ A.x "15", A.y "12", A.fontFamily "Verdana", A.fontSize "10" ] [ Svg.text "2" ]
        , Svg.text_ [ A.x "9", A.y "24", A.fontFamily "Verdana", A.fontSize "10" ] [ Svg.text "3" ]
        ]
