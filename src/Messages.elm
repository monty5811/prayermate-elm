module Messages exposing (Msg(..))

import Date exposing (Date)
import DatePicker
import DragDrop
import Json.Encode
import Prayermate exposing (Card, Category, PrayerMate, Subject, WeekDay)
import RemoteData exposing (WebData)
import Time
import Url


type Msg
    = NoOp
    | ToggleAbout
    | ReceiveAbout (WebData String)
    | ReceiveTime Time.Posix
    | UrlChange Url.Url
    | LoadDemoData
    | LoadDropBoxData
    | LoadPreviousSession
    | ReceivePrayerMate (WebData PrayerMate)
    | FileSelected String
    | FileRead { contents : String, filename : String, id : String }
    | ReceiveDropboxLink Json.Encode.Value
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
    | CatEditSubjectStart Category Subject
    | CatEditSubjectCancel
    | CatEditSubjectUpdateName String
    | CatEditSubjectSave
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
    | GoToScheduler
    | CloseScheduler
    | ToggleWeekday WeekDay Category Subject Card
    | SchedOpenDatePickerView ( Category, Subject, Card )
    | SchedCancelDatePickerView
    | SchedSaveDateChange String
    | SchedOpenDoMPickerView ( Category, Subject, Card )
    | SchedCancelDoMPickerView
    | SchedSaveDoMChange
    | SchedDoMToggleDay Int
    | SetDatePicker DatePicker.Msg
    | SchedDatePickerDeleteDate Date
