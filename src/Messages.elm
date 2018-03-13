module Messages exposing (Msg(..))

import DragDrop
import Navigation exposing (Location)
import Prayermate exposing (Card, Category, PrayerMate, Subject)
import RemoteData exposing (WebData)
import Time


type Msg
    = NoOp
    | ToggleAbout
    | ReceiveAbout (WebData String)
    | ReceiveTime Time.Time
    | UrlChange Location
    | LoadDemoData
    | LoadPreviousSession
    | ReceivePrayerMate (WebData PrayerMate)
    | FileSelected String
    | FileRead { contents : String, filename : String, id : String }
    | CatOpen Category
    | CatEditStart Category
    | CatEditUpdateName String
    | CatEditSave
    | CatEditCancel
    | CatDeleteStart Category
    | CatDeleteCancel
    | CatDeleteConfirm
    | CatCreateStart
    | CatCreateUpdateName String
    | CatCreateSave
    | CatCreateCancel
    | DnD (DragDrop.Msg Category Subject)
    | SubEditStart Subject
    | SubEditUpdateName String
    | SubEditSave
    | SubEditCancel
    | SubDeleteStart Subject
    | SubDeleteCancel
    | SubDeleteConfirm
    | CloseList
    | SubMoveStart Subject
    | SubMoveCancel
    | SubMoveComplete Category
    | SubCreateStart
    | SubCreateUpdateName String
    | SubCreateSave
    | SubCreateCancel
    | EditCardStart Subject Card
    | EditCardUpdateText String
    | EditCardSave
    | EditCardCancel
    | CreateEmptyCard Subject
    | CSVInputChanged String
    | CSVFileSelected String
    | CSVGoToKanban
