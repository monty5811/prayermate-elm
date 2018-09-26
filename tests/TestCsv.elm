module TestCsv exposing (csv)

import CsvConvert exposing (parseCsvData)
import Expect
import Fixtures
import Json.Decode as Decode
import Prayermate exposing (Card, Category, PrayerMate, Subject, decodePrayerMate)
import Test exposing (Test, describe, test)
import Time


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
csvMatchesJson csvStr json =
    let
        jsonModelResult =
            Decode.decodeString decodePrayerMate json

        maybeCsvModel =
            parseCsvData (Time.millisToPosix 0) csvStr
    in
    case ( maybeCsvModel, jsonModelResult ) of
        ( csvModel, Ok jsonModel ) ->
            Expect.equal (simplifyPm csvModel) (simplifyPm jsonModel)

        ( _, Err err ) ->
            Expect.fail ("Json Parsing failed: " ++ Decode.errorToString err)


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
