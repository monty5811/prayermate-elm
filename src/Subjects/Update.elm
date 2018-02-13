module Subjects.Update
    exposing
        ( deleteSubject
        , maybeAddSubject
        , update
        )

import Editing exposing (Editing(Editing))
import Models exposing (Step(..), SubjectStep(..), initialCategoriesStep)
import Prayermate exposing (Category, Subject, newCard, newSubject)
import RemoteData exposing (WebData)
import Subjects.Messages exposing (Msg(..))
import Time
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
                    ( initialCategoriesStep, RemoteData.map (Util.replaceItem origCat modifiedCat) cats, Cmd.none )

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
                                    |> RemoteData.map (Util.replaceItem originalCat newCurrentCat)
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
                SubjectsList cat (EditSubjectCard (Editing origSub _) (Editing origCard modifCard)) ->
                    let
                        newSub =
                            { origSub | cards = Util.replaceItem origCard modifCard origSub.cards }

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
    { category | subjects = Util.replaceItem orig new category.subjects }


maybeAddSubject : Subject -> Category -> Category -> Category
maybeAddSubject sub newCat currentCat =
    if newCat == currentCat then
        { currentCat | subjects = List.append currentCat.subjects [ sub ] }
    else
        currentCat


addNewSubject : Time.Time -> String -> Category -> Category
addNewSubject currentTime name cat =
    { cat | subjects = List.append cat.subjects [ newSubject currentTime name Nothing ] }


addEmptyCard : Time.Time -> Subject -> Category -> Category
addEmptyCard currentTime sub cat =
    { cat | subjects = List.map (addEmptyCardHelp currentTime sub) cat.subjects }


addEmptyCardHelp : Time.Time -> Subject -> Subject -> Subject
addEmptyCardHelp currentTime sub2change currentSub =
    if sub2change == currentSub then
        { currentSub | cards = newCard currentTime Nothing :: currentSub.cards }
    else
        currentSub


deleteSubject : Subject -> Category -> Category
deleteSubject sub category =
    { category | subjects = deleteSubjectHelp sub category.subjects }


deleteSubjectHelp : Subject -> List Subject -> List Subject
deleteSubjectHelp sub subjects =
    List.filter (\x -> x /= sub) subjects
