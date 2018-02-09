module View exposing (view)

import Categories.View as Cat
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode
import Messages exposing (Msg(..))
import Models exposing (..)
import PrayermateModels exposing (PrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Subjects.View as Subj
import Views as V


view : Model -> Html Msg
view model =
    Html.main_ [ A.class "min-w-screen min-h-screen bg-blue-lightest" ]
        [ navigation
        , Html.section [ A.class "w-full h-full p-6" ] [ mainContent model ]
        ]


navigation : Html msg
navigation =
    Html.ul [ A.class "list-reset flex w-full p-3 bg-grey-dark" ]
        [ Html.li [ A.class "mr-6" ]
            [ Html.a [ A.class "hover:text-blue-darker" ]
                [ Html.text "PrayerMate" ]
            ]
        , Html.li [ A.class "mr-6" ]
            [ Html.a [ A.class "hover:text-blue-darker" ]
                [ Html.text "About" ]
            ]
        ]


mainContent : Model -> Html Msg
mainContent model =
    case model.step of
        LandingPage ->
            landingView model.cachedData

        CategoriesList catStep ->
            mapRemoteView (Html.map CategoryMsg << Cat.view catStep) model.pm

        SubjectsList cat subStep ->
            mapRemoteView (Html.map SubjectMsg << Subj.view cat subStep << .categories) model.pm


mapRemoteView : (a -> Html Msg) -> WebData a -> Html Msg
mapRemoteView fn remote =
    case remote of
        NotAsked ->
            loadingIndicator

        Loading ->
            loadingIndicator

        Failure err ->
            Html.text <| niceErrMsg err

        Success data ->
            fn data


landingView : WebData PrayerMate -> Html Msg
landingView cachedData =
    Html.div []
        [ cachedSessionView cachedData
        , V.grid []
            [ V.button
                [ A.class "h-full w-full bg-blue" ]
                [ Html.p [] [ Html.text "Upload a .json file exported from PrayerMate" ]
                , Html.input
                    [ A.type_ "file"
                    , A.id "uploadPMFile"
                    , E.on "change" (Json.Decode.succeed <| FileSelected "uploadPMFile")
                    ]
                    []
                ]
            , V.button
                [ A.class "h-full w-full bg-blue hover:bg-blue-dark"
                , E.onClick LoadDemoData
                ]
                [ Html.text "Use Demo Data" ]
            ]
        ]


cachedSessionView : WebData PrayerMate -> Html Msg
cachedSessionView cachedData =
    case cachedData of
        Success pm ->
            V.button
                [ A.class "bg-indigo hover:bg-indigo-darker w-full p-4 my-4"
                , E.onClick LoadPreviousSession
                ]
                [ Html.p [ A.class "my-2" ] [ Html.text "It looks like you have a previous session, click here to restore it" ]
                , Html.p [ A.class "my-2" ] [ Html.text "If you load any other data, this previous session will be lost forever." ]
                ]

        _ ->
            Html.text ""


loadingIndicator : Html msg
loadingIndicator =
    Html.text "loading"


niceErrMsg : Http.Error -> String
niceErrMsg err =
    case err of
        Http.BadUrl s ->
            s

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "There is a network issue"

        Http.BadStatus { body } ->
            "Bad status from server " ++ body

        Http.BadPayload msg _ ->
            "Uh oh, something went wrong with that file. Sorry. (Bad payload: " ++ msg ++ ")"
