port module Ports exposing (..)

import Json.Encode


port fileSelected : String -> Cmd msg


port fileContentRead : ({ contents : String, filename : String, id : String } -> msg) -> Sub msg


port saveData : Json.Encode.Value -> Cmd msg
