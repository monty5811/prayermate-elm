module Subjects.View exposing (view, viewSubjectEdit)

import Editing exposing (Editing(..))
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Icons
import Messages exposing (Msg(..))
import Models exposing (SubjectStep(..))
import Prayermate exposing (Card, Category, Subject)
import Views as V exposing (defaultGridOptions, defaultKanBanOptions)


view : Editing Category -> SubjectStep -> List Category -> Html Msg
view category step categories =
    case step of
        MoveSubject sub2move ->
            Html.div [ A.class "px-6" ]
                [ Html.h3 [ A.class "text-center" ] [ Html.text <| "Move \"" ++ sub2move.name ++ "\" to a different list:" ]
                , V.greenButton [ A.class "w-full my-8", E.onClick SubMoveCancel ] [ Html.text "Cancel Move" ]
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
            Html.div [ A.class "overflow-x-scroll px-6" ]
                [ Html.div [ A.class "flex items-center" ]
                    [ Html.h2 [ A.class "inline-block" ]
                        [ V.invertedButton [ E.onClick CloseList ] [ Icons.cornerUpLeft ]
                        , Editing.original category |> Maybe.map .name |> Maybe.withDefault "" |> Html.text
                        ]
                    , createNewButton step
                    ]
                , V.gridWithOptions
                    { defaultGridOptions | minHeight = 300, minCols = 5 }
                    [ A.class "py-4" ]
                    (List.map (viewSubject step) subjects)
                ]


createNewButton : SubjectStep -> Html Msg
createNewButton step =
    Html.div [ A.class "inline-block ml-8" ] <|
        case step of
            CreateSubject tmpName ->
                createNewSubject tmpName

            _ ->
                [ V.greenButton
                    [ E.onClick SubCreateStart
                    , A.class "w-full"
                    ]
                    [ Html.text "Add New" ]
                ]


createNewSubject : String -> List (Html Msg)
createNewSubject tmpName =
    [ V.simpleForm [ E.onSubmit SubCreateSave ]
        [ V.textInput [ A.class "inline-block w-md mx-1" ] SubCreateUpdateName tmpName
        , V.greenButton [ E.onClick SubCreateSave, A.class "mx-1" ] [ Html.text "Create" ]
        , V.greyButton [ E.onClick SubCreateCancel, A.class "mx-1" ] [ Html.text "Cancel" ]
        ]
    ]


viewCat : Category -> Html Msg
viewCat cat =
    Html.div
        [ E.onClick <| SubMoveComplete cat
        , A.class "p-4 rounded shadow-md bg-white text-grey-dark hover:bg-grey-dark hover:border hover:text-white cursor-pointer font-bold text-center text-3xl"
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
                        viewSubjectEdit viewSubjectEditProps modifiedSub

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
    Html.div [ V.colClass ] elems


viewSubjectDelete : List (Html Msg)
viewSubjectDelete =
    [ V.simpleForm
        [ E.onSubmit NoOp
        , A.class "mt-8"
        ]
        [ V.redButton [ E.onClick SubDeleteConfirm, A.class "w-1/2" ] [ Html.text "Delete" ]
        , V.greyButton [ E.onClick SubDeleteCancel, A.class "w-1/2" ] [ Html.text "Cancel" ]
        ]
    ]


viewSubjectEditingCard : Subject -> Editing Subject -> Editing Card -> List (Html Msg)
viewSubjectEditingCard currentSub subWeAreEditing editingCard =
    case ( subWeAreEditing, editingCard ) of
        ( Editing origSub _, Editing _ modifiedCard ) ->
            if currentSub == origSub then
                [ V.simpleForm
                    [ E.onSubmit EditCardSave ]
                    [ V.greenButton [ E.onClick EditCardSave, A.class "w-1/2" ] [ Html.text "Save" ]
                    , V.greyButton [ E.onClick EditCardCancel, A.class "w-1/2" ] [ Html.text "Cancel" ]
                    , V.textArea 30 EditCardUpdateText (Maybe.withDefault "" modifiedCard.text)
                    ]
                ]

            else
                viewSubjectNoEdit currentSub

        ( _, _ ) ->
            [ Html.text "" ]


viewSubjectNoEdit : Subject -> List (Html Msg)
viewSubjectNoEdit sub =
    [ Html.h3 [ A.class "inline-block py-2" ] [ Html.text sub.name ]
    , Html.div [ A.class "float-right" ]
        [ V.invertedButton [ E.onClick <| SubEditStart sub ] [ Icons.edit ]
        , V.invertedButton [ E.onClick <| SubDeleteStart sub ] [ Icons.x ]
        , V.invertedButton [ E.onClick <| SubMoveStart sub ] [ Icons.move ]
        ]
    , if List.length sub.cards > 0 then
        Html.div [] <| List.map (viewCard sub) sub.cards

      else
        V.greenButton [ E.onClick <| CreateEmptyCard sub ] [ Icons.plus ]
    ]


type alias ViewSubjectEditProps =
    { save : Msg
    , updateName : String -> Msg
    , cancel : Msg
    }


viewSubjectEditProps : ViewSubjectEditProps
viewSubjectEditProps =
    ViewSubjectEditProps SubEditSave SubEditUpdateName SubEditCancel


viewSubjectEdit : ViewSubjectEditProps -> Subject -> List (Html Msg)
viewSubjectEdit props modifiedSub =
    [ V.simpleForm
        [ E.onSubmit props.save ]
        [ V.textInput [ A.class "w-full" ] props.updateName modifiedSub.name
        , V.textArea 15 CatEditUpdateCardText (getCardText modifiedSub)
        , V.greenButton [ E.onClick props.save, A.class "w-1/2" ] [ Html.text "Save" ]
        , V.greyButton [ E.onClick props.cancel, A.class "w-1/2" ] [ Html.text "Cancel" ]
        ]
    ]


getCardText : Subject -> String
getCardText sub =
    case List.head sub.cards of
        Nothing ->
            ""

        Just card ->
            Maybe.withDefault "" card.text


viewCard : Subject -> Card -> Html Msg
viewCard sub card =
    Html.div [ A.class "p-2" ]
        [ Html.div [ E.onClick <| EditCardStart sub card ] <| paragraghs card ]


paragraghs : Card -> List (Html msg)
paragraghs card =
    card.text
        |> Maybe.withDefault ""
        |> String.split "\n"
        |> List.map Html.text
        |> List.map List.singleton
        |> List.map (Html.p [])
