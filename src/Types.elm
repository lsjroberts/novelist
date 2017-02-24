module Types exposing (..)

import Editor.Types


type alias Model =
    { route : Route
    , editor : Editor.Types.Model
    }


type Route
    = EditorRoute


type Msg
    = SetRoute Route
    | EditorMsg Editor.Types.Msg
