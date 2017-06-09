module Data.File exposing (File, FileType(..))


type alias File =
    { id : Int
    , parent : Maybe Int
    , type_ : FileType
    , name : String
    , expanded : Bool
    }


type FileType
    = SceneFile
