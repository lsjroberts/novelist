module Editor.Types exposing (..)

import Json.Encode
import Scene.Types


type alias Model =
    { name : String
    , author : String
    , manuscript : List File
    , plan : List File
    , notes : List File
    , open : List File
    , active : Maybe FilePath
    }


empty =
    { name = "Title"
    , author = "Author"
    , manuscript = []
    , plan = []
    , notes = []
    , open = []
    , active = Nothing
    }


type alias FilePath =
    String


type alias File =
    { path : FilePath
    , children : FileChildren
    }


type FileChildren
    = FileChildren (List File)


type Msg
    = ShowOpenDialog
    | OpenProject String
