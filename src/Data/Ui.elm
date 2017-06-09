module Data.Ui exposing (Ui, ViewType(..))

import Data.File exposing (File)


type alias Ui r =
    { r
        | files : List File
        , editingFileName : Maybe Int
        , activeFile : Maybe Int
        , activeView : ViewType
    }


type ViewType
    = EditorView
    | SettingsView
