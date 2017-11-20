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
    | OpenProjectSubscription String
    | UpdateFileSubscription String
    | SearchSubscription String
    | NewUuid


type DataMsg
    = AddCharacter (Maybe FileId)
    | AddCharacterFolder
    | AddLocation (Maybe FileId)
    | AddLocationFolder
    | AddScene (Maybe FileId)
    | AddSceneFolder
    | RenameFile FileId String
    | SetWordTarget String


type UiMsg
    = CloseFile FileId
    | ClosePalette
    | Combos Keyboard.Combo.Msg
    | FocusPaletteInput (Result Dom.Error ())
    | OpenFile FileId
    | Search String
    | SearchName String
    | SetActivity Activity
    | SetPalette PaletteStatus
