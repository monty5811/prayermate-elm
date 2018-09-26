module Models
    exposing
        ( CategoryStep(..)
        , Model
        , SchedulerStep(..)
        , Step(..)
        , SubjectStep(..)
        , decodePrayerMate2WebData
        , initialCategoriesStep
        , initialModel
        )

import Browser.Navigation as Navigation
import Date exposing (Date)
import DatePicker
import DragDrop
import Editing exposing (Editing(..))
import Json.Decode
import Prayermate exposing (Card, Category, PrayerMate, Subject, decodePrayerMate)
import RemoteData exposing (RemoteData(..), WebData)
import Time
import Util


type alias Model =
    { pm : WebData PrayerMate
    , originalPm : WebData PrayerMate
    , cachedData : WebData PrayerMate
    , step : Step
    , currentTime : Time.Posix
    , showAbout : Bool
    , about : WebData String
    , navKey : Navigation.Key
    }


initialModel : Navigation.Key -> { cachedData : String } -> Step -> Model
initialModel key flags step =
    { pm = NotAsked
    , originalPm = NotAsked
    , cachedData = decodePrayerMate2WebData flags.cachedData
    , step = step
    , currentTime = Time.millisToPosix 0
    , showAbout = False
    , about = NotAsked
    , navKey = key
    }


type Step
    = LandingPage
    | CategoriesList CategoryStep
    | SubjectsList (Editing Category) SubjectStep
    | CsvConvert String (Maybe PrayerMate)
    | Scheduler SchedulerStep


type CategoryStep
    = ViewCats (DragDrop.Model Category Subject)
    | CreateCat String
    | EditCat (Editing Category)
    | DeleteCat Category
    | EditSubject (DragDrop.Model Category Subject) Category (Editing Subject)


type SchedulerStep
    = MainView
    | DatePickerView DatePicker.DatePicker ( Category, Subject, Card ) (List Date)
    | DayOfMonthPickerView ( Category, Subject, Card ) (List Int)


initialCategoriesStep : Step
initialCategoriesStep =
    CategoriesList (ViewCats DragDrop.init)


type SubjectStep
    = ViewSubjects
    | CreateSubject String
    | EditSubjectName (Editing Subject)
    | DeleteSubject Subject
    | MoveSubject Subject
    | EditSubjectCard (Editing Subject) (Editing Card)


decodePrayerMate2WebData : String -> WebData PrayerMate
decodePrayerMate2WebData str =
    str
        |> Json.Decode.decodeString decodePrayerMate
        |> RemoteData.fromResult
        |> Util.toWebData
