module Categories.Messages exposing (Msg(..))

import DragDrop
import PrayermateModels exposing (Category, Subject)


type Msg
    = Open Category
    | EditStart Category
    | EditUpdateName String
    | EditSave
    | EditCancel
    | DeleteStart Category
    | DeleteCancel
    | DeleteConfirm
    | CreateStart
    | CreateUpdateName String
    | CreateSave
    | CreateCancel
    | NoOp
    | DnD (DragDrop.Msg Category Subject)
