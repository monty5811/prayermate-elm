module Categories.View exposing (exportButton, view)

import Categories.Messages exposing (Msg(..))
import DragDrop
import Editing exposing (Editing(Editing, NoSelected))
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Icons
import Models exposing (CategoryStep(CreateCat, DeleteCat, EditCat, ViewCats))
import Prayermate exposing (Category, PrayerMate, Subject, exportb64)
import Views as V


view : CategoryStep -> PrayerMate -> Html Msg
view step data =
    Html.div [ A.class "overflow-x-scroll" ]
        [ exportButton data
        , Html.h2 [] [ Html.text "Lists" ]
        , V.kanban [ A.class "py-4" ]
            (createNewButton step :: List.map (viewCategory step) data.categories)
        ]


exportButton : PrayerMate -> Html msg
exportButton data =
    Html.a
        [ A.href <| exportb64 data
        , A.downloadAs "unofficial_prayemate_export.json"
        , A.class "absolute pin-t pin-r p-1"
        ]
        [ V.greenButton [] [ Html.text "Export" ] ]


createNewButton : CategoryStep -> Html Msg
createNewButton step =
    Html.div [ A.class "w-full" ] <|
        case step of
            CreateCat tmpName ->
                createNewCategory tmpName

            _ ->
                [ V.greenButton
                    [ E.onClick CreateStart
                    , A.class "w-full"
                    ]
                    [ Html.text "Add New" ]
                ]


createNewCategory : String -> List (Html Msg)
createNewCategory tmpName =
    [ V.form [ E.onSubmit CreateSave ]
        [ V.textInput CreateUpdateName tmpName
        , V.greenButton [ E.onClick CreateSave ] [ Html.text "Create" ]
        , V.greyButton [ E.onClick CreateCancel ] [ Html.text "Cancel" ]
        ]
    ]


viewCategory : CategoryStep -> Category -> Html Msg
viewCategory step cat =
    case step of
        ViewCats dndState ->
            viewCategoryNoEdit dndState cat

        EditCat NoSelected ->
            viewCategoryNoEdit Nothing cat

        EditCat (Editing originalCat modifiedCat) ->
            if cat == originalCat then
                viewCategoryEdit modifiedCat
            else
                viewCategoryNoEdit Nothing cat

        DeleteCat cat2Delete ->
            if cat == cat2Delete then
                viewCategoryDelete
            else
                viewCategoryNoEdit Nothing cat

        CreateCat _ ->
            viewCategoryNoEdit Nothing cat


catColClass : String
catColClass =
    "bg-grey px-2"


viewCategoryNoEdit : DragDrop.Model Category Subject -> Category -> Html Msg
viewCategoryNoEdit dndModel cat =
    let
        dropClass =
            if DragDrop.isOver dndModel cat then
                "bg-green-light"
            else
                ""
    in
    Html.div
        ([ A.class catColClass, A.class dropClass ] ++ DragDrop.droppable DnD cat)
        [ V.invertedButton [ E.onClick <| EditStart cat ] [ Icons.edit ]
        , V.invertedButton [ E.onClick <| DeleteStart cat ] [ Icons.x ]
        , Html.h3 [ A.class "pb-2 cursor-pointer", E.onClick <| Open cat ] [ Html.text cat.name ]
        , Html.ul [ A.class "list-reset" ] (List.map (subjectCard dndModel cat) cat.subjects)
        ]


subjectCard : DragDrop.Model Category Subject -> Category -> Subject -> Html Msg
subjectCard dndModel cat sub =
    let
        dragClass =
            if DragDrop.isDragged dndModel sub then
                "bg-grey-darker text-grey"
            else
                "bg-grey-light"
    in
    Html.li
        ([ A.class "p-2 mb-2"
         , A.class dragClass
         ]
            ++ DragDrop.draggable DnD cat sub
        )
        [ Html.text sub.name ]


viewCategoryDelete : Html Msg
viewCategoryDelete =
    Html.div [ A.class catColClass ]
        [ V.redButton [ E.onClick DeleteConfirm ] [ Html.text "Delete" ]
        , V.greyButton [ E.onClick DeleteCancel ] [ Html.text "Cancel" ]
        ]


viewCategoryEdit : Category -> Html Msg
viewCategoryEdit modifiedCat =
    Html.div [ A.class catColClass ]
        [ V.form
            [ E.onSubmit EditSave ]
            [ V.textInput EditUpdateName modifiedCat.name
            , V.greenButton [ E.onClick EditSave ] [ Html.text "Save" ]
            , V.greyButton [ E.onClick EditCancel ] [ Html.text "Cancel" ]
            ]
        ]
