module TestCsv exposing (csv)

import CsvConvert exposing (parseCsvData)
import Expect
import Fixtures
import Json.Decode as Decode
import PrayermateModels exposing (..)
import Test exposing (Test, describe, test)


csv : Test
csv =
    describe "test csv import"
        [ describe "real test data"
            [ test "demo data (android)" <|
                \_ ->
                    csvMatchesJson Fixtures.test_data_csv Fixtures.test_data
            , test "test data (iOS)" <|
                \_ ->
                    csvMatchesJson Fixtures.test_data_ios_csv Fixtures.test_data_ios
            ]
        ]


csvMatchesJson : String -> String -> Expect.Expectation
csvMatchesJson csv json =
    let
        jsonModelResult =
            Decode.decodeString decodePrayerMate json

        maybeCsvModelResult =
            parseCsvData 0 csv
    in
    case ( maybeCsvModelResult, jsonModelResult ) of
        ( Ok csvModel, Ok jsonModel ) ->
            Expect.equal (simplifyPm csvModel) (simplifyPm jsonModel)

        ( Err err, _ ) ->
            Expect.fail ("Csv Parsing failed: " ++ String.join ", " err)

        ( _, Err err ) ->
            Expect.fail ("Json Parsing failed: " ++ err)


{-| Remove extra information from the `PrayerMate` type, sort and remove empty lists as teh csv import will ignore them
-}
simplifyPm : PrayerMate -> SimplePm
simplifyPm pm =
    { categories =
        List.map simplifyCategory pm.categories
            |> List.filter (.subjects >> List.isEmpty >> not)
            |> List.sortBy .name
    }


simplifyCategory : Category -> SimpleCategory
simplifyCategory cat =
    { name = cat.name
    , subjects =
        List.map simplifySubject cat.subjects
            |> List.sortBy .name
    }


simplifySubject : Subject -> SimpleSubject
simplifySubject sub =
    { name = sub.name
    , cards =
        List.map simplifyCard sub.cards
            |> List.sortBy (.text >> Maybe.withDefault "")
    }


simplifyCard : Card -> SimpleCard
simplifyCard card =
    { text = card.text }


type alias SimplePm =
    { categories : List SimpleCategory }


type alias SimpleCategory =
    { subjects : List SimpleSubject
    , name : String
    }


type alias SimpleSubject =
    { cards : List SimpleCard, name : String }


type alias SimpleCard =
    { text : Maybe String }
