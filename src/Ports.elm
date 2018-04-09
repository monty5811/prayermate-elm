port module Ports exposing (dropboxLinkRead, fileContentRead, fileSelected, openDropboxChooser, saveData)

import Json.Encode


port fileSelected : String -> Cmd msg


port fileContentRead : ({ contents : String, filename : String, id : String } -> msg) -> Sub msg


port saveData : Json.Encode.Value -> Cmd msg


port openDropboxChooser : () -> Cmd msg


port dropboxLinkRead : (Json.Encode.Value -> msg) -> Sub msg
