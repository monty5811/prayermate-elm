module Messages exposing (..)

import Categories.Messages as Cat
import CsvConvert
import Navigation exposing (Location)
import PrayermateModels exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Subjects.Messages as Subj
import Time


type Msg
    = NoOp
    | LoadDemoData
    | LoadPreviousSession
    | ReceivePrayerMate (WebData PrayerMate)
    | FileSelected String
    | FileRead { contents : String, filename : String, id : String }
    | CategoryMsg Cat.Msg
    | SubjectMsg Subj.Msg
    | CsvMsg CsvConvert.Msg
    | ReceiveTime Time.Time
    | UrlChange Location
