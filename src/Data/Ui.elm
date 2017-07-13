module Data.Ui exposing (Ui, ViewType(..), Selection, updateFile)

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
        , selection : Maybe Selection
    }


type ViewType
    = EditorView
    | SettingsView


type alias Selection =
    { start : Int
    , end : Int
    , paragraphIndex : Int
    }


updateFile : Int -> (File -> File) -> Ui r -> Ui r
updateFile id fn ui =
    { ui
        | files =
            ui.files
                |> List.Extra.updateIf (\file -> file.id == id) fn
    }
