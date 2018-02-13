module Categories.Update exposing (update)

import Categories.Messages exposing (Msg(..))
import DragDrop exposing (Res(Dragging, DraggingCancelled, Dropped))
import Editing exposing (Editing(Editing, NoSelected))
import Models
    exposing
        ( CategoryStep(..)
        , Step(CategoriesList, SubjectsList)
        , SubjectStep(ViewSubjects)
        , initialCategoriesStep
        )
import Prayermate exposing (Category, Subject, newCategory)
import RemoteData exposing (WebData)
import Subjects.Update as Subj
import Time
import Util


update : Time.Time -> Msg -> Step -> WebData (List Category) -> ( Step, WebData (List Category), Cmd Msg )
update currentTime msg step cats =
    case msg of
        NoOp ->
            ( step, cats, Cmd.none )

        Open cat ->
            ( SubjectsList (Editing cat cat) ViewSubjects, cats, Cmd.none )

        EditStart cat ->
            ( CategoriesList <| EditCat (Editing cat cat), cats, Util.focusInput NoOp )

        EditUpdateName updatingName ->
            case step of
                CategoriesList (EditCat editing) ->
                    ( editing
                        |> Editing.map (updateName updatingName)
                        |> EditCat
                        |> CategoriesList
                    , cats
                    , Cmd.none
                    )

                _ ->
                    ( step, cats, Cmd.none )

        EditSave ->
            case step of
                CategoriesList (EditCat NoSelected) ->
                    ( step, cats, Cmd.none )

                CategoriesList (EditCat (Editing origCat modCat)) ->
                    ( initialCategoriesStep
                    , RemoteData.map (updateCategory origCat modCat) cats
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        EditCancel ->
            ( initialCategoriesStep, cats, Cmd.none )

        DeleteStart cat ->
            case step of
                CategoriesList _ ->
                    ( CategoriesList (DeleteCat cat), cats, Cmd.none )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        DeleteCancel ->
            case step of
                CategoriesList (DeleteCat _) ->
                    ( initialCategoriesStep, cats, Cmd.none )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        DeleteConfirm ->
            case step of
                CategoriesList (DeleteCat cat2Delete) ->
                    ( initialCategoriesStep, RemoteData.map (deleteCategory cat2Delete) cats, Cmd.none )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        CreateStart ->
            case step of
                CategoriesList _ ->
                    ( CategoriesList (CreateCat ""), cats, Util.focusInput NoOp )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        CreateCancel ->
            case step of
                CategoriesList (CreateCat _) ->
                    ( initialCategoriesStep, cats, Cmd.none )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        CreateSave ->
            case step of
                CategoriesList (CreateCat name) ->
                    ( initialCategoriesStep
                    , RemoteData.map (addNewCategory currentTime name) cats
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        CreateUpdateName text ->
            case step of
                CategoriesList (CreateCat _) ->
                    ( CategoriesList (CreateCat text)
                    , cats
                    , Cmd.none
                    )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )

        DnD msg_ ->
            case step of
                CategoriesList (ViewCats oldDndModel) ->
                    let
                        ( dndModel, result ) =
                            DragDrop.update msg_ oldDndModel
                    in
                    case result of
                        Dragging _ _ _ ->
                            ( CategoriesList (ViewCats dndModel), cats, Cmd.none )

                        Dropped startCat endCat subject ->
                            ( CategoriesList (ViewCats dndModel)
                            , RemoteData.map (dropSubject subject startCat endCat) cats
                            , Cmd.none
                            )

                        DraggingCancelled ->
                            ( CategoriesList (ViewCats dndModel), cats, Cmd.none )

                _ ->
                    -- skip every other step
                    ( step, cats, Cmd.none )


dropSubject : Subject -> Category -> Category -> List Category -> List Category
dropSubject sub startCat destCat catList =
    if startCat == destCat then
        -- short circuit if start and end are the same
        catList
    else
        let
            updatedStartCat =
                Subj.deleteSubject sub startCat
        in
        catList
            |> List.map (Subj.maybeAddSubject sub destCat)
            |> Util.replaceItem startCat updatedStartCat


updateName : String -> Category -> Category
updateName newText cat =
    { cat | name = newText }


addNewCategory : Time.Time -> String -> List Category -> List Category
addNewCategory currentTime name cats =
    newCategory currentTime name :: cats


deleteCategory : Category -> List Category -> List Category
deleteCategory cat categories =
    List.filter (\x -> x /= cat) categories


updateCategory : Category -> Category -> List Category -> List Category
updateCategory origCat newCat categories =
    List.map (updateCategoryHelp origCat newCat) categories


updateCategoryHelp : Category -> Category -> Category -> Category
updateCategoryHelp origCat modCat iterCat =
    if origCat == iterCat then
        modCat
    else
        iterCat
