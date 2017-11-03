module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)


type Msg
    = NoOp
    | Data DataMsg
    | Ui UiMsg
    | NewUuid


type DataMsg
    = AddScene
    | RenameFile FileId
    | SetWordTarget String


type UiMsg
    = CloseFile FileId
    | OpenFile FileId
    | RenamingFile (Maybe FileId)
    | SetActivity Activity
