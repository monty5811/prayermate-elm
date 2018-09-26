module TestSerialisation exposing (serialisation)

import Expect
import Fixtures
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Json.Encode as Encode
import Prayermate
    exposing
        ( Card
        , Category
        , DayOfWeekMask
        , Feed
        , PrayerMate
        , SchedulingMode(..)
        , Subject
        , WeekDay(..)
        , decodeCard
        , decodeCategory
        , decodeFeed
        , decodePrayerMate
        , decodeSubject
        , encodeCard
        , encodeCategory
        , encodeFeed
        , encodePrayerMate
        , encodeSubject
        , intToDayOfTheWeekMask
        )
import Test exposing (Test, describe, fuzz, test)


category : Fuzzer Category
category =
    Fuzz.map Category Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap (Fuzz.maybe Fuzz.int)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.list subject)


subject : Fuzzer Subject
subject =
    Fuzz.map Subject Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap (Fuzz.list card)


card : Fuzzer Card
card =
    Fuzz.map Card (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap schedule


schedule : Fuzzer SchedulingMode
schedule =
    Fuzz.oneOf
        [ Fuzz.constant Default
        , Fuzz.constant <| DayOfWeek [ Monday, Sunday ]
        , Fuzz.constant <| Date "date1,date2"
        , Fuzz.constant <| DayOfMonth [ 1, 2, 3 ]
        ]


feed : Fuzzer Feed
feed =
    Fuzz.map Feed (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)


prayermate : Fuzzer PrayerMate
prayermate =
    Fuzz.map PrayerMate
        (Fuzz.list category)
        |> Fuzz.andMap (Fuzz.list feed)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)
        |> Fuzz.andMap (Fuzz.maybe Fuzz.string)


serialisation : Test
serialisation =
    describe "test serialisation"
        [ describe "real test data"
            [ test "demo data (android)" <|
                \_ ->
                    roundTripString encodePrayerMate decodePrayerMate Fixtures.test_data
            , test "test data (iOS)" <|
                \_ ->
                    roundTripString encodePrayerMate decodePrayerMate Fixtures.test_data_ios
            , test "test scheduling data" <|
                \_ ->
                    roundTripString encodePrayerMate decodePrayerMate Fixtures.test_schedules
            ]
        , describe "test day of the week mask" <|
            List.map dayOfTheWeekMaskTest
                [ ( 1, [ Sunday ] )
                , ( 2, [ Monday ] )
                , ( 4, [ Tuesday ] )
                , ( 8, [ Wednesday ] )
                , ( 16, [ Thursday ] )
                , ( 32, [ Friday ] )
                , ( 64, [ Saturday ] )
                , ( 126, [ Saturday, Friday, Thursday, Wednesday, Tuesday, Monday ] )
                , ( 33, [ Friday, Sunday ] )
                ]
        , describe "fuzz round trip"
            [ fuzz feed "Feed" <| roundTrip encodeFeed decodeFeed
            , fuzz subject "Subject" <| roundTrip encodeSubject decodeSubject
            , fuzz card "Card" <| roundTrip encodeCard decodeCard
            , fuzz category "Category" <| roundTrip encodeCategory decodeCategory

            --, fuzz prayermate "prayermate" <| roundTrip encodePrayerMate decodePrayerMate
            ]
        ]


roundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expect.Expectation
roundTrip enc dec model =
    model
        |> enc
        |> Decode.decodeValue dec
        |> Expect.equal (Ok model)


roundTripString : (a -> Encode.Value) -> Decode.Decoder a -> String -> Expect.Expectation
roundTripString enc dec str =
    let
        model =
            Decode.decodeString dec str
    in
    case model of
        Ok val ->
            val
                |> enc
                |> Decode.decodeValue dec
                |> Expect.equal (Ok val)

        Err err ->
            Expect.fail <| Decode.errorToString err


dayOfTheWeekMaskTest : ( Int, DayOfWeekMask ) -> Test
dayOfTheWeekMaskTest ( mask, days ) =
    test (String.fromInt mask) <|
        \_ ->
            Expect.equal (intToDayOfTheWeekMask mask) days
