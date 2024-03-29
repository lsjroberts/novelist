module Data.Encode exposing (encode)

import Data.File exposing (..)
import Data.Model exposing (Model)
import Dict exposing (Dict)
import Json.Encode exposing (..)


encode : Model -> Value
encode model =
    object
        [ ( "version", int 1 )
        , ( "files", filesEncoder model.files )
        , ( "openFiles", list (List.map string model.openFiles) )
        , ( "activeFile", maybeStringEncoder model.activeFile )
        ]


filesEncoder : Dict FileId File -> Value
filesEncoder files =
    dictEncoder fileEncoder files


fileEncoder : File -> Value
fileEncoder file =
    let
        ( type_, meta ) =
            case file.fileType of
                FolderFile folderType ->
                    ( "folder"
                    , case folderType of
                        SceneFolder ->
                            string "scene"

                        CharacterFolder ->
                            string "character"

                        LocationFolder ->
                            string "location"
                    )

                SceneFile scene ->
                    ( "scene", sceneEncoder scene )

                CharacterFile character ->
                    ( "character", characterEncoder character )

                LocationFile ->
                    ( "location", null )
    in
        object
            [ ( "name", string file.name )
            , ( "parentId", maybeStringEncoder file.parentId )
            , ( "position", int file.position )
            , ( "type", string type_ )
            , ( "meta", meta )
            ]


sceneEncoder : Scene -> Value
sceneEncoder scene =
    object
        [ ( "synopsis", string scene.synopsis )
        , ( "status", string (toString scene.status) )
        , ( "tags", list [] )
        , ( "characters", object [] )
        , ( "locations", list [] )
        , ( "wordTarget", maybeIntEncoder scene.wordTarget )
        ]


characterEncoder : Character -> Value
characterEncoder character =
    object
        [ ( "aliases", list [] ) ]


dictEncoder : (a -> Value) -> Dict String a -> Value
dictEncoder enc dict =
    Dict.toList dict
        |> List.map (\( k, v ) -> ( k, enc v ))
        |> object


maybeStringEncoder : Maybe String -> Value
maybeStringEncoder maybeString =
    case maybeString of
        Just s ->
            string s

        Nothing ->
            null


maybeIntEncoder : Maybe Int -> Value
maybeIntEncoder maybeInt =
    case maybeInt of
        Just i ->
            int i

        Nothing ->
            null
