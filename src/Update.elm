module Update exposing (update)

import Browser.Navigation as Navigation
import CsvConvert exposing (parseCsvData)
import Date
import DateFormat
import DatePicker
import DragDrop exposing (Res(..))
import Editing exposing (Editing(..))
import Http
import Json.Decode
import Messages exposing (Msg(..))
import Models exposing (..)
import Ports exposing (fileSelected, openDropboxChooser)
import Prayermate exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Time
import Util


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleAbout ->
            ( { model | showAbout = not model.showAbout }, Cmd.none )

        ReceiveAbout about ->
            ( { model | about = about }
            , Cmd.none
            )

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

        LoadDropBoxData ->
            ( model, openDropboxChooser () )

        ReceivePrayerMate pm ->
            ( { model | pm = pm, originalPm = pm }
            , Cmd.none
            )

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
                    case model.step of
                        CsvConvert _ _ ->
                            ( { model | step = CsvConvert contents (Just <| parseCsvData model.currentTime contents) }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReceiveDropboxLink value ->
            case Json.Decode.decodeValue Json.Decode.string value of
                Err _ ->
                    ( model, Cmd.none )

                Ok url ->
                    ( { model | step = initialCategoriesStep }, fetchDropboxData url )

        CSVInputChanged newCsv ->
            case model.step of
                CsvConvert _ _ ->
                    ( { model | step = CsvConvert newCsv (Just <| parseCsvData model.currentTime newCsv) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        CSVFileSelected id ->
            case model.step of
                CsvConvert csv _ ->
                    ( { model | step = CsvConvert csv (Just <| parseCsvData model.currentTime csv) }, fileSelected id )

                _ ->
                    ( model, Cmd.none )

        CSVGoToKanban ->
            case model.step of
                CsvConvert _ parsedData ->
                    case parsedData of
                        Just pm ->
                            ( { model
                                | step = initialCategoriesStep
                                , pm = Success pm
                                , originalPm = Success pm
                              }
                            , Navigation.replaceUrl model.navKey "/"
                            )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GoToScheduler ->
            case model.step of
                CategoriesList (ViewCats _) ->
                    ( { model | step = Scheduler MainView }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CloseScheduler ->
            case model.step of
                Scheduler MainView ->
                    ( { model | step = initialCategoriesStep }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReceiveTime t ->
            ( { model | currentTime = t }
            , Cmd.none
            )

        CatOpen cat ->
            ( { model | step = SubjectsList (Editing cat cat) ViewSubjects }
            , Cmd.none
            )

        CatEditStart cat ->
            ( { model | step = CategoriesList <| EditCat (Editing cat cat) }, Util.focusInput NoOp )

        CatEditUpdateName updatingName ->
            case model.step of
                CategoriesList (EditCat editing) ->
                    ( { model
                        | step =
                            editing
                                |> Editing.map (updateName updatingName)
                                |> EditCat
                                |> CategoriesList
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        CatEditSave ->
            case model.step of
                CategoriesList (EditCat NoSelected) ->
                    ( model, Cmd.none )

                CategoriesList (EditCat (Editing origCat modCat)) ->
                    ( { model
                        | step = initialCategoriesStep
                        , pm = RemoteData.map (replaceCategory origCat modCat) model.pm
                      }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatEditCancel ->
            ( { model | step = initialCategoriesStep }
            , Cmd.none
            )

        CatDeleteStart cat ->
            case model.step of
                CategoriesList _ ->
                    ( { model | step = CategoriesList (DeleteCat cat) }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatDeleteCancel ->
            case model.step of
                CategoriesList (DeleteCat _) ->
                    ( { model | step = initialCategoriesStep }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatDeleteConfirm ->
            case model.step of
                CategoriesList (DeleteCat cat2Delete) ->
                    ( { model
                        | step = initialCategoriesStep
                        , pm = RemoteData.map (deleteCategory cat2Delete) model.pm
                      }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatCreateStart ->
            case model.step of
                CategoriesList _ ->
                    ( { model | step = CategoriesList (CreateCat "") }, Util.focusInput NoOp )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatCreateCancel ->
            case model.step of
                CategoriesList (CreateCat _) ->
                    ( { model | step = initialCategoriesStep }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatCreateSave ->
            case model.step of
                CategoriesList (CreateCat name) ->
                    ( { model
                        | step = initialCategoriesStep
                        , pm = RemoteData.map (addNewCategory model.currentTime name) model.pm
                      }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatCreateUpdateName text ->
            case model.step of
                CategoriesList (CreateCat _) ->
                    ( { model | step = CategoriesList (CreateCat text) }
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        CatEditSubjectStart cat sub ->
            ( { model | step = CategoriesList <| EditSubject DragDrop.init cat (Editing sub sub) }, Cmd.none )

        CatEditSubjectCancel ->
            case model.step of
                CategoriesList (EditSubject _ _ _) ->
                    ( { model | step = initialCategoriesStep }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CatEditSubjectSave ->
            case model.step of
                CategoriesList (EditSubject _ cat (Editing origSub modifSub)) ->
                    let
                        newCat =
                            { cat | subjects = Util.replaceItem origSub modifSub cat.subjects }
                    in
                    ( { model
                        | step = initialCategoriesStep
                        , pm = RemoteData.map2 updateCategories (RemoteData.map (.categories >> Util.replaceItem cat newCat) model.pm) model.pm
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        CatEditSubjectUpdateName text ->
            case model.step of
                CategoriesList (EditSubject dnd cat eSub) ->
                    ( { model | step = CategoriesList <| EditSubject dnd cat (Editing.map (updateName text) eSub) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CatEditUpdateCardText newText ->
            case model.step of
                CategoriesList (EditSubject dnd cat eSub) ->
                    ( { model
                        | step =
                            CategoriesList <|
                                EditSubject dnd cat (Editing.map (updateSubjectCardText newText) eSub)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DnD msg_ ->
            case model.step of
                CategoriesList (ViewCats oldDndModel) ->
                    let
                        ( dndModel, result ) =
                            DragDrop.update msg_ oldDndModel
                    in
                    case result of
                        Dragging _ _ _ ->
                            ( { model | step = CategoriesList (ViewCats dndModel) }
                            , Cmd.none
                            )

                        Dropped startCat endTarget subject ->
                            let
                                cats =
                                    RemoteData.map (.categories >> dropSubject subject startCat endTarget) model.pm
                            in
                            ( { model
                                | step = CategoriesList (ViewCats dndModel)
                                , pm = RemoteData.map2 updateCategories cats model.pm
                              }
                            , Cmd.none
                            )

                        DraggingCancelled ->
                            ( { model | step = CategoriesList (ViewCats dndModel) }
                            , Cmd.none
                            )

                _ ->
                    -- skip every other step
                    ( model, Cmd.none )

        SubEditStart sub ->
            case model.step of
                SubjectsList category ViewSubjects ->
                    ( { model | step = SubjectsList category <| EditSubjectName (Editing sub sub) }, Util.focusInput NoOp )

                _ ->
                    ( model, Cmd.none )

        SubEditUpdateName newName ->
            case model.step of
                SubjectsList cat (EditSubjectName editingSubject) ->
                    ( { model
                        | step =
                            SubjectsList cat <|
                                EditSubjectName <|
                                    Editing.map (updateName newName) editingSubject
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubEditSave ->
            case model.step of
                SubjectsList cat (EditSubjectName (Editing original modified)) ->
                    ( { model | step = SubjectsList (Editing.map (replaceSubject original modified) cat) ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubEditCancel ->
            case model.step of
                SubjectsList cat _ ->
                    ( { model | step = SubjectsList cat ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubDeleteStart sub ->
            case model.step of
                SubjectsList cat ViewSubjects ->
                    ( { model | step = SubjectsList cat <| DeleteSubject sub }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubDeleteCancel ->
            case model.step of
                SubjectsList cat (DeleteSubject _) ->
                    ( { model | step = SubjectsList cat <| ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubDeleteConfirm ->
            case model.step of
                SubjectsList cat (DeleteSubject sub2delete) ->
                    ( { model | step = SubjectsList (Editing.map (deleteSubject sub2delete) cat) <| ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        CloseList ->
            case model.step of
                SubjectsList (Editing origCat modifiedCat) _ ->
                    ( { model
                        | step = initialCategoriesStep
                        , pm = RemoteData.map2 updateCategories (RemoteData.map (.categories >> Util.replaceItem origCat modifiedCat) model.pm) model.pm
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubCreateStart ->
            case model.step of
                SubjectsList cat ViewSubjects ->
                    ( { model | step = SubjectsList cat (CreateSubject "") }, Util.focusInput NoOp )

                _ ->
                    ( model, Cmd.none )

        SubCreateCancel ->
            case model.step of
                SubjectsList cat (CreateSubject _) ->
                    ( { model | step = SubjectsList cat ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubCreateSave ->
            case model.step of
                SubjectsList cat (CreateSubject name) ->
                    ( { model | step = SubjectsList (Editing.map (addNewSubject model.currentTime name) cat) ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubCreateUpdateName text ->
            case model.step of
                SubjectsList cat (CreateSubject _) ->
                    ( { model | step = SubjectsList cat (CreateSubject text) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubMoveStart sub ->
            case model.step of
                SubjectsList cat ViewSubjects ->
                    ( { model | step = SubjectsList cat <| MoveSubject sub }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubMoveCancel ->
            case model.step of
                SubjectsList cat (MoveSubject _) ->
                    ( { model | step = SubjectsList cat <| ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubMoveComplete newCat ->
            case model.step of
                SubjectsList (Editing originalCat modifiedCat) (MoveSubject sub2Move) ->
                    -- remove subject from current category in the step and in the list
                    -- and add subject to new category in the list
                    if newCat == originalCat then
                        ( { model | step = SubjectsList (Editing originalCat modifiedCat) ViewSubjects }
                        , Cmd.none
                        )
                    else
                        let
                            newCurrentCat =
                                deleteSubject sub2Move modifiedCat

                            newCats =
                                model.pm
                                    |> RemoteData.map .categories
                                    |> RemoteData.map (List.map (maybeAddSubjectToEnd sub2Move newCat))
                                    |> RemoteData.map (Util.replaceItem originalCat newCurrentCat)
                        in
                        ( { model
                            | step =
                                SubjectsList
                                    (Editing newCurrentCat newCurrentCat)
                                    ViewSubjects
                            , pm = RemoteData.map2 updateCategories newCats model.pm
                          }
                        , Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        EditCardStart sub card ->
            case model.step of
                SubjectsList cat ViewSubjects ->
                    ( { model
                        | step =
                            SubjectsList cat
                                (EditSubjectCard (Editing sub sub) (Editing card card))
                      }
                    , Util.focusInput NoOp
                    )

                _ ->
                    ( model, Cmd.none )

        EditCardUpdateText text ->
            case model.step of
                SubjectsList cat (EditSubjectCard editingSubject editingCard) ->
                    ( { model
                        | step =
                            SubjectsList cat
                                (EditSubjectCard editingSubject (Editing.map (updateText text) editingCard))
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        EditCardSave ->
            case model.step of
                SubjectsList cat (EditSubjectCard (Editing origSub _) (Editing origCard modifCard)) ->
                    let
                        newSub =
                            { origSub | cards = Util.replaceItem origCard modifCard origSub.cards }

                        newCat =
                            Editing.map (replaceSubject origSub newSub) cat
                    in
                    ( { model | step = SubjectsList newCat ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        EditCardCancel ->
            case model.step of
                SubjectsList cat (EditSubjectCard _ _) ->
                    ( { model | step = SubjectsList cat ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        CreateEmptyCard sub ->
            case model.step of
                SubjectsList cat ViewSubjects ->
                    ( { model | step = SubjectsList (Editing.map (addEmptyCard model.currentTime sub) cat) ViewSubjects }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ToggleWeekday weekday cat subject card ->
            case card.schedulingMode of
                Default ->
                    toggleWeekday [] weekday cat subject card model

                DayOfWeek selectedDays ->
                    toggleWeekday selectedDays weekday cat subject card model

                Date _ ->
                    toggleWeekday [] weekday cat subject card model

                DayOfMonth _ ->
                    toggleWeekday [] weekday cat subject card model

        SchedOpenDatePickerView (( cat, sub, card ) as cd) ->
            case model.step of
                Scheduler MainView ->
                    let
                        ( datePicker, datePickerCmd ) =
                            DatePicker.init
                    in
                    ( { model | step = Scheduler <| DatePickerView datePicker cd <| getSelectedDates card }
                    , Cmd.map SetDatePicker datePickerCmd
                    )

                _ ->
                    ( model, Cmd.none )

        SchedCancelDatePickerView ->
            case model.step of
                Scheduler (DatePickerView _ _ _) ->
                    ( { model | step = Scheduler MainView }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SchedSaveDateChange dates ->
            case model.step of
                Scheduler (DatePickerView _ cd selectedDates) ->
                    { model | step = Scheduler MainView } |> saveDateChange selectedDates cd

                _ ->
                    ( model, Cmd.none )

        SchedOpenDoMPickerView (( cat, sub, card ) as cd) ->
            case model.step of
                Scheduler MainView ->
                    ( { model | step = Scheduler <| DayOfMonthPickerView cd <| getSelectedDaysOfMonth card }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SchedCancelDoMPickerView ->
            case model.step of
                Scheduler (DayOfMonthPickerView _ _) ->
                    ( { model | step = Scheduler MainView }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SchedDoMToggleDay day ->
            case model.step of
                Scheduler (DayOfMonthPickerView cd selectedDays) ->
                    ( { model | step = Scheduler <| DayOfMonthPickerView cd <| toggleDay day selectedDays }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SchedSaveDoMChange ->
            case model.step of
                Scheduler (DayOfMonthPickerView cd selectedDays) ->
                    saveDoMChange selectedDays cd model

                _ ->
                    ( model, Cmd.none )

        SetDatePicker subMsg ->
            case model.step of
                Scheduler (DatePickerView datepicker cd selectedDays) ->
                    let
                        ( newDatePicker, datePickerCmd, dateEvent ) =
                            DatePicker.update DatePicker.defaultSettings subMsg datepicker

                        step =
                            Scheduler << DatePickerView newDatePicker cd
                    in
                    case dateEvent of
                        DatePicker.FailedInput _ ->
                            ( { model | step = step selectedDays }, Cmd.map SetDatePicker datePickerCmd )

                        DatePicker.None ->
                            ( { model | step = step selectedDays }, Cmd.map SetDatePicker datePickerCmd )

                        DatePicker.Picked newDate ->
                            if List.member newDate selectedDays then
                                ( { model | step = step selectedDays }, Cmd.map SetDatePicker datePickerCmd )
                            else
                                ( { model | step = step <| newDate :: selectedDays }, Cmd.map SetDatePicker datePickerCmd )

                _ ->
                    ( model, Cmd.none )

        SchedDatePickerDeleteDate date ->
            case model.step of
                Scheduler (DatePickerView datepicker cd selectedDays) ->
                    ( { model | step = Scheduler <| DatePickerView datepicker cd <| List.filter (\d -> d /= date) selectedDays }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


updateSubjectCardText : String -> Subject -> Subject
updateSubjectCardText newText subject =
    case subject.cards of
        [ card ] ->
            let
                newCard =
                    { card | text = Just newText }
            in
            { subject | cards = [ newCard ] }

        card :: rest ->
            let
                newCard =
                    { card | text = Just newText }
            in
            { subject | cards = newCard :: rest }

        _ ->
            subject


toggleDay : Int -> List Int -> List Int
toggleDay day selectedDays =
    if List.member day selectedDays then
        List.filter (\d -> d /= day) selectedDays
    else
        List.sort <| day :: selectedDays


saveDateChange : List Date.Date -> ( Category, Subject, Card ) -> Model -> ( Model, Cmd Msg )
saveDateChange selectedDates ( cat, subject, card ) model =
    let
        isPLEveryDay =
            subject.priorityLevel == 10000

        anyDatesChosen =
            List.length selectedDates > 0

        newCard =
            if anyDatesChosen then
                { card | schedulingMode = Date <| String.join "," <| List.map pmDateFmt selectedDates }
            else
                { card | schedulingMode = Default }

        newSubject =
            if isPLEveryDay then
                case newCard.schedulingMode of
                    Date _ ->
                        -- priorityLevel may need to be downgraded
                        { subject | cards = [ newCard ], priorityLevel = 0 }

                    _ ->
                        { subject | cards = [ newCard ] }
            else
                -- we can just update the card and leave the priorityLevel as is
                { subject | cards = [ newCard ] }

        newCat =
            replaceSubject
                subject
                newSubject
                cat

        newPm =
            RemoteData.map (replaceCategory cat newCat) model.pm
    in
    ( { model | pm = newPm }, Cmd.none )


{-|

    Convert to format: 2018-04-26T00:00

-}
pmDateFmt : Date.Date -> String
pmDateFmt date =
    Date.toIsoString date ++ "T00:00"


saveDoMChange : List Int -> ( Category, Subject, Card ) -> Model -> ( Model, Cmd Msg )
saveDoMChange selectedDays ( cat, subject, card ) model =
    let
        isPLEveryDay =
            subject.priorityLevel == 10000

        anyDaysChosen =
            List.length selectedDays > 0

        newCard =
            if anyDaysChosen then
                { card | schedulingMode = DayOfMonth selectedDays }
            else
                { card | schedulingMode = Default }

        newSubject =
            if isPLEveryDay then
                case newCard.schedulingMode of
                    DayOfMonth _ ->
                        -- priorityLevel may need to be downgraded
                        { subject | cards = [ newCard ], priorityLevel = 0 }

                    _ ->
                        { subject | cards = [ newCard ] }
            else
                -- we can just update the card and leave the priorityLevel as is
                { subject | cards = [ newCard ] }

        newCat =
            replaceSubject
                subject
                newSubject
                cat

        newPm =
            RemoteData.map (replaceCategory cat newCat) model.pm
    in
    ( { model | pm = newPm, step = Scheduler MainView }, Cmd.none )


toggleWeekday : DayOfWeekMask -> WeekDay -> Category -> Subject -> Card -> Model -> ( Model, Cmd Msg )
toggleWeekday selectedDays weekday cat subject card model =
    let
        isPLEveryDay =
            subject.priorityLevel == 10000

        isDayInMask =
            List.member weekday selectedDays

        newCard =
            (case ( isPLEveryDay, isDayInMask ) of
                ( True, _ ) ->
                    { card | schedulingMode = DayOfWeek [ weekday ] }

                ( False, True ) ->
                    { card | schedulingMode = DayOfWeek <| removeDay weekday selectedDays }

                ( False, False ) ->
                    { card | schedulingMode = DayOfWeek <| addDay weekday selectedDays }
            )
                |> checkIfNoDaysTicked

        newSubject =
            case isPLEveryDay of
                True ->
                    case newCard.schedulingMode of
                        DayOfWeek selectedDays_ ->
                            -- priorityLevel may need to be downgraded
                            if List.length selectedDays_ < 7 then
                                { subject | cards = [ newCard ], priorityLevel = 0 }
                            else
                                { subject | cards = [ newCard ] }

                        _ ->
                            { subject | cards = [ newCard ] }

                False ->
                    -- we can just update the card and leave the priorityLevel as is
                    { subject | cards = [ newCard ] }

        newCat =
            replaceSubject
                subject
                (newSubject |> checkIfAllDaysTicked newCard)
                cat

        newPm =
            RemoteData.map (replaceCategory cat newCat) model.pm
    in
    ( { model | pm = newPm }, Cmd.none )


dropSubject : Subject -> Category -> DragDrop.Target Category Subject -> List Category -> List Category
dropSubject sub startCat destTarget catList =
    case destTarget of
        DragDrop.Zone destCat ->
            if startCat == destCat then
                -- short circuit if start and end are the same
                catList
            else
                let
                    updatedStartCat =
                        deleteSubject sub startCat
                in
                catList
                    |> List.map (maybeAddSubjectToEnd sub destCat)
                    |> Util.replaceItem startCat updatedStartCat

        DragDrop.Item destCat destSub ->
            case ( destCat == startCat, destSub == sub ) of
                ( True, True ) ->
                    -- short circuit if start and end are the same
                    catList

                ( False, True ) ->
                    -- identical subjects on different lists, don't do anything
                    catList

                ( True, False ) ->
                    -- moving within a list
                    -- we need to delete the item from the current category and add it back in the correct place
                    let
                        startCatWithoutSub =
                            deleteSubject sub startCat

                        updatedStartCat =
                            maybeAddSubjectAfterExistingSub destSub sub startCatWithoutSub startCatWithoutSub
                    in
                    catList
                        |> Util.replaceItem startCat updatedStartCat

                ( False, False ) ->
                    -- moving between lists
                    -- we need to delete the item from the start category and add to the new category
                    let
                        updatedStartCat =
                            deleteSubject sub startCat
                    in
                    catList
                        |> List.map (maybeAddSubjectAfterExistingSub destSub sub destCat)
                        |> Util.replaceItem startCat updatedStartCat


maybeAddSubjectToEnd : Subject -> Category -> Category -> Category
maybeAddSubjectToEnd sub newCat currentCat =
    if newCat == currentCat then
        { currentCat | subjects = List.append currentCat.subjects [ sub ] }
    else
        currentCat


maybeAddSubjectAfterExistingSub : Subject -> Subject -> Category -> Category -> Category
maybeAddSubjectAfterExistingSub destSub newSub newCat currentCat =
    if newCat == currentCat then
        if newSub == destSub then
            currentCat
        else
            let
                updatedCurrentCat =
                    deleteSubject newSub currentCat
            in
            { currentCat | subjects = List.concatMap (insertSubAfter destSub newSub) updatedCurrentCat.subjects }
    else
        currentCat


insertSubAfter : Subject -> Subject -> Subject -> List Subject
insertSubAfter afterThisSub newSub currentSub =
    if afterThisSub == currentSub then
        [ currentSub, newSub ]
    else
        [ currentSub ]


removeDay : WeekDay -> DayOfWeekMask -> DayOfWeekMask
removeDay weekday mask =
    List.filter (\day -> day /= weekday) mask


addDay : WeekDay -> DayOfWeekMask -> DayOfWeekMask
addDay weekday mask =
    weekday :: mask


checkIfAllDaysTicked : Card -> Subject -> Subject
checkIfAllDaysTicked card subject =
    case card.schedulingMode of
        DayOfWeek selectedDays ->
            if List.length selectedDays > 6 then
                { subject | priorityLevel = 10000, cards = [ { card | schedulingMode = Default } ] }
            else
                subject

        _ ->
            subject


checkIfNoDaysTicked : Card -> Card
checkIfNoDaysTicked card =
    case card.schedulingMode of
        DayOfWeek [] ->
            { card | schedulingMode = Default }

        _ ->
            card


loadDemoData : Cmd Msg
loadDemoData =
    Http.get "test_data.json" decodePrayerMate
        |> RemoteData.sendRequest
        |> Cmd.map ReceivePrayerMate


fetchDropboxData : String -> Cmd Msg
fetchDropboxData url =
    Http.get url decodePrayerMate
        |> RemoteData.sendRequest
        |> Cmd.map ReceivePrayerMate
