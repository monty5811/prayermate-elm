module Categories.View exposing (view)

import DragDrop
import Editing exposing (Editing(..))
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Icons
import Messages exposing (Msg(..))
import Models exposing (CategoryStep(..))
import Prayermate exposing (Card, Category, PrayerMate, Subject)
import Subjects.View exposing (viewSubjectEdit)
import Views as V


view : CategoryStep -> PrayerMate -> Html Msg
view step data =
    Html.div [ A.class "overflow-x-scroll" ]
        [ Html.h2 [] [ Html.text "Lists" ]
        , V.kanban [ A.class "py-4" ]
            (createNewButton step :: List.map (viewCategory step) data.categories)
        ]


createNewButton : CategoryStep -> Html Msg
createNewButton step =
    Html.div [ A.class "w-full" ] <|
        case step of
            CreateCat tmpName ->
                createNewCategory tmpName

            _ ->
                [ V.greenButton
                    [ E.onClick CatCreateStart
                    , A.class "w-full"
                    ]
                    [ Html.text "Add New" ]
                ]


createNewCategory : String -> List (Html Msg)
createNewCategory tmpName =
    [ V.form [ E.onSubmit CatCreateSave ]
        [ V.textInput CatCreateUpdateName tmpName
        , V.greenButton [ E.onClick CatCreateSave ] [ Html.text "Create" ]
        , V.greyButton [ E.onClick CatCreateCancel ] [ Html.text "Cancel" ]
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

        EditSubject dndState eCat eSub ->
            if eCat == cat then
                viewCategoryEditSubject cat eSub

            else
                viewCategoryNoEdit dndState cat


catColClass : String
catColClass =
    "bg-grey-light px-2 rounded shadow"


viewCategoryNoEdit : DragDrop.Model Category Subject -> Category -> Html Msg
viewCategoryNoEdit dndModel cat =
    let
        isOver =
            DragDrop.isOver dndModel (DragDrop.Zone cat)

        dropClass =
            if isOver then
                "bg-green-light"

            else
                ""
    in
    Html.div
        ([ A.class catColClass, A.class dropClass ] ++ DragDrop.droppableZone DnD cat)
        [ Html.h3 [ A.class "inline-block py-2 cursor-pointer", E.onClick <| CatOpen cat ] [ Html.text cat.name ]
        , Html.div [ A.class "float-right" ]
            [ V.invertedButton [ A.class "inline-block px-1", E.onClick <| CatEditStart cat ] [ Icons.edit ]
            , V.invertedButton [ A.class "inline-block", E.onClick <| CatDeleteStart cat ] [ Icons.x ]
            ]
        , Html.ul [ A.class "list-reset" ] <| List.concatMap (subjectCard dndModel cat) cat.subjects
        ]


fakeSubjectCard : Category -> Bool -> Maybe (Html Msg)
fakeSubjectCard cat isOver =
    if isOver then
        Just <|
            Html.li
                [ A.class "p-4 mb-2 cursor-none border-dashed border-blue-light border-2" ]
                []

    else
        Nothing


viewCategoryEditSubject : Category -> Editing Subject -> Html Msg
viewCategoryEditSubject cat eSub =
    Html.div
        [ A.class catColClass ]
        (Html.h3 [ A.class "py-2" ] [ Html.text cat.name ]
            :: (case eSub of
                    NoSelected ->
                        []

                    Editing _ modifSub ->
                        viewSubjectEdit
                            { save = CatEditSubjectSave
                            , updateName = CatEditSubjectUpdateName
                            , cancel = CatEditSubjectCancel
                            }
                            modifSub
               )
        )


subjectCard : DragDrop.Model Category Subject -> Category -> Subject -> List (Html Msg)
subjectCard dndModel cat sub =
    let
        dragClass =
            if DragDrop.isDragged dndModel sub then
                "bg-grey-darker text-grey"

            else
                "bg-white"
    in
    [ Just <|
        Html.li
            ([ A.class "p-2 mb-2 rounded shadow cursor-point"
             , A.class dragClass
             , E.onClick <| CatEditSubjectStart cat sub
             ]
                ++ DragDrop.draggable DnD cat sub
                ++ DragDrop.droppableItem DnD cat sub
            )
            [ Html.text sub.name ]
    , fakeSubjectCard cat <| DragDrop.isOver dndModel (DragDrop.Item cat sub)
    ]
        |> List.filterMap identity


viewCategoryDelete : Html Msg
viewCategoryDelete =
    Html.div [ A.class catColClass ]
        [ V.form
            [ E.onSubmit NoOp
            , A.class "mt-8"
            ]
            [ V.redButton [ E.onClick CatDeleteConfirm, A.class "w-1/2" ] [ Html.text "Delete" ]
            , V.greyButton [ E.onClick CatDeleteCancel, A.class "w-1/2" ] [ Html.text "Cancel" ]
            ]
        ]


viewCategoryEdit : Category -> Html Msg
viewCategoryEdit modifiedCat =
    Html.div [ A.class catColClass ]
        [ V.form
            [ E.onSubmit CatEditSave
            , A.class "mt-8"
            ]
            [ V.textInput CatEditUpdateName modifiedCat.name
            , V.greenButton [ E.onClick CatEditSave ] [ Html.text "Save" ]
            , V.greyButton [ E.onClick CatEditCancel ] [ Html.text "Cancel" ]
            ]
        ]
