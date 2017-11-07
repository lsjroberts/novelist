module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)
import Data.Palette exposing (PaletteStatus)
import Dom
import Keyboard.Combo


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
    | Combos Keyboard.Combo.Msg
    | FocusPaletteInput (Result Dom.Error ())
    | OpenFile FileId
    | SetActivity Activity
    | SetPalette PaletteStatus
    | SearchName String
