module Data.File exposing (..)

import Dict exposing (Dict)
import Octicons as Icon


type alias FileId =
    String


type alias File =
    { name : String
    , parentId : Maybe FileId
    , position : Int
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


scenes : Dict FileId File -> Dict FileId File
scenes =
    filterByType
        (\fileType ->
            case fileType of
                SceneFile a ->
                    True

                FolderFile SceneFolder ->
                    True

                _ ->
                    False
        )


characters : Dict FileId File -> Dict FileId File
characters =
    filterByType
        (\fileType ->
            case fileType of
                CharacterFile a ->
                    True

                FolderFile CharacterFolder ->
                    True

                _ ->
                    False
        )


locations : Dict FileId File -> Dict FileId File
locations =
    filterByType
        (\fileType ->
            case fileType of
                LocationFile ->
                    True

                FolderFile LocationFolder ->
                    True

                _ ->
                    False
        )


filterByType : (FileType -> Bool) -> Dict FileId File -> Dict FileId File
filterByType fn =
    Dict.filter (\fileId file -> fn file.fileType)


except : Dict FileId File -> FileId -> Dict FileId File
except files fileId =
    Dict.filter (\id f -> not (id == fileId)) files


children : Maybe FileId -> Dict FileId File -> Dict FileId File
children maybeParent =
    Dict.filter (\fileId file -> file.parentId == maybeParent)


nextPosition : Dict FileId File -> Int
nextPosition files =
    files
        |> Dict.values
        |> List.map .position
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1
