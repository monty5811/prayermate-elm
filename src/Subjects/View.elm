module Subjects.View exposing (view)

import Editing exposing (Editing(Editing, NoSelected))
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Icons
import Models exposing (SubjectStep(..))
import Prayermate exposing (Card, Category, Subject)
import Subjects.Messages exposing (Msg(..))
import Views as V exposing (defaultGridOptions, defaultKanBanOptions)


view : Editing Category -> SubjectStep -> List Category -> Html Msg
view category step categories =
    case step of
        MoveSubject sub2move ->
            Html.div []
                [ Html.h3 [ A.class "text-center" ] [ Html.text <| "Move " ++ sub2move.name ++ " to a different list:" ]
                , V.greyButton [ A.class "w-full my-8", E.onClick MoveCancel ] [ Html.text "Cancel Move" ]
                , V.gridWithOptions { defaultGridOptions | minHeight = 150, gridGap = 20 } [] (List.map viewCat categories)
                ]

        _ ->
            let
                subjects =
                    category
                        |> Editing.modified
                        |> Maybe.map .subjects
                        |> Maybe.withDefault []
            in
            Html.div [ A.class "overflow-x-scroll" ]
                [ Html.h2 []
                    [ V.invertedButton [ E.onClick CloseList ] [ Icons.cornerUpLeft ]
                    , Editing.original category |> Maybe.map .name |> Maybe.withDefault "" |> Html.text
                    ]
                , V.kanbanWithOptions { defaultKanBanOptions | minHeight = 500, colWidth = 360 } [] (createNewButton step :: List.map (viewSubject step) subjects)
                ]


createNewButton : SubjectStep -> Html Msg
createNewButton step =
    Html.div [ A.class "w-full" ] <|
        case step of
            CreateSubject tmpName ->
                createNewSubject tmpName

            _ ->
                [ V.greenButton
                    [ E.onClick CreateStart
                    , A.class "w-full"
                    ]
                    [ Html.text "Add New" ]
                ]


createNewSubject : String -> List (Html Msg)
createNewSubject tmpName =
    [ V.form [ E.onSubmit CreateSave ]
        [ V.textInput CreateUpdateName tmpName
        , V.greenButton [ E.onClick CreateSave ] [ Html.text "Create" ]
        , V.greyButton [ E.onClick CreateCancel ] [ Html.text "Cancel" ]
        ]
    ]


viewCat : Category -> Html Msg
viewCat cat =
    Html.div
        [ E.onClick <| MoveComplete cat
        , A.class "p-4 bg-blue hover:bg-blue-dark cursor-pointer text-white font-bold text-center text-3xl"
        ]
        [ Html.text cat.name ]


viewSubject : SubjectStep -> Subject -> Html Msg
viewSubject step sub =
    let
        elems =
            case step of
                ViewSubjects ->
                    viewSubjectNoEdit sub

                EditSubjectName NoSelected ->
                    viewSubjectNoEdit sub

                EditSubjectName (Editing originalSub modifiedSub) ->
                    if sub == originalSub then
                        viewSubjectEdit modifiedSub
                    else
                        viewSubjectNoEdit sub

                CreateSubject _ ->
                    viewSubjectNoEdit sub

                DeleteSubject sub2Delete ->
                    if sub == sub2Delete then
                        viewSubjectDelete
                    else
                        viewSubjectNoEdit sub

                MoveSubject _ ->
                    []

                EditSubjectCard subWeAreEditing editingCard ->
                    viewSubjectEditingCard sub subWeAreEditing editingCard
    in
    Html.div [ A.class "bg-grey px-2" ] elems


viewSubjectDelete : List (Html Msg)
viewSubjectDelete =
    [ V.redButton [ E.onClick DeleteConfirm ] [ Html.text "Delete" ]
    , V.greyButton [ E.onClick DeleteCancel ] [ Html.text "Cancel" ]
    ]


viewSubjectEditingCard : Subject -> Editing Subject -> Editing Card -> List (Html Msg)
viewSubjectEditingCard currentSub subWeAreEditing editingCard =
    case ( subWeAreEditing, editingCard ) of
        ( Editing origSub _, Editing _ modifiedCard ) ->
            if currentSub == origSub then
                [ V.form
                    [ E.onSubmit EditCardSave ]
                    [ V.greenButton [ E.onClick EditCardSave ] [ Html.text "Save" ]
                    , V.greyButton [ E.onClick EditCardCancel ] [ Html.text "Cancel" ]
                    , V.textArea 30 EditCardUpdateText (Maybe.withDefault "" modifiedCard.text)
                    ]
                ]
            else
                viewSubjectNoEdit currentSub

        ( _, _ ) ->
            [ Html.text "" ]


viewSubjectNoEdit : Subject -> List (Html Msg)
viewSubjectNoEdit sub =
    [ V.invertedButton [ E.onClick <| EditStart sub ] [ Icons.edit ]
    , V.invertedButton [ E.onClick <| DeleteStart sub ] [ Icons.x ]
    , V.invertedButton [ E.onClick <| MoveStart sub ] [ Icons.move ]
    , Html.h3 [ A.class "pb-2" ] [ Html.text sub.name ]
    , if List.length sub.cards > 0 then
        Html.div [] <| List.map (viewCard sub) sub.cards
      else
        V.greenButton [ E.onClick <| CreateEmptyCard sub ] [ Icons.plus ]
    ]


viewSubjectEdit : Subject -> List (Html Msg)
viewSubjectEdit modifiedSub =
    [ V.form
        [ E.onSubmit EditSave ]
        [ V.textInput EditUpdateName modifiedSub.name
        , V.greenButton [ E.onClick EditSave ] [ Html.text "Save" ]
        , V.greyButton [ E.onClick EditCancel ] [ Html.text "Cancel" ]
        ]
    ]


viewCard : Subject -> Card -> Html Msg
viewCard sub card =
    Html.div [ A.class "p-2" ]
        [ V.invertedButton [ E.onClick <| EditCardStart sub card, A.class "float-right" ] [ Icons.edit ]
        , Html.div [ E.onClick <| EditCardStart sub card ] <| paragraghs card
        ]


paragraghs : Card -> List (Html msg)
paragraghs card =
    card.text
        |> Maybe.withDefault ""
        |> String.split "\n"
        |> List.map Html.text
        |> List.map List.singleton
        |> List.map (Html.p [])
