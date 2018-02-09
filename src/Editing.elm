module Editing exposing (Editing(Editing, NoSelected), map, modified, original)


type Editing a
    = NoSelected
    | Editing a a


map : (a -> a) -> Editing a -> Editing a
map fn ed =
    case ed of
        NoSelected ->
            NoSelected

        Editing orig modified ->
            Editing orig (fn modified)


original : Editing a -> Maybe a
original ed =
    case ed of
        NoSelected ->
            Nothing

        Editing orig modified ->
            Just orig


modified : Editing a -> Maybe a
modified ed =
    case ed of
        NoSelected ->
            Nothing

        Editing orig modified ->
            Just modified
