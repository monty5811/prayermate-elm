module Views exposing (..)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E


rawButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
rawButton attrs nodes =
    Html.button (List.append [ A.class "font-bold py-2 px-4 rounded" ] attrs) nodes


button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attrs nodes =
    rawButton (List.append [ A.class "text-white" ] attrs) nodes


greenButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
greenButton attrs nodes =
    button (A.class "bg-green hover:bg-green-dark" :: attrs) nodes


redButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
redButton attrs nodes =
    button (A.class "bg-red hover:bg-red-dark" :: attrs) nodes


greyButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
greyButton attrs nodes =
    button (A.class "bg-grey hover:bg-grey-dark" :: attrs) nodes


invertedButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
invertedButton attrs nodes =
    rawButton (List.append [ A.class "text-black" ] attrs) nodes


grid : List (Html.Attribute msg) -> List (Html msg) -> Html msg
grid attrs nodes =
    gridWithOptions defaultGridOptions attrs nodes


type alias GridOptions =
    { maxCols : Int
    , gridGap : Int
    , minHeight : Int
    }


defaultGridOptions : GridOptions
defaultGridOptions =
    { maxCols = 4
    , gridGap = 10
    , minHeight = 600
    }


gridWithOptions : GridOptions -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
gridWithOptions opts attrs nodes =
    let
        nNodes =
            List.length nodes

        cols =
            if nNodes > opts.maxCols then
                opts.maxCols
            else
                nNodes
    in
    Html.div
        (A.style
            [ ( "display", "grid" )
            , ( "grid-template-columns", "repeat(" ++ (cols |> toString) ++ ", 1fr)" )
            , ( "grid-gap", toString opts.gridGap ++ "px" )
            , ( "grid-auto-rows", "minmax(" ++ toString opts.minHeight ++ "px, auto)" )
            ]
            :: attrs
        )
        nodes


kanban : List (Html.Attribute msg) -> List (Html msg) -> Html msg
kanban attrs nodes =
    kanbanWithOptions defaultKanBanOptions attrs nodes


type alias KanBanOptions =
    { colWidth : Int
    , gridGap : Int
    , minHeight : Int
    }


defaultKanBanOptions : KanBanOptions
defaultKanBanOptions =
    { colWidth = 270
    , gridGap = 10
    , minHeight = 400
    }


kanbanWithOptions : KanBanOptions -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
kanbanWithOptions opts attrs nodes =
    Html.div
        (A.style
            [ ( "display", "grid" )
            , ( "grid-template-columns", "repeat(" ++ (List.length nodes |> toString) ++ ", " ++ toString opts.colWidth ++ "px)" )
            , ( "grid-gap", toString opts.gridGap ++ "px" )
            , ( "grid-auto-rows", "minmax(" ++ toString opts.minHeight ++ "px, auto)" )
            ]
            :: attrs
        )
        nodes


form : List (Html.Attribute msg) -> List (Html msg) -> Html msg
form attrs nodes =
    Html.form (A.class "bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4" :: attrs) nodes


textInput : (String -> msg) -> String -> Html msg
textInput onInput value =
    Html.input
        [ A.type_ "text"
        , A.class "shadow appearance-none border rounded w-full py-2 px-3 mb-2 text-grey-darker"
        , A.value value
        , A.id "focusable"
        , E.onInput onInput
        ]
        []


textArea : Int -> (String -> msg) -> String -> Html msg
textArea rows onInput value =
    Html.textarea
        [ A.class "shadow appearance-none border rounded w-full py-2 px-3 mb-2 text-grey-darker"
        , A.value value
        , A.rows rows
        , A.cols 30
        , A.id "focusable"
        , E.onInput onInput
        ]
        []