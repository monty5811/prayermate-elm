module Models exposing (..)

import DragDrop
import Editing exposing (..)
import PrayermateModels exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Time
import Util


type alias Model =
    { pm : WebData PrayerMate
    , originalPm : WebData PrayerMate
    , cachedData : WebData PrayerMate
    , step : Step
    , currentTime : Time.Time
    }


initialModel : { cachedData : String } -> Model
initialModel flags =
    { pm = NotAsked
    , originalPm = NotAsked
    , cachedData = Util.decodePrayerMate2WebData flags.cachedData
    , step = LandingPage
    , currentTime = 0
    }


type Step
    = LandingPage
    | CategoriesList CategoryStep
    | SubjectsList (Editing Category) SubjectStep


type CategoryStep
    = ViewCats (DragDrop.Model Category Subject)
    | CreateCat String
    | EditCat (Editing Category)
    | DeleteCat Category


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
