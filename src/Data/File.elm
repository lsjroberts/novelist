module Data.File exposing (..)

import Dict exposing (Dict)


type alias FileId =
    Int


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
    , status : String
    , tags : List String
    , characters : Dict FileId SceneCharacter
    , locations : List FileId
    , wordTarget : Maybe Int
    }


type alias SceneCharacter =
    { speaking : Bool }


type alias Character =
    { aliases : List String }
