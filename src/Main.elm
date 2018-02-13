module Main exposing (main)

import Categories.Update as Cat
import CsvConvert
import Http
import Messages exposing (Msg(..))
import Models exposing (Model, Step(..), decodePrayerMate2WebData, initialCategoriesStep, initialModel)
import Navigation
import Ports exposing (fileContentRead, fileSelected)
import Prayermate exposing (Category, PrayerMate, decodePrayerMate, encodePrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Subjects.Update as Subj
import Time
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
    ( initialModel flags page, Cmd.none )


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
            updateHelp msg model
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


updateHelp : Msg -> Model -> ( Model, Cmd Msg )
updateHelp msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChange _ ->
            -- ignore for now
            ( model, Cmd.none )

        LoadPreviousSession ->
            ( { model
                | pm = model.cachedData
                , originalPm = model.cachedData
                , step = initialCategoriesStep
              }
            , Cmd.none
            )

        LoadDemoData ->
            ( { model | step = initialCategoriesStep }, loadDemoData )

        FileSelected id ->
            ( model, fileSelected id )

        FileRead { contents, id } ->
            case id of
                "uploadPMFile" ->
                    let
                        pm =
                            decodePrayerMate2WebData contents
                    in
                    ( { model
                        | pm = pm
                        , originalPm = pm
                        , step = initialCategoriesStep
                      }
                    , Cmd.none
                    )

                "uploadCsvFile" ->
                    handleCsvMsg (CsvConvert.InputChanged contents) model

                _ ->
                    ( model, Cmd.none )

        ReceivePrayerMate pm ->
            ( { model | pm = pm, originalPm = pm }, Cmd.none )

        CategoryMsg subMsg ->
            let
                ( step, cats, cmd ) =
                    Cat.update
                        model.currentTime
                        subMsg
                        model.step
                        (RemoteData.map .categories model.pm)
            in
            ( { model
                | step = step
                , pm = RemoteData.map2 updateCategories cats model.pm
              }
            , Cmd.map CategoryMsg cmd
            )

        SubjectMsg subMsg ->
            let
                ( step, cats, cmd ) =
                    Subj.update
                        model.currentTime
                        subMsg
                        model.step
                        (RemoteData.map .categories model.pm)
            in
            ( { model
                | step = step
                , pm = RemoteData.map2 updateCategories cats model.pm
              }
            , Cmd.map SubjectMsg cmd
            )

        CsvMsg subMsg ->
            handleCsvMsg subMsg model

        ReceiveTime t ->
            ( { model | currentTime = t }, Cmd.none )


handleCsvMsg : CsvConvert.Msg -> Model -> ( Model, Cmd Msg )
handleCsvMsg subMsg model =
    case model.step of
        CsvConvert csv _ ->
            let
                ( raw, parsed, cmd ) =
                    CsvConvert.update subMsg model.currentTime csv
            in
            ( { model | step = CsvConvert raw (Just parsed) }, Cmd.map CsvMsg cmd )

        _ ->
            ( model, Cmd.none )


updateCategories : List Category -> PrayerMate -> PrayerMate
updateCategories cats pm =
    { pm | categories = cats }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ fileContentRead FileRead
        , Time.every Time.second (\t -> ReceiveTime t)
        ]


loadDemoData : Cmd Msg
loadDemoData =
    Http.get "test_data.json" decodePrayerMate
        |> RemoteData.sendRequest
        |> Cmd.map ReceivePrayerMate
