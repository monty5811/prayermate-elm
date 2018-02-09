module Util
    exposing
        ( dateTimeFormat
        , decodePrayerMate2WebData
        , focusInput
        )

import Dict
import Dom
import Http
import Json.Decode
import PrayermateModels exposing (PrayerMate, decodePrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Task


focusInput : msg -> Cmd msg
focusInput msg =
    Task.attempt (\_ -> msg) (Dom.focus "focusable")


dateTimeFormat : String
dateTimeFormat =
    "%Y-%m-%dT%H:%M"


decodePrayerMate2WebData : String -> WebData PrayerMate
decodePrayerMate2WebData str =
    str
        |> Json.Decode.decodeString decodePrayerMate
        |> RemoteData.fromResult
        |> toWebData


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
