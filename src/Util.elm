module Util
    exposing
        ( dateTimeFormat
        , focusInput
        , replaceItem
        , toWebData
        )

import Dict
import Dom
import Http
import RemoteData exposing (RemoteData(..), WebData)
import Task


replaceItem : a -> a -> List a -> List a
replaceItem orig modif categoryList =
    List.map (replaceItemHelp orig modif) categoryList


replaceItemHelp : a -> a -> a -> a
replaceItemHelp orig modif current =
    if orig == current then
        modif
    else
        current


focusInput : msg -> Cmd msg
focusInput msg =
    Task.attempt (\_ -> msg) (Dom.focus "focusable")


dateTimeFormat : String
dateTimeFormat =
    "%Y-%m-%dT%H:%M"


toWebData : RemoteData e a -> WebData a
toWebData remote =
    case remote of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure err ->
            Failure <|
                Http.BadPayload (toString err)
                    { url = ""
                    , status = { code = -1, message = "" }
                    , headers = Dict.empty
                    , body = "Woops"
                    }

        Success val ->
            Success val
