module Scheduler exposing (view)

import Date exposing (Date)
import DateFormat
import DatePicker
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Icons
import Markdown
import Messages exposing (Msg(..))
import Models exposing (SchedulerStep(..))
import Prayermate exposing (..)
import Time
import Views as V exposing (GridOptions, defaultGridOptions, gridWithOptions)


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
    , auto : List CardDetails
    , everyDayByPriorityLevel : List CardDetails
    , byDayOfMonth : List CardDetails
    , byDate : List CardDetails
    }


emptyColumns : Columns
emptyColumns =
    Columns [] [] [] [] [] [] [] [] [] [] []


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


view : SchedulerStep -> PrayerMate -> Html Msg
view step pm =
    case step of
        MainView ->
            let
                cols =
                    getColumns pm
            in
            Html.div []
                [ Markdown.toHtml [ A.class "mx-8 leading-normal font-sans" ] helpMd
                , gridWithOptions gridOptions [ A.class "py-4 max-w-lg" ] (otherSchedCols cols)
                , Html.h3 [] [ Html.text "Day of the Week" ]
                , gridWithOptions gridOptions [ A.class "py-4 overflow-x-scroll" ] (dayOfWeekCols cols)
                ]

        DatePickerView datepicker cd selectedDates ->
            datePickerView datepicker cd selectedDates

        DayOfMonthPickerView cd selectedDays ->
            dayOfMonthPickerView cd selectedDays


helpMd : String
helpMd =
    """
## Help

There are four scheduling modes that a subject can have. Each subject can only be in a single mode.

* Default - managed completely by PrayerMate
* Day of The Week
* Day of the Month
* Specific Dates

How to use this tool:

* Click on the calendar to choose specific dates
* Click on the numbers to choose days of the month
* Click on each weekday to toggle that day - the subject will show up in each column that is selected
* If you want to move a subject back into "Default", simply remove all other scheduling, e.g. remove all the selected weekdays or all the selected dates
    """


defaultDPSettings : DatePicker.Settings
defaultDPSettings =
    DatePicker.defaultSettings


datePickerView : DatePicker.DatePicker -> CardDetails -> List Date -> Html Msg
datePickerView datepicker ( cat, subject, card ) selectedDates =
    Html.div
        [ A.class "fixed shadow-inner max-w-md md:relative pin-x align-top m-auto justify-end md:justify-center p-8 bg-white md:rounded w-full md:h-auto md:shadow flex flex-col" ]
        [ Html.h2 [ A.class "mb-2" ] [ Html.text subject.name ]
        , Html.p [ A.class "mb-2" ] [ Html.text "Edit Dates:" ]
        , Html.div [ A.class "flex" ]
            [ Html.div [ A.class "flex-1" ]
                [ DatePicker.view
                    Nothing
                    { defaultDPSettings | placeholder = "Add new date" }
                    datepicker
                    |> Html.map SetDatePicker
                ]
            , Html.div [ A.class "flex-1" ] [ Html.ul [ A.class "list-reset" ] <| List.map datePickerDateItem selectedDates ]
            ]
        , Html.div [ A.class "my-4" ]
            [ V.greenButton [ A.class "w-1/2", E.onClick <| SchedSaveDateChange "dates go here" ] [ Html.text "Save" ]
            , V.greyButton [ A.class "w-1/2", E.onClick SchedCancelDatePickerView ] [ Html.text "Cancel" ]
            ]
        ]


datePickerDateItem : Date -> Html Msg
datePickerDateItem date =
    Html.li [ E.onClick <| SchedDatePickerDeleteDate date, A.class "p-2 mb-2 cursor-point bg-grey-light" ] [ Html.span [ A.class "float-right text-red cursor-pointer" ] [ Icons.x ], Html.text <| formatDate date ]


formatDate : Date -> String
formatDate date =
    Date.toIsoString date


dayOfMonthPickerView : CardDetails -> List Int -> Html Msg
dayOfMonthPickerView ( cat, subject, card ) selectedDays =
    Html.div
        [ A.class "fixed shadow-inner max-w-md md:relative pin-x align-top m-auto justify-end md:justify-center p-8 bg-white md:rounded w-full md:h-auto md:shadow flex flex-col" ]
        [ Html.h2 [ A.class "mb-2" ] [ Html.text subject.name ]
        , Html.p [ A.class "mb-1" ] [ Html.text "Pick Days Of The Month:" ]
        , gridWithOptions { defaultGridOptions | maxCols = 7, gridGap = 3, minHeight = 20 } [ A.class "my-4" ] <| List.map (dayOfMonthDay selectedDays) (List.range 1 31)
        , V.greenButton [ A.class "my-1", E.onClick <| SchedSaveDoMChange ] [ Html.text "Save" ]
        , V.greyButton [ A.class "my-1", E.onClick SchedCancelDoMPickerView ] [ Html.text "Cancel" ]
        ]


dayOfMonthDay : List Int -> Int -> Html Msg
dayOfMonthDay selectedDays currentDay =
    Html.div
        [ A.class "text-center cursor-pointer"
        , A.class <|
            if List.member currentDay selectedDays then
                "bg-green-light"
            else
                "bg-grey"
        , E.onClick <| SchedDoMToggleDay currentDay
        ]
        [ Html.text <| String.fromInt currentDay ]


dayOfWeekCols : Columns -> List (Html Msg)
dayOfWeekCols cols =
    [ colView "Sunday" cols.sun
    , colView "Monday" cols.mon
    , colView "Tuesday" cols.tues
    , colView "Wednesday" cols.wed
    , colView "Thursday" cols.thurs
    , colView "Friday" cols.fri
    , colView "Saturday" cols.sat
    ]


otherSchedCols : Columns -> List (Html Msg)
otherSchedCols cols =
    [ colView "Default (auto scheduled)" cols.auto
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
            weekDaySelHelp cd []

        DayOfMonth _ ->
            weekDaySelHelp cd []


weekDaySelHelp : CardDetails -> DayOfWeekMask -> Html Msg
weekDaySelHelp (( cat, sub, card ) as cd) selectedDays =
    Html.div [ A.class "my-1 py-1 bg-grey-dark" ]
        [ Html.div
            [ A.class "inline-flex" ]
            (List.map (weekDaySelDay cd selectedDays) daysOfWeek
                ++ [ Html.div [ A.class "flex-1 mx-1" ] [ Html.text "|" ]
                   , dateSel cd
                   , dayOfMonthSel cd
                   ]
            )
        , if sub.priorityLevel == 10000 then
            Html.div [ A.class "flex-10 mx-2 text-sm text-white" ] [ Html.text "Priority Level: Every Day" ]
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


dateSel : CardDetails -> Html Msg
dateSel (( cat, subject, card ) as cd) =
    Html.div
        [ E.onClick (SchedOpenDatePickerView cd)
        , A.class "flex-1 cursor-pointer mx-1"
        ]
        [ Icons.calendar ]


dayOfMonthSel : CardDetails -> Html Msg
dayOfMonthSel (( cat, subject, card ) as cd) =
    Html.div
        [ E.onClick (SchedOpenDoMPickerView cd)
        , A.class "flex-1 cursor-pointer mx-1"
        ]
        [ Icons.nums ]


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
