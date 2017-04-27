module Editor.Decode exposing (..)

import Debug
import Json.Encode
import Json.Decode
    exposing
        ( Decoder
        , decodeString
        , andThen
        , succeed
        , string
        , int
        , list
        , nullable
        , lazy
        , map
        , map4
        , map6
        , field
        )
import Editor.Types exposing (..)


decodeMetaData : String -> Model
decodeMetaData payload =
    case decodeString metaData payload of
        Ok model ->
            Debug.log "decodedModel" model

        Err message ->
            Debug.crash message ()



-- fileChildren : Decoder FileChildren
-- fileChildren =
--     -- This definition must be above `metaData`
--     -- @see https://github.com/elm-lang/elm-compiler/issues/1560
--     lazy <| \_ -> map FileChildren (list file)


metaData : Decoder Model
metaData =
    map6 Model
        (field "name" string)
        (field "author" string)
        (field "files" (list file))
        (field "open" (list file))
        (field "active" (nullable int))
        (field "lastFileId" int)


file : Decoder File
file =
    map4 File
        (field "id" int)
        (field "fileType" fileType)
        (field "parentId" int)
        (field "name" string)


fileType : Decoder FileType
fileType =
    string |> andThen stringToFileType


stringToFileType : String -> Decoder FileType
stringToFileType ft =
    case ft of
        "scene" ->
            succeed Scene

        _ ->
            succeed None
