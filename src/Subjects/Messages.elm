module Subjects.Messages exposing (Msg(..))

import Prayermate exposing (Card, Category, Subject)


type Msg
    = EditStart Subject
    | EditUpdateName String
    | EditSave
    | EditCancel
    | DeleteStart Subject
    | DeleteCancel
    | DeleteConfirm
    | CloseList
    | MoveStart Subject
    | MoveCancel
    | MoveComplete Category
    | CreateStart
    | CreateUpdateName String
    | CreateSave
    | CreateCancel
    | EditCardStart Subject Card
    | EditCardUpdateText String
    | EditCardSave
    | EditCardCancel
    | CreateEmptyCard Subject
    | NoOp
