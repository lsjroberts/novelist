module Data.File exposing (..)

import Dict exposing (Dict)


type alias FileId =
    String


type alias File =
    { name : String
    , fileType : FileType
    }


type FileType
    = SceneFile Scene
    | CharacterFile Character
    | LocationFile


type alias Scene =
    { synopsis : String
    , status : SceneStatus
    , tags : List String
    , position : Int
    , characters : Dict FileId SceneCharacter
    , locations : List FileId
    , wordTarget : Maybe Int
    }


type SceneStatus
    = Draft


type alias SceneCharacter =
    { speaking : Bool }


type alias Character =
    { aliases : List String }
