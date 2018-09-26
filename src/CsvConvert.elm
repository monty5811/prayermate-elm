module CsvConvert exposing (parseCsvData, view)

import Csv
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Json.Decode
import Messages exposing (Msg(..))
import Prayermate exposing (Card, Category, PrayerMate, Subject, newSubject)
import Time
import Util
import Views as V exposing (defaultGridOptions)


view : String -> Maybe PrayerMate -> Html Msg
view raw parsed =
    Html.div []
        [ Html.h2 [] [ Html.text "CSV Convertor" ]
        , Html.br [] []
        , Html.p [] [ Html.text "Paste some csv data, or upload a .csv file, there should be no header row and you should have three columns: 'category, subject, prayer content'" ]
        , Html.ul []
            [ Html.li [] [ Html.text "The last column is optional" ]
            , Html.li [] [ Html.text "If you want to paste data, open the file in a text editor (e.g. notepad) and copy from there as spreadsheet apps may give you tab-separated values instead - which won't work" ]
            ]
        , Html.br [] []
        , Html.input
            [ A.type_ "file"
            , A.id "uploadCsvFile"
            , E.on "change" (Json.Decode.succeed <| FileSelected "uploadCsvFile")
            ]
            []
        , V.gridWithOptions
            { defaultGridOptions | maxCols = 2 }
            []
            [ V.textArea
                20
                CSVInputChanged
                raw
            , parsedView parsed
            ]
        ]


parsedView : Maybe PrayerMate -> Html msg
parsedView parsed =
    case parsed of
        Nothing ->
            Html.text ""

        Just pm ->
            pmTree pm



--Err errs ->
--    Html.div [ A.class "overflow-y-scroll" ] (List.map (\e -> Html.p [] [ Html.text e ]) errs)


pmTree : PrayerMate -> Html msg
pmTree pm =
    Html.ul [ A.class "overflow-y-scroll" ] (List.map catView pm.categories)


catView : Category -> Html msg
catView cat =
    Html.li []
        [ Html.text cat.name
        , Html.ul [] (List.map subView cat.subjects)
        ]


subView : Subject -> Html msg
subView sub =
    Html.li [] [ Html.text sub.name, Html.ul [] (List.map cardView sub.cards) ]


cardView : Card -> Html msg
cardView card =
    case card.text of
        Nothing ->
            Html.text ""

        Just content ->
            if content == "" then
                Html.text ""
            else
                Html.li [] [ Html.text content ]


parseCsvData : Time.Posix -> String -> PrayerMate
parseCsvData currentTime csv =
    csv
        |> Csv.parse
        |> buildPM currentTime


buildPM : Time.Posix -> Csv.Csv -> PrayerMate
buildPM currentTime csv =
    { categories = csv2Categories currentTime csv
    , feeds = []
    , prayerMateAndroidVersion = Nothing
    , prayerMateVersion = Nothing
    }


csv2Categories : Time.Posix -> Csv.Csv -> List Category
csv2Categories currentTime csv =
    List.foldl (addSubject currentTime) [] (csv.headers :: csv.records)


addSubject : Time.Posix -> List String -> List Category -> List Category
addSubject currentTime raw cats =
    case raw of
        [ cat, sub, content ] ->
            -- good match
            addNew currentTime cats cat sub content

        cat :: sub :: content :: _ ->
            -- ignore extra columns at end
            addNew currentTime cats cat sub content

        [ cat, sub ] ->
            -- no content, just use blank
            addNew currentTime cats cat sub ""

        _ ->
            -- Invalid, ignore by returning categories as are
            cats


addNew : Time.Posix -> List Category -> String -> String -> String -> List Category
addNew currentTime cats catName subName content =
    if List.member catName (List.map .name cats) then
        -- category exists, add subject
        List.map (updateCatWithSubject currentTime catName subName content) cats
    else
        -- category does not exist, create it and append to list
        cats ++ [ createNewCatWithSubject currentTime catName subName content ]


updateCatWithSubject : Time.Posix -> String -> String -> String -> Category -> Category
updateCatWithSubject currentTime catName subName content cat =
    if cat.name == catName then
        { cat | subjects = cat.subjects ++ [ newSubject currentTime subName (Just content) ] }
    else
        cat


createNewCatWithSubject : Time.Posix -> String -> String -> String -> Category
createNewCatWithSubject currentTime catName subName content =
    { name = catName
    , createdDate = Util.formatDateTime currentTime
    , itemsPerSession = 1
    , visible = True
    , pinned = False
    , manualSessionLimit = Nothing
    , syncID = Nothing
    , subjects =
        [ newSubject currentTime subName (Just content) ]
    }
