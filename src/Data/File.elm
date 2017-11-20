module Data.File exposing (..)

import Dict exposing (Dict)
import Maybe.Extra
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


isFolder : FileId -> Dict FileId File -> Bool
isFolder fileId files =
    files
        |> Dict.get fileId
        |> Maybe.Extra.unwrap False
            (\file ->
                case file.fileType of
                    FolderFile _ ->
                        True

                    _ ->
                        False
            )


except : Dict FileId File -> FileId -> Dict FileId File
except files fileId =
    Dict.filter (\id f -> not (id == fileId)) files


children : Maybe FileId -> Dict FileId File -> Dict FileId File
children maybeParent =
    Dict.filter (\fileId file -> file.parentId == maybeParent)


setParent : FileId -> FileId -> Dict FileId File -> Dict FileId File
setParent parentId fileId =
    Dict.update fileId
        (\maybeFile ->
            case maybeFile of
                Just file ->
                    Just { file | parentId = Just parentId }

                Nothing ->
                    Nothing
        )


placeAfter : FileId -> FileId -> Dict FileId File -> Dict FileId File
placeAfter afterId fileId files =
    let
        afterFile =
            Dict.get afterId files

        position =
            afterFile |> Maybe.Extra.unwrap 0 (\file -> file.position + 1)

        maybeFileAtPosition =
            files
                |> Dict.filter (\fileId file -> file.position == position)
                |> Dict.keys
                |> List.head

        parentId =
            afterFile |> Maybe.Extra.unwrap Nothing (\file -> file.parentId)

        filesWithUpdatedPosition =
            files
                |> Dict.update fileId
                    (Maybe.Extra.unwrap Nothing
                        (\file ->
                            Just { file | position = position, parentId = parentId }
                        )
                    )
    in
        case maybeFileAtPosition of
            Nothing ->
                filesWithUpdatedPosition

            Just fileAtPosition ->
                if fileId == fileAtPosition then
                    filesWithUpdatedPosition
                else
                    filesWithUpdatedPosition |> placeAfter fileId fileAtPosition


nextPosition : Dict FileId File -> Int
nextPosition files =
    files
        |> Dict.values
        |> List.map .position
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1
