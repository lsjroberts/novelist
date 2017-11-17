module Data.File exposing (..)

import Dict exposing (Dict)
import Octicons as Icon


type alias FileId =
    String


type alias File =
    { name : String
    , parentId : Maybe FileId
    , fileType : FileType
    }


type FileType
    = FolderFile FolderType
    | SceneFile Scene
    | CharacterFile Character
    | LocationFile


type FolderType
    = SceneFolder
    | CharacterFolder
    | LocationFolder


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


fileIcon fileType =
    case fileType of
        FolderFile _ ->
            Icon.fileDirectory

        CharacterFile _ ->
            Icon.gistSecret

        SceneFile _ ->
            Icon.file

        LocationFile ->
            Icon.globe


characters : Dict FileId File -> Dict FileId File
characters files =
    Dict.filter
        (\fileId file ->
            case file.fileType of
                CharacterFile a ->
                    True

                _ ->
                    False
        )
        files


except : Dict FileId File -> FileId -> Dict FileId File
except files fileId =
    Dict.filter (\id f -> not (id == fileId)) files
