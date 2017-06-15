module Data.Ui exposing (Ui, ViewType(..), updateFile)

import Data.File exposing (File)
import List.Extra
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


updateFile : Int -> (File -> File) -> Ui r -> Ui r
updateFile id fn ui =
    { ui
        | files =
            ui.files
                |> List.Extra.updateIf (\file -> file.id == id) fn
    }
