module Scheduler exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(..))
import Prayermate exposing (..)
import Views exposing (GridOptions, defaultGridOptions, gridWithOptions)


gridOptions : GridOptions
gridOptions =
    { defaultGridOptions | maxCols = 7, minHeight = 500 }


type alias CardDetails =
    ( Category, Subject, Card )


type alias Columns =
    { sun : List CardDetails
    , mon : List CardDetails
    , tues : List CardDetails
    , wed : List CardDetails
    , thurs : List CardDetails
    , fri : List CardDetails
    , sat : List CardDetails
    , sun : List CardDetails
    , auto : List CardDetails
    , everyDayByPriorityLevel : List CardDetails
    , byDayOfMonth : List CardDetails
    , byDate : List CardDetails
    }


emptyColumns : Columns
emptyColumns =
    Columns [] [] [] [] [] [] [] [] [] [] [] []


getColumns : PrayerMate -> Columns
getColumns pm =
    List.foldl extractFromCat emptyColumns pm.categories


extractFromCat : Category -> Columns -> Columns
extractFromCat cat cols =
    List.foldl (extractFromSub cat) cols cat.subjects


extractFromSub : Category -> Subject -> Columns -> Columns
extractFromSub cat subject cols =
    case List.head subject.cards of
        Nothing ->
            cols

        Just card ->
            updateColsWithCard cat subject card cols


{-|

    Additionally, if a `subject` has a `priorityLevel` of `10000`, it is scheduled every day

-}
updateColsWithCard : Category -> Subject -> Card -> Columns -> Columns
updateColsWithCard cat subject card cols =
    case subject.priorityLevel of
        10000 ->
            List.foldl (extractFromWeekMask cat subject card) cols daysOfWeek

        _ ->
            case card.schedulingMode of
                Default ->
                    { cols | auto = ( cat, subject, card ) :: cols.auto }

                DayOfWeek selectedDays ->
                    List.foldl (extractFromWeekMask cat subject card) cols selectedDays

                Date _ ->
                    { cols | byDate = ( cat, subject, card ) :: cols.byDate }

                DayOfMonth _ ->
                    { cols | byDayOfMonth = ( cat, subject, card ) :: cols.byDayOfMonth }


extractFromWeekMask : Category -> Subject -> Card -> WeekDay -> Columns -> Columns
extractFromWeekMask cat subject card weekday cols =
    let
        cd =
            ( cat, subject, card )
    in
    case weekday of
        Sunday ->
            { cols | sun = cd :: cols.sun }

        Monday ->
            { cols | mon = cd :: cols.mon }

        Tuesday ->
            { cols | tues = cd :: cols.tues }

        Wednesday ->
            { cols | wed = cd :: cols.wed }

        Thursday ->
            { cols | thurs = cd :: cols.thurs }

        Friday ->
            { cols | fri = cd :: cols.fri }

        Saturday ->
            { cols | sat = cd :: cols.sat }


view : PrayerMate -> Html Msg
view pm =
    let
        columnData =
            getColumns pm
    in
    gridWithOptions gridOptions [ A.class "py-4" ] (gridCols columnData)


gridCols : Columns -> List (Html Msg)
gridCols cols =
    [ colView "Sunday" cols.sun
    , colView "Monday" cols.mon
    , colView "Tuesday" cols.tues
    , colView "Wednesday" cols.wed
    , colView "Thursday" cols.thurs
    , colView "Friday" cols.fri
    , colView "Saturday" cols.sat
    , colView "Default (auto scheduled)" cols.auto
    , colView "By Date" cols.byDate
    , colView "By Day of the Month" cols.byDayOfMonth
    ]


colView : String -> List CardDetails -> Html Msg
colView title cds =
    Html.div [ A.class "bg-grey px-2" ]
        [ Html.h3 [ A.class "py-2" ] [ Html.text title ]
        , Html.ul [ A.class "list-reset" ] (List.map cardView cds)
        ]


cardView : CardDetails -> Html Msg
cardView (( cat, subject, card ) as cd) =
    Html.li [ A.class "p-2 mb-2 bg-grey-light" ]
        [ Html.div [] [ Html.text subject.name ]
        , weekDaySel cd
        ]


weekDaySel : CardDetails -> Html Msg
weekDaySel (( cat, sub, card ) as cd) =
    case card.schedulingMode of
        Default ->
            weekDaySelHelp cd []

        DayOfWeek days ->
            weekDaySelHelp cd days

        Date _ ->
            Html.text ""

        DayOfMonth _ ->
            Html.text ""


weekDaySelHelp : CardDetails -> DayOfWeekMask -> Html Msg
weekDaySelHelp (( cat, sub, card ) as cd) selectedDays =
    Html.div [ A.class "my-1 py-1 bg-grey-dark" ]
        [ Html.div [ A.class "inline-flex" ] (List.map (weekDaySelDay cd selectedDays) daysOfWeek)
        , if sub.priorityLevel == 10000 then
            Html.div [ A.class "flex-7 mx-2 text-sm text-white" ] [ Html.text "Priority Level: Every Day" ]
          else
            Html.text ""
        ]


weekDaySelDay : CardDetails -> DayOfWeekMask -> WeekDay -> Html Msg
weekDaySelDay ( cat, subject, card ) selectedDays weekday =
    Html.div
        [ E.onClick (ToggleWeekday weekday cat subject card)
        , A.class <| weekDayColour weekday selectedDays
        , A.class "flex-1 cursor-pointer mx-1"
        ]
        [ Html.text <| weekDayAbbr weekday ]


weekDayAbbr : WeekDay -> String
weekDayAbbr weekday =
    case weekday of
        Sunday ->
            "Su"

        Monday ->
            "M"

        Tuesday ->
            "Tu"

        Wednesday ->
            "W"

        Thursday ->
            "Th"

        Friday ->
            "F"

        Saturday ->
            "Sa"


weekDayColour : WeekDay -> DayOfWeekMask -> String
weekDayColour wd mask =
    if List.member wd mask then
        "text-green-light"
    else
        "text-black"
