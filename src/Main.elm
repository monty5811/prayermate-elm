module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Http
import Messages exposing (Msg(..))
import Models exposing (Model, Step(..), decodePrayerMate2WebData, initialCategoriesStep, initialModel)
import Ports exposing (dropboxLinkRead, fileContentRead, fileSelected)
import Prayermate exposing (PrayerMate, encodePrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Time
import Update
import Url
import Url.Parser
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = urlRequest
        , onUrlChange = UrlChange
        }


urlRequest : Browser.UrlRequest -> Msg
urlRequest req =
    NoOp


init : Flags -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags loc navKey =
    let
        page =
            location2step loc
    in
    ( initialModel navKey flags page, fetchAbout )


location2step : Url.Url -> Step
location2step url =
    Url.Parser.parse Route.route url
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
        , Time.every 1000 (\t -> ReceiveTime t)
        ]


fetchAbout : Cmd Msg
fetchAbout =
    Http.getString "/about.md"
        |> RemoteData.sendRequest
        |> Cmd.map ReceiveAbout
