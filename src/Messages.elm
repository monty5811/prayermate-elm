module Messages exposing (..)

import Categories.Messages as Cat
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
    | FileRead { contents : String, filename : String }
    | CategoryMsg Cat.Msg
    | SubjectMsg Subj.Msg
    | ReceiveTime Time.Time
