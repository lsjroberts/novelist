module Editor.Decode exposing (..)

import Debug
import Json.Encode
import Json.Decode
    exposing
        ( Decoder
        , decodeString
        , string
        , list
        , nullable
        , lazy
        , map
        , map2
        , map7
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


fileChildren : Decoder FileChildren
fileChildren =
    -- This definition must be above `metaData`
    -- @see https://github.com/elm-lang/elm-compiler/issues/1560
    lazy <| \_ -> map FileChildren (list file)


metaData : Decoder Model
metaData =
    map7 Model
        (field "name" string)
        (field "author" string)
        (field "manuscript" (list file))
        (field "plan" (list file))
        (field "notes" (list file))
        (field "open" (list file))
        (field "active" (nullable filePath))


file : Decoder File
file =
    map2 File
        (field "path" filePath)
        (field "children" fileChildren)


filePath : Decoder FilePath
filePath =
    string
