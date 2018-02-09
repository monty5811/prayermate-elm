module Subjects.Update
    exposing
        ( deleteSubject
        , maybeAddSubject
        , replaceItem
        , update
        )

import Editing exposing (..)
import Models exposing (CategoryStep(ViewCats), Step(..), SubjectStep(..), initialCategoriesStep)
import PrayermateModels exposing (..)
import RemoteData exposing (WebData)
import Subjects.Messages exposing (..)
import Time
import Time.Format
import Util


update : Time.Time -> Msg -> Step -> WebData (List Category) -> ( Step, WebData (List Category), Cmd Msg )
update currentTime msg step cats =
    case msg of
        NoOp ->
            ( step, cats, Cmd.none )

        EditStart sub ->
            case step of
                SubjectsList category ViewSubjects ->
                    ( SubjectsList category <| EditSubjectName (Editing sub sub), cats, Util.focusInput NoOp )

                _ ->
                    ( step, cats, Cmd.none )

        EditUpdateName newName ->
            case step of
                SubjectsList cat (EditSubjectName editingSubject) ->
                    ( SubjectsList cat <|
                        EditSubjectName <|
                            Editing.map (updateName newName) editingSubject
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditSave ->
            case step of
                SubjectsList cat (EditSubjectName (Editing original modified)) ->
                    ( SubjectsList (Editing.map (replaceSubject original modified) cat) ViewSubjects
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditCancel ->
            case step of
                SubjectsList cat _ ->
                    ( SubjectsList cat ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        DeleteStart sub ->
            case step of
                SubjectsList cat ViewSubjects ->
                    ( SubjectsList cat <| DeleteSubject sub, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        DeleteCancel ->
            case step of
                SubjectsList cat (DeleteSubject _) ->
                    ( SubjectsList cat <| ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        DeleteConfirm ->
            case step of
                SubjectsList cat (DeleteSubject sub2delete) ->
                    ( SubjectsList (Editing.map (deleteSubject sub2delete) cat) <| ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        CloseList ->
            case step of
                SubjectsList (Editing origCat modifiedCat) _ ->
                    ( initialCategoriesStep, RemoteData.map (replaceItem origCat modifiedCat) cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        CreateStart ->
            case step of
                SubjectsList cat ViewSubjects ->
                    ( SubjectsList cat (CreateSubject ""), cats, Util.focusInput NoOp )

                _ ->
                    ( step, cats, Cmd.none )

        CreateCancel ->
            case step of
                SubjectsList cat (CreateSubject _) ->
                    ( SubjectsList cat ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        CreateSave ->
            case step of
                SubjectsList cat (CreateSubject name) ->
                    ( SubjectsList (Editing.map (addNewSubject currentTime name) cat) ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        CreateUpdateName text ->
            case step of
                SubjectsList cat (CreateSubject _) ->
                    ( SubjectsList cat (CreateSubject text)
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        MoveStart sub ->
            case step of
                SubjectsList cat ViewSubjects ->
                    ( SubjectsList cat <| MoveSubject sub, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        MoveCancel ->
            case step of
                SubjectsList cat (MoveSubject _) ->
                    ( SubjectsList cat <| ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        MoveComplete newCat ->
            case step of
                SubjectsList (Editing originalCat modifiedCat) (MoveSubject sub2Move) ->
                    -- remove subject from current category in the step and in the list
                    -- and add subject to new category in the list
                    if newCat == originalCat then
                        ( SubjectsList (Editing originalCat modifiedCat) ViewSubjects, cats, Cmd.none )
                    else
                        let
                            newCurrentCat =
                                deleteSubject sub2Move modifiedCat

                            newList =
                                cats
                                    |> RemoteData.map (List.map (maybeAddSubject sub2Move newCat))
                                    |> RemoteData.map (replaceItem originalCat newCurrentCat)
                        in
                        ( SubjectsList
                            (Editing newCurrentCat newCurrentCat)
                            ViewSubjects
                        , newList
                        , Cmd.none
                        )

                _ ->
                    ( step, cats, Cmd.none )

        EditCardStart sub card ->
            case step of
                SubjectsList cat ViewSubjects ->
                    ( SubjectsList cat
                        (EditSubjectCard (Editing sub sub) (Editing card card))
                    , cats
                    , Util.focusInput NoOp
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditCardUpdateText text ->
            case step of
                SubjectsList cat (EditSubjectCard editingSubject editingCard) ->
                    ( SubjectsList cat
                        (EditSubjectCard editingSubject (Editing.map (updateText text) editingCard))
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditCardSave ->
            case step of
                SubjectsList cat (EditSubjectCard (Editing origSub modifSub) (Editing origCard modifCard)) ->
                    let
                        newSub =
                            { origSub | cards = replaceItem origCard modifCard origSub.cards }

                        newCat =
                            Editing.map (replaceSubject origSub newSub) cat
                    in
                    ( SubjectsList newCat ViewSubjects
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditCardCancel ->
            case step of
                SubjectsList cat (EditSubjectCard _ _) ->
                    ( SubjectsList cat ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )

        CreateEmptyCard sub ->
            case step of
                SubjectsList cat ViewSubjects ->
                    ( SubjectsList (Editing.map (addEmptyCard currentTime sub) cat) ViewSubjects, cats, Cmd.none )

                _ ->
                    ( step, cats, Cmd.none )


updateName : String -> { a | name : String } -> { a | name : String }
updateName new rec =
    { rec | name = new }


updateText : String -> { a | text : Maybe String } -> { a | text : Maybe String }
updateText new rec =
    { rec | text = Just new }


replaceSubject : Subject -> Subject -> Category -> Category
replaceSubject orig new category =
    { category | subjects = replaceItem orig new category.subjects }


replaceItem : a -> a -> List a -> List a
replaceItem orig modif categoryList =
    List.map (replaceItemHelp orig modif) categoryList


replaceItemHelp : a -> a -> a -> a
replaceItemHelp orig modif current =
    if orig == current then
        modif
    else
        current


maybeAddSubject : Subject -> Category -> Category -> Category
maybeAddSubject sub newCat currentCat =
    if newCat == currentCat then
        { currentCat | subjects = List.append currentCat.subjects [ sub ] }
    else
        currentCat


addNewSubject : Time.Time -> String -> Category -> Category
addNewSubject currentTime name cat =
    { cat | subjects = List.append cat.subjects [ newSubject currentTime name ] }


newSubject : Time.Time -> String -> Subject
newSubject currentTime name =
    { name = name
    , createdDate = Time.Format.format Util.dateTimeFormat currentTime
    , lastPrayed = Nothing
    , schedulingTimestamp = Nothing
    , syncID = Nothing
    , priorityLevel = 0
    , seenCount = 0
    , cards = [ emptyCard currentTime ]
    }


addEmptyCard : Time.Time -> Subject -> Category -> Category
addEmptyCard currentTime sub cat =
    { cat | subjects = List.map (addEmptyCardHelp currentTime sub) cat.subjects }


addEmptyCardHelp : Time.Time -> Subject -> Subject -> Subject
addEmptyCardHelp currentTime sub2change currentSub =
    if sub2change == currentSub then
        { currentSub | cards = emptyCard currentTime :: currentSub.cards }
    else
        currentSub


emptyCard : Time.Time -> Card
emptyCard currentTime =
    { text = Nothing
    , archived = False
    , syncID = Nothing
    , createdDate = Time.Format.format Util.dateTimeFormat currentTime
    , dayOfTheWeekMask = 0
    , schedulingMode = 0
    , lastPrayed = Nothing
    , seenCount = 0
    }


deleteSubject : Subject -> Category -> Category
deleteSubject sub category =
    { category | subjects = deleteSubjectHelp sub category.subjects }


deleteSubjectHelp : Subject -> List Subject -> List Subject
deleteSubjectHelp sub subjects =
    List.filter (\x -> x /= sub) subjects
