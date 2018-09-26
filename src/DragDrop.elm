module DragDrop
    exposing
        ( Model
        , Msg
        , Res(..)
        , draggable
        , droppable
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
    | Drop zone
    | DragOver zone
    | DragLeave zone
    | DragEnd


type alias Model zone item =
    Maybe (DnDModel zone item)


type alias DnDModel zone item =
    { startZone : zone
    , item : item
    , hovering : Maybe zone
    }


init : Model zone item
init =
    Nothing


type Res zone item
    = Dragging zone (Maybe zone) item
    | Dropped zone zone item
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

        ( DragOver overZone, Just model ) ->
            ( Just { model | hovering = Just overZone }
            , Dragging model.startZone (Just overZone) model.item
            )

        ( DragOver _, Nothing ) ->
            cancel

        ( Drop endZone, Just model ) ->
            ( Nothing, Dropped model.startZone endZone model.item )

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


droppable : (Msg a item -> msg) -> a -> List (Html.Attribute msg)
droppable tagger zone =
    [ onDrop <| tagger <| Drop zone
    , onDragEnter <| tagger <| DragOver zone
    , onDragLeave <| tagger <| DragLeave zone
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


isOver : Model zone item -> zone -> Bool
isOver model_ currentZone =
    case model_ of
        Nothing ->
            False

        Just { hovering } ->
            case hovering of
                Nothing ->
                    False

                Just zone ->
                    zone == currentZone


isDragged : Model zone item -> item -> Bool
isDragged model_ currentItem =
    case model_ of
        Nothing ->
            False

        Just { item } ->
            item == currentItem
