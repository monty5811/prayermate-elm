module Main exposing (main)

import Http
import Messages exposing (Msg(..))
import Models exposing (Model, Step(..), decodePrayerMate2WebData, initialCategoriesStep, initialModel)
import Navigation
import Ports exposing (dropboxLinkRead, fileContentRead, fileSelected)
import Prayermate exposing (PrayerMate, encodePrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Time
import Update
import UrlParser
import View exposing (view)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags
        UrlChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    let
        page =
            location2step loc
    in
    ( initialModel flags page, fetchAbout )


location2step : Navigation.Location -> Step
location2step location =
    UrlParser.parsePath Route.route location
        |> Maybe.withDefault LandingPage


type alias Flags =
    { cachedData : String
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, cmd ) =
            Update.update msg model
    in
    ( newModel
    , Cmd.batch
        [ cacheData msg newModel.pm
        , cmd
        ]
    )


cacheData : Msg -> WebData PrayerMate -> Cmd msg
cacheData msg pm =
    case msg of
        ReceiveTime _ ->
            -- skip on ticks
            Cmd.none

        _ ->
            case pm of
                Success data ->
                    encodePrayerMate data
                        |> Ports.saveData

                _ ->
                    Cmd.none


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ fileContentRead FileRead
        , dropboxLinkRead ReceiveDropboxLink
        , Time.every Time.second (\t -> ReceiveTime t)
        ]


fetchAbout : Cmd Msg
fetchAbout =
    Http.getString "/about.md"
        |> RemoteData.sendRequest
        |> Cmd.map ReceiveAbout
