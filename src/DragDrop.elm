module DragDrop
    exposing
        ( Model
        , Msg
        , Res(..)
        , Target(..)
        , draggable
        , droppableItem
        , droppableZone
        , init
        , isDragged
        , isOver
        , update
        )

import Html
import Html.Attributes as A
import Html.Events as E
import Json.Decode


type Msg zone item
    = Drag zone item
    | Drop (Target zone item)
    | DragOver (Target zone item)
    | DragLeave (Target zone item)
    | DragEnd


type alias Model zone item =
    Maybe (DnDModel zone item)


type alias DnDModel zone item =
    { startZone : zone
    , item : item
    , hovering : Maybe (Target zone item)
    }


type Target zone item
    = Zone zone
    | Item zone item


init : Model zone item
init =
    Nothing


type Res zone item
    = Dragging zone (Maybe (Target zone item)) item
    | Dropped zone (Target zone item) item
    | DraggingCancelled


update : Msg zone item -> Model zone item -> ( Model zone item, Res zone item )
update msg model_ =
    case ( msg, model_ ) of
        ( Drag startZone item, _ ) ->
            ( Just
                { startZone = startZone
                , item = item
                , hovering = Nothing
                }
            , Dragging startZone Nothing item
            )

        ( DragOver overTarget, Just model ) ->
            ( Just { model | hovering = Just overTarget }
            , Dragging model.startZone (Just overTarget) model.item
            )

        ( DragOver _, Nothing ) ->
            cancel

        ( Drop endTarget, Just model ) ->
            ( Nothing, Dropped model.startZone endTarget model.item )

        ( Drop _, Nothing ) ->
            cancel

        ( DragLeave _, Just model ) ->
            ( Just { model | hovering = Nothing }
            , Dragging model.startZone Nothing model.item
            )

        ( DragLeave _, Nothing ) ->
            cancel

        ( DragEnd, _ ) ->
            cancel


cancel : ( Model zone item, Res zone item )
cancel =
    ( Nothing, DraggingCancelled )



-- Html attributes


droppableZone : (Msg zone item -> msg) -> zone -> List (Html.Attribute msg)
droppableZone tagger zone =
    [ onDrop <| tagger <| Drop <| Zone zone
    , onDragEnter <| tagger <| DragOver <| Zone zone
    , onDragLeave <| tagger <| DragLeave <| Zone zone
    , A.attribute "ondragover" "return false"
    ]


droppableItem : (Msg zone item -> msg) -> zone -> item -> List (Html.Attribute msg)
droppableItem tagger zone item =
    [ onDrop <| tagger <| Drop <| Item zone item
    , onDragEnter <| tagger <| DragOver <| Item zone item
    , onDragLeave <| tagger <| DragLeave <| Item zone item
    , A.attribute "ondragover" "return false"
    ]


draggable : (Msg zone item -> a) -> zone -> item -> List (Html.Attribute a)
draggable tagger zone item =
    [ A.draggable "true"
    , onDragStart <| tagger <| Drag zone item
    , onDragEnd <| tagger <| DragEnd
    ]



-- Html events


onDragStart : msg -> Html.Attribute msg
onDragStart msg =
    E.on "dragstart" (Json.Decode.succeed msg)


onDragEnter : msg -> Html.Attribute msg
onDragEnter msg =
    E.custom "dragover"
        (Json.Decode.succeed
            { message = msg
            , preventDefault = True
            , stopPropagation = True
            }
        )


onDragEnd : msg -> Html.Attribute msg
onDragEnd msg =
    E.on "dragend" (Json.Decode.succeed msg)


onDragLeave : msg -> Html.Attribute msg
onDragLeave msg =
    E.custom "dragleave"
        (Json.Decode.succeed
            { message = msg
            , preventDefault = True
            , stopPropagation = True
            }
        )


onDrop : msg -> Html.Attribute msg
onDrop msg =
    E.custom "drop"
        (Json.Decode.succeed
            { message = msg
            , preventDefault = True
            , stopPropagation = True
            }
        )



-- helpers


isOver : Model zone item -> Target zone item -> Bool
isOver model_ currentTarget =
    case model_ of
        Nothing ->
            False

        Just { hovering } ->
            case hovering of
                Nothing ->
                    False

                Just target ->
                    target == currentTarget


isDragged : Model zone item -> item -> Bool
isDragged model_ currentItem =
    case model_ of
        Nothing ->
            False

        Just { item } ->
            item == currentItem
