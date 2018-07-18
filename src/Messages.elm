module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)
import Data.Palette exposing (PaletteStatus)
import Html5.DragDrop as DragDrop
import Dom
import Keyboard.Combo


type Msg
    = NoOp
    | Data DataMsg
    | Ui UiMsg
    | Prose ProseMsg
    | OpenProjectSubscription String
    | UpdateFileSubscription String
    | SearchSubscription String
    | NewUuid
    | DragDropFiles (DragDrop.Msg FileId FileId)


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


type ProseMsg
    = SetActiveParagraph Int
