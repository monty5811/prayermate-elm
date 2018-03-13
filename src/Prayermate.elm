module Prayermate
    exposing
        ( Card
        , Category
        , Feed
        , PrayerMate
        , Subject
        , addEmptyCard
        , addNewCategory
        , addNewSubject
        , decodeCard
        , decodeCategory
        , decodeFeed
        , decodePrayerMate
        , decodeSubject
        , deleteCategory
        , deleteSubject
        , dropSubject
        , encodeCard
        , encodeCategory
        , encodeFeed
        , encodePrayerMate
        , encodeSubject
        , exportb64
        , maybeAddSubject
        , newCard
        , newCategory
        , newSubject
        , replaceCategory
        , replaceSubject
        , updateCategories
        , updateCategory
        , updateName
        , updateText
        )

import Base64
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Time
import Time.Format
import Util


type alias PrayerMate =
    { categories : List Category
    , feeds : List Feed
    , prayerMateAndroidVersion : Maybe String
    , prayerMateVersion : Maybe String
    }


decodePrayerMate : Json.Decode.Decoder PrayerMate
decodePrayerMate =
    Json.Decode.Pipeline.decode PrayerMate
        |> Json.Decode.Pipeline.required "Categories" (Json.Decode.list decodeCategory)
        |> Json.Decode.Pipeline.required "Feeds" (Json.Decode.list decodeFeed)
        |> Json.Decode.Pipeline.optional "PrayerMateAndroidVersion" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.optional "PrayerMateVersion" (Json.Decode.maybe Json.Decode.string) Nothing


encodePrayerMate : PrayerMate -> Json.Encode.Value
encodePrayerMate record =
    [ ( "Categories", Json.Encode.list <| List.map encodeCategory <| record.categories )
    , ( "Feeds", Json.Encode.list <| List.map encodeFeed <| record.feeds )
    ]
        |> maybeAddStringField "PrayerMateAndroidVersion" record.prayerMateAndroidVersion
        |> maybeAddStringField "PrayerMateVersion" record.prayerMateVersion
        |> Json.Encode.object


exportb64 : PrayerMate -> String
exportb64 pm =
    let
        data =
            pm
                |> encodePrayerMate
                |> Json.Encode.encode 0
                |> Base64.encode
    in
    "data:text/plain;base64," ++ data


type alias Category =
    { name : String
    , createdDate : String
    , itemsPerSession : Int
    , visible : Bool
    , pinned : Bool
    , manualSessionLimit : Maybe Int
    , syncID : Maybe String
    , subjects : List Subject
    }


decodeCategory : Json.Decode.Decoder Category
decodeCategory =
    Json.Decode.Pipeline.decode Category
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "createdDate" Json.Decode.string
        |> Json.Decode.Pipeline.required "itemsPerSession" Json.Decode.int
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "pinned" Json.Decode.bool
        |> Json.Decode.Pipeline.required "manualSessionLimit" (Json.Decode.maybe Json.Decode.int)
        |> Json.Decode.Pipeline.optional "syncID" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "subjects" (Json.Decode.list decodeSubject)


encodeCategory : Category -> Json.Encode.Value
encodeCategory record =
    [ ( "name", Json.Encode.string <| record.name )
    , ( "createdDate", Json.Encode.string <| record.createdDate )
    , ( "itemsPerSession", Json.Encode.int <| record.itemsPerSession )
    , ( "visible", Json.Encode.bool <| record.visible )
    , ( "pinned", Json.Encode.bool <| record.pinned )
    , ( "manualSessionLimit", encodeMaybe Json.Encode.int record.manualSessionLimit )
    , ( "subjects", Json.Encode.list <| List.map encodeSubject <| record.subjects )
    ]
        |> maybeAddStringField "syncID" record.syncID
        |> Json.Encode.object


newCategory : Time.Time -> String -> Category
newCategory currentTime name =
    { name = name
    , createdDate = Time.Format.format Util.dateTimeFormat currentTime
    , itemsPerSession = 1
    , visible = True
    , pinned = False
    , manualSessionLimit = Nothing
    , syncID = Nothing
    , subjects = []
    }


type alias Subject =
    { name : String
    , createdDate : String
    , lastPrayed : Maybe String
    , schedulingTimestamp : Maybe String
    , syncID : Maybe String
    , priorityLevel : Int
    , seenCount : Int
    , cards : List Card
    }


decodeSubject : Json.Decode.Decoder Subject
decodeSubject =
    Json.Decode.Pipeline.decode Subject
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "createdDate" Json.Decode.string
        |> Json.Decode.Pipeline.optional "lastPrayed" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.optional "schedulingTimestamp" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.optional "syncID" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "priorityLevel" Json.Decode.int
        |> Json.Decode.Pipeline.required "seenCount" Json.Decode.int
        |> Json.Decode.Pipeline.required "cards" (Json.Decode.list decodeCard)


encodeSubject : Subject -> Json.Encode.Value
encodeSubject record =
    [ ( "name", Json.Encode.string <| record.name )
    , ( "createdDate", Json.Encode.string <| record.createdDate )
    , ( "priorityLevel", Json.Encode.int <| record.priorityLevel )
    , ( "seenCount", Json.Encode.int <| record.seenCount )
    , ( "cards", Json.Encode.list <| List.map encodeCard <| record.cards )
    ]
        |> maybeAddStringField "schedulingTimestamp" record.schedulingTimestamp
        |> maybeAddStringField "lastPrayed" record.lastPrayed
        |> maybeAddStringField "syncID" record.syncID
        |> Json.Encode.object


newSubject : Time.Time -> String -> Maybe String -> Subject
newSubject currentTime name cardText =
    { name = name
    , createdDate = Time.Format.format Util.dateTimeFormat currentTime
    , lastPrayed = Nothing
    , schedulingTimestamp = Nothing
    , syncID = Nothing
    , priorityLevel = 0
    , seenCount = 0
    , cards = [ newCard currentTime cardText ]
    }


type alias Card =
    { text : Maybe String
    , archived : Bool
    , syncID : Maybe String
    , createdDate : String
    , dayOfTheWeekMask : Int
    , schedulingMode : Int
    , lastPrayed : Maybe String
    , seenCount : Int
    }


decodeCard : Json.Decode.Decoder Card
decodeCard =
    Json.Decode.Pipeline.decode Card
        |> Json.Decode.Pipeline.optional "text" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "archived" Json.Decode.bool
        |> Json.Decode.Pipeline.optional "syncID" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "createdDate" Json.Decode.string
        |> Json.Decode.Pipeline.required "dayOfTheWeekMask" Json.Decode.int
        |> Json.Decode.Pipeline.required "schedulingMode" Json.Decode.int
        |> Json.Decode.Pipeline.optional "lastPrayed" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "seenCount" Json.Decode.int


encodeCard : Card -> Json.Encode.Value
encodeCard record =
    [ ( "archived", Json.Encode.bool <| record.archived )
    , ( "createdDate", Json.Encode.string <| record.createdDate )
    , ( "dayOfTheWeekMask", Json.Encode.int <| record.dayOfTheWeekMask )
    , ( "schedulingMode", Json.Encode.int <| record.schedulingMode )
    , ( "seenCount", Json.Encode.int <| record.seenCount )
    ]
        |> maybeAddStringField "text" record.text
        |> maybeAddStringField "lastPrayed" record.lastPrayed
        |> maybeAddStringField "syncID" record.syncID
        |> Json.Encode.object


newCard : Time.Time -> Maybe String -> Card
newCard currentTime text =
    { text = text
    , archived = False
    , syncID = Nothing
    , createdDate = Time.Format.format Util.dateTimeFormat currentTime
    , dayOfTheWeekMask = 0
    , schedulingMode = 0
    , lastPrayed = Nothing
    , seenCount = 0
    }


type alias Feed =
    { description : Maybe String
    , name : String
    , subscribedAt : Maybe String
    , syncID : Maybe String
    , image : Maybe String
    , url : String
    , category : Maybe String
    }


decodeFeed : Json.Decode.Decoder Feed
decodeFeed =
    Json.Decode.Pipeline.decode Feed
        |> Json.Decode.Pipeline.optional "description" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.optional "subscribedAt" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.optional "syncID" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.optional "image" (Json.Decode.maybe Json.Decode.string) Nothing
        |> Json.Decode.Pipeline.required "url" Json.Decode.string
        |> Json.Decode.Pipeline.optional "category" (Json.Decode.maybe Json.Decode.string) Nothing


encodeFeed : Feed -> Json.Encode.Value
encodeFeed record =
    [ ( "name", Json.Encode.string <| record.name )
    , ( "url", Json.Encode.string <| record.url )
    ]
        |> maybeAddStringField "description" record.description
        |> maybeAddStringField "image" record.image
        |> maybeAddStringField "syncID" record.syncID
        |> maybeAddStringField "category" record.category
        |> maybeAddStringField "subscribedAt" record.subscribedAt
        |> Json.Encode.object


maybeAddStringField : String -> Maybe String -> List ( String, Json.Encode.Value ) -> List ( String, Json.Encode.Value )
maybeAddStringField name field l =
    case field of
        Nothing ->
            l

        Just str ->
            ( name, Json.Encode.string str ) :: l


encodeMaybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
encodeMaybe encoder ms =
    case ms of
        Nothing ->
            Json.Encode.null

        Just s ->
            encoder s



-- Helpers


updateCategories : List Category -> PrayerMate -> PrayerMate
updateCategories cats pm =
    { pm | categories = cats }


updateName : String -> { a | name : String } -> { a | name : String }
updateName new rec =
    { rec | name = new }


updateText : String -> { a | text : Maybe String } -> { a | text : Maybe String }
updateText new rec =
    { rec | text = Just new }


replaceSubject : Subject -> Subject -> Category -> Category
replaceSubject orig new category =
    { category | subjects = Util.replaceItem orig new category.subjects }


replaceCategory : Category -> Category -> PrayerMate -> PrayerMate
replaceCategory orig new pm =
    { pm | categories = Util.replaceItem orig new pm.categories }


maybeAddSubject : Subject -> Category -> Category -> Category
maybeAddSubject sub newCat currentCat =
    if newCat == currentCat then
        { currentCat | subjects = List.append currentCat.subjects [ sub ] }
    else
        currentCat


addNewSubject : Time.Time -> String -> Category -> Category
addNewSubject currentTime name cat =
    { cat | subjects = List.append cat.subjects [ newSubject currentTime name Nothing ] }


addEmptyCard : Time.Time -> Subject -> Category -> Category
addEmptyCard currentTime sub cat =
    { cat | subjects = List.map (addEmptyCardHelp currentTime sub) cat.subjects }


addEmptyCardHelp : Time.Time -> Subject -> Subject -> Subject
addEmptyCardHelp currentTime sub2change currentSub =
    if sub2change == currentSub then
        { currentSub | cards = newCard currentTime Nothing :: currentSub.cards }
    else
        currentSub


deleteSubject : Subject -> Category -> Category
deleteSubject sub category =
    { category | subjects = deleteSubjectHelp sub category.subjects }


deleteSubjectHelp : Subject -> List Subject -> List Subject
deleteSubjectHelp sub subjects =
    List.filter (\x -> x /= sub) subjects


dropSubject : Subject -> Category -> Category -> List Category -> List Category
dropSubject sub startCat destCat catList =
    if startCat == destCat then
        -- short circuit if start and end are the same
        catList
    else
        let
            updatedStartCat =
                deleteSubject sub startCat
        in
        catList
            |> List.map (maybeAddSubject sub destCat)
            |> Util.replaceItem startCat updatedStartCat


addNewCategory : Time.Time -> String -> PrayerMate -> PrayerMate
addNewCategory currentTime name pm =
    { pm | categories = newCategory currentTime name :: pm.categories }


deleteCategory : Category -> PrayerMate -> PrayerMate
deleteCategory cat pm =
    { pm | categories = List.filter (\x -> x /= cat) pm.categories }


updateCategory : Category -> Category -> List Category -> List Category
updateCategory origCat newCat categories =
    List.map (updateCategoryHelp origCat newCat) categories


updateCategoryHelp : Category -> Category -> Category -> Category
updateCategoryHelp origCat modCat iterCat =
    if origCat == iterCat then
        modCat
    else
        iterCat
