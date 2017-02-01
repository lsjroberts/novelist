module Editor.Types exposing (..)

import Json.Encode
import Scene.Types


type alias Model =
    { name : String
    , author : String
    , manuscript : List FileId
    , plan : List FileId
    , notes : List FileId
    , open : List FileId
    , active : Maybe FileId
    }


type alias FileId =
    String


type alias File =
    { path : String
    , contents : Maybe String
    }


type Msg
    = ShowOpenDialog
    | OpenProject String
