module Route exposing (route)

import Models exposing (Step(..))
import Url.Parser exposing (Parser, map, oneOf, s, top)


route : Parser (Step -> a) a
route =
    oneOf
        [ map LandingPage top
        , map (CsvConvert "" Nothing) (s "csv")
        ]
