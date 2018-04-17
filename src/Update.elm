module Update exposing (update)

import CsvConvert exposing (parseCsvData)
import DragDrop exposing (Res(Dragging, DraggingCancelled, Dropped))
import Editing exposing (Editing(Editing, NoSelected))
import Http
import Json.Decode
import Messages exposing (Msg(..))
import Models exposing (..)
import Navigation
import Ports exposing (fileSelected, openDropboxChooser)
import Prayermate exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
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
                        Just (Ok pm) ->
                            ( { model
                                | step = initialCategoriesStep
                                , pm = Success pm
                                , originalPm = Success pm
                              }
                            , Navigation.modifyUrl "/"
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GoToScheduler ->
            case model.step of
                CategoriesList (ViewCats _) ->
                    ( { model | step = Scheduler }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CloseScheduler ->
            case model.step of
                Scheduler ->
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

                        Dropped startCat endCat subject ->
                            let
                                cats =
                                    RemoteData.map (.categories >> dropSubject subject startCat endCat) model.pm
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
                                    |> RemoteData.map (List.map (maybeAddSubject sub2Move newCat))
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
                    ( model, Cmd.none )

                DayOfMonth _ ->
                    ( model, Cmd.none )


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
