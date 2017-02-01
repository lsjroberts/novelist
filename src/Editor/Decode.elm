module Editor.Decode exposing (..)

import Debug
import Json.Encode
import Json.Decode exposing (Decoder, decodeString, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Editor.Types exposing (..)


decodeMetaData : String -> Model
decodeMetaData payload =
    case decodeString decoderMetaData payload of
        Ok model ->
            Debug.log "decodedModel" model

        Err message ->
            Debug.crash message ()


decoderMetaData : Decoder Model
decoderMetaData =
    decode Model
        |> required "name" string
        |> required "author" string
        |> required "manuscript" decoderFileIds
        |> required "plan" decoderFileIds
        |> required "notes" decoderFileIds
        |> required "open" decoderFileIds
        |> required "active" (nullable decoderFileId)


decoderFileIds : Decoder (List FileId)
decoderFileIds =
    list decoderFileId


decoderFileId : Decoder FileId
decoderFileId =
    string
