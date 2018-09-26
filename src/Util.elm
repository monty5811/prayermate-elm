module Util
    exposing
        ( focusInput
        , formatDateTime
        , replaceItem
        , toWebData
        )

import Browser.Dom
import DateFormat as DF
import Dict
import Http
import Json.Decode
import RemoteData exposing (RemoteData(..), WebData)
import Task
import Time


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
    Task.attempt (\_ -> msg) (Browser.Dom.focus "focusable")


formatDateTime : Time.Posix -> String
formatDateTime t =
    DF.format
        [ DF.yearNumber
        , DF.text "-"
        , DF.monthFixed
        , DF.text "-"
        , DF.dayOfMonthFixed
        , DF.text "T"
        , DF.hourMilitaryFixed
        , DF.text ":"
        , DF.minuteFixed
        ]
        Time.utc
        t


toWebData : RemoteData Json.Decode.Error a -> WebData a
toWebData remote =
    case remote of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure err ->
            Failure <|
                Http.BadPayload (Json.Decode.errorToString err)
                    { url = ""
                    , status = { code = -1, message = "" }
                    , headers = Dict.empty
                    , body = "Woops"
                    }

        Success val ->
            Success val
