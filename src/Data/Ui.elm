module Data.Ui exposing (Ui, ViewType(..))

import Data.File exposing (File)
import Time exposing (Time)


type alias Ui r =
    { r
        | files : List File
        , editingFileName : Maybe Int
        , activeFile : Maybe Int
        , activeView : ViewType
        , time : Time
    }


type ViewType
    = EditorView
    | SettingsView
