module View exposing (view)

import Categories.View as Cat
import CsvConvert
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Icons
import Json.Decode
import Markdown
import Messages exposing (Msg(..))
import Models exposing (CategoryStep(..), Model, SchedulerStep(..), Step(..))
import Prayermate exposing (PrayerMate, exportb64)
import RemoteData exposing (RemoteData(..), WebData)
import Scheduler
import Subjects.View as Subj
import Views as V


view : Model -> Html Msg
view model =
    Html.main_ [ A.class "min-w-screen min-h-screen bg-blue-lightest" ]
        [ navigation model
        , aboutScreen model.about model.showAbout
        , Html.section [ A.class "w-full h-full p-6" ] [ mainContent model ]
        ]


aboutScreen : WebData String -> Bool -> Html Msg
aboutScreen about show =
    if show then
        Html.div [ A.class "fixed z-50 pin overflow-auto bg-black flex" ]
            [ Html.div [ A.class "fixed shadow-inner max-w-md md:relative pin-b pin-x align-top m-auto justify-end md:justify-center p-8 bg-white md:rounded w-full md:h-auto md:shadow flex flex-col" ]
                [ aboutText about
                , Html.a [ E.onClick ToggleAbout, A.class "absolute pin-t pin-r pt-4 px-4 cursor-pointer" ] [ Icons.x ]
                ]
            ]
    else
        Html.text ""


aboutText : WebData String -> Html msg
aboutText about =
    case about of
        Success md ->
            Markdown.toHtml [ A.class "leading-normal font-sans" ] md

        _ ->
            Html.text "..."


navigation : Model -> Html Msg
navigation model =
    Html.ul [ A.class "list-reset flex items-center w-full p-3 bg-grey-dark" ]
        [ Html.li [ A.class "mr-6" ]
            [ Html.a [ A.class "text-white font-bold" ]
                [ Html.text "Unofficial PrayerMate Editor" ]
            ]
        , Html.li [ A.class "mr-6" ]
            [ V.button [ E.onClick ToggleAbout ]
                [ Html.text "About" ]
            ]
        , Html.li [ A.class "ml-auto mr-3" ] [ goToSchedulerButton model ]
        , Html.li [ A.class "mr-3" ] [ goToKanbanButton model ]
        , Html.li [ A.class "mr-6" ] [ exportButton model ]
        ]


exportButton : Model -> Html msg
exportButton model =
    case ( model.step, model.pm ) of
        ( CategoriesList (ViewCats _), Success pm ) ->
            exportButtonHelp pm

        ( CsvConvert _ (Just (Ok pm)), _ ) ->
            exportButtonHelp pm

        ( Scheduler MainView, Success pm ) ->
            exportButtonHelp pm

        ( _, _ ) ->
            Html.text ""


exportButtonHelp : PrayerMate -> Html msg
exportButtonHelp pm =
    Html.a
        [ A.href <| exportb64 pm
        , A.downloadAs "unofficial_prayemate_export.json"
        ]
        [ V.greenButton [] [ Html.text "Export" ] ]


goToSchedulerButton : Model -> Html Msg
goToSchedulerButton { step } =
    case step of
        CategoriesList (ViewCats _) ->
            V.blueButton [ E.onClick GoToScheduler ] [ Html.text "Scheduler" ]

        _ ->
            Html.text ""


goToKanbanButton : Model -> Html Msg
goToKanbanButton model =
    case model.step of
        CsvConvert _ (Just (Ok data)) ->
            case data.categories of
                [] ->
                    V.greyButton [] [ Html.text "Go To Editor" ]

                _ ->
                    Html.a
                        [ E.onClick CSVGoToKanban
                        ]
                        [ V.blueButton [] [ Html.text "Go To Editor " ] ]

        Scheduler MainView ->
            Html.a [ E.onClick CloseScheduler ] [ V.blueButton [] [ Html.text "Go To Editor " ] ]

        _ ->
            Html.text ""


mainContent : Model -> Html Msg
mainContent model =
    case model.step of
        LandingPage ->
            landingView model.cachedData

        CategoriesList catStep ->
            mapRemoteView (Cat.view catStep) model.pm

        SubjectsList cat subStep ->
            mapRemoteView (Subj.view cat subStep << .categories) model.pm

        CsvConvert csv parsed ->
            CsvConvert.view csv parsed

        Scheduler schedStep ->
            mapRemoteView (Scheduler.view schedStep) model.pm


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
    Html.div [ A.class "mx-auto w-1/2 my-8 p-4 bg-grey-dark" ]
        [ cachedSessionView cachedData
        , landingButton
            [ A.class "bg-blue" ]
            [ Html.p [] [ Html.text "Upload a .json file exported from PrayerMate" ]
            , Html.input
                [ A.type_ "file"
                , A.id "uploadPMFile"
                , E.on "change" (Json.Decode.succeed <| FileSelected "uploadPMFile")
                ]
                []
            ]
        , landingButton
            [ A.class "bg-blue hover:bg-blue-dark"
            , E.onClick LoadDropBoxData
            ]
            [ Html.text "Choose a .json file from Dropbox" ]
        , landingButton
            [ A.class "bg-blue hover:bg-blue-dark"
            , E.onClick LoadDemoData
            ]
            [ Html.text "Use Demo Data" ]
        ]


landingButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
landingButton attrs nodes =
    V.button ([ A.class "w-full py-4 my-2" ] ++ attrs) nodes


cachedSessionView : WebData PrayerMate -> Html Msg
cachedSessionView cachedData =
    case cachedData of
        Success _ ->
            landingButton
                [ A.class "bg-indigo hover:bg-indigo-darker"
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
