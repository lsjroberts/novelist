module Data.Decode exposing (decode)

import Data.File exposing (..)
import Data.Model exposing (Model)
import Dict exposing (Dict)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))


decode : (Dict FileId File -> List FileId -> Maybe FileId -> Model) -> String -> Model
decode createModel payload =
    case decodeString (decoder createModel) payload of
        Ok model ->
            Debug.log "decoded" model

        Err message ->
            Debug.crash message ()


decoder : (Dict FileId File -> List FileId -> Maybe FileId -> Model) -> Decoder Model
decoder createModel =
    succeed createModel
        |: (field "files" (dict fileDecoder))
        |: (field "openFiles" (list string))
        |: (field "activeFile" (maybe string))


fileDecoder : Decoder File
fileDecoder =
    map4 File
        (field "name" string)
        (field "parentId" (maybe string))
        (field "position" int)
        (field "meta"
            (oneOf
                [ sceneDecoder |> andThen (\s -> succeed (SceneFile s))
                , characterDecoder |> andThen (\c -> succeed (CharacterFile c))
                , folderDecoder
                ]
            )
        )


sceneDecoder : Decoder Scene
sceneDecoder =
    succeed Scene
        |: (field "synopsis" string)
        |: (field "status" sceneStatusDecoder)
        |: (field "tags" (list string))
        |: (field "characters" (dict sceneCharacterDecoder))
        |: (field "locations" (list string))
        |: (field "wordTarget" (maybe int))


sceneStatusDecoder : Decoder SceneStatus
sceneStatusDecoder =
    let
        stringToStatus s =
            case s of
                "Draft" ->
                    succeed Draft

                _ ->
                    fail ("Unrecognised scene status: " ++ s)
    in
        string |> andThen stringToStatus


sceneCharacterDecoder : Decoder SceneCharacter
sceneCharacterDecoder =
    map SceneCharacter
        (field "speaking" bool)


characterDecoder : Decoder Character
characterDecoder =
    succeed Character
        |: (field "aliases" (list string))


folderDecoder : Decoder FileType
folderDecoder =
    let
        stringToFolderType s =
            case s of
                "scene" ->
                    succeed (FolderFile SceneFolder)

                "character" ->
                    succeed (FolderFile CharacterFolder)

                "location" ->
                    succeed (FolderFile LocationFolder)

                _ ->
                    fail ("Unrecognised scene status: " ++ s)
    in
        string |> andThen stringToFolderType
