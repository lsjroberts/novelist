module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)
import Data.Palette exposing (PaletteStatus)


type Msg
    = NoOp
    | Data DataMsg
    | Ui UiMsg
    | NewUuid


type DataMsg
    = AddScene
    | RenameFile FileId String
    | SetWordTarget String


type UiMsg
    = CloseFile FileId
    | ClosePalette
    | OpenFile FileId
    | OpenPalette PaletteStatus
    | SetActivity Activity
    | SearchName String
