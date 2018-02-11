module Route exposing (route)

import Models exposing (Step(CsvConvert, LandingPage))
import UrlParser as Url exposing (s, top)


route : Url.Parser (Step -> a) a
route =
    Url.oneOf
        [ Url.map LandingPage top
        , Url.map (CsvConvert "" Nothing) (s "csv")
        ]
