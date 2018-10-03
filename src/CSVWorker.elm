port module Main exposing (main)

import Base64
import Csv
import CsvConvert exposing (parseCsvData)
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Platform
import Prayermate exposing (encodePrayerMate)
import Time


main : Platform.Program Flags () msg
main =
    Platform.worker
        { init = init
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = always Sub.none
        }


type alias Flags =
    { event : Json.Encode.Value, now : Int }


type alias Event =
    { path : String
    , httpMethod : String
    , body : String
    , isBase64Encoded : Bool
    }


decodeEvent : Json.Decode.Decoder Event
decodeEvent =
    Json.Decode.succeed Event
        |> Json.Decode.Pipeline.required "path" Json.Decode.string
        |> Json.Decode.Pipeline.required "httpMethod" Json.Decode.string
        |> Json.Decode.Pipeline.required "body" Json.Decode.string
        |> Json.Decode.Pipeline.required "isBase64Encoded" Json.Decode.bool


init : Flags -> ( (), Cmd msg )
init flags =
    let
        body =
            Json.Decode.decodeValue decodeEvent flags.event
                |> Result.mapError Json.Decode.errorToString
                |> Result.andThen getBody
    in
    case body of
        Ok b ->
            ( (), toJS ( "ok", encodePrayerMate <| parseCsvData (Time.millisToPosix flags.now) b ) )

        Err _ ->
            ( (), toJS ( "error", Json.Encode.object [] ) )


getBody : Event -> Result String String
getBody event =
    case event.isBase64Encoded of
        True ->
            Base64.decode event.body

        False ->
            Ok event.body


port toJS : ( String, Json.Encode.Value ) -> Cmd msg
