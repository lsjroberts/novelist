module Data.Search exposing (..)

import Data.File exposing (FileId)
import Dict exposing (Dict)
import Json.Decode exposing (..)


type alias FileSearch =
    { term : String
    , result : SearchResult
    }


type alias SearchResult =
    { contents : Maybe (Dict FileId (List String)) }


decodeSearchContents : String -> Dict FileId (List String)
decodeSearchContents payload =
    case decodeString searchContentsDecoder payload of
        Ok searchContents ->
            searchContents

        Err message ->
            Debug.crash message ()


searchContentsDecoder : Decoder (Dict FileId (List String))
searchContentsDecoder =
    dict (list string)
