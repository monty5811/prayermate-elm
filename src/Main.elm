module Main exposing (main)

import Categories.Update as Cat
import Html exposing (Html)
import Http
import Messages exposing (Msg(..))
import Models exposing (..)
import Ports exposing (fileContentRead, fileSelected)
import PrayermateModels exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Subjects.Update as Subj
import Time
import Util
import View exposing (view)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = \f -> ( initialModel f, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


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

        FileRead { contents, filename } ->
            let
                pm =
                    Util.decodePrayerMate2WebData contents
            in
            ( { model
                | pm = pm
                , originalPm = pm
                , step = initialCategoriesStep
              }
            , Cmd.none
            )

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

        ReceiveTime t ->
            ( { model | currentTime = t }, Cmd.none )


updateCategories : List Category -> PrayerMate -> PrayerMate
updateCategories cats pm =
    { pm | categories = cats }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ fileContentRead FileRead
        , Time.every Time.second (\t -> ReceiveTime t)
        ]


loadDemoData : Cmd Msg
loadDemoData =
    Http.get "test_data.json" decodePrayerMate
        |> RemoteData.sendRequest
        |> Cmd.map ReceivePrayerMate
