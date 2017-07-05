module Data.Decode exposing (..)

import Date exposing (Date)
import Json.Decode as Json
import Json.Decode.Extra exposing ((|:))
import Data.File exposing (File, FileType(..))
import Data.Model exposing (..)
import Data.Novel exposing (Novel)
import Data.Scene exposing (Scene)
import Data.Token
    exposing
        ( Token
        , TokenChildren(..)
        , TokenType(..)
        , getClosingTag
        , getOpeningTag
        , getShowTags
        , getTokenChildren
        , getTokenValue
        , markdownToTokens
        , tokensToPlainText
        )
import Data.Ui
    exposing
        ( Ui
        , ViewType(..)
        )


childrenContentDecoder : Json.Decoder String
childrenContentDecoder =
    Json.at [ "target", "childNodes" ] (Json.keyValuePairs textContentDecoder)
        |> Json.map
            (\nodes ->
                nodes
                    |> List.filterMap
                        (\( key, text ) ->
                            case String.toInt key of
                                Err msg ->
                                    Nothing

                                Ok value ->
                                    Just text
                        )
                    |> List.foldl (\acc x -> acc ++ "\n" ++ x) ""
            )


textContentDecoder : Json.Decoder String
textContentDecoder =
    Json.oneOf [ Json.field "textContent" Json.string, Json.succeed "nope" ]


tokenChildrenDecoder : Json.Decoder TokenChildren
tokenChildrenDecoder =
    -- This definition must be above `decodeProject`
    -- @see https://github.com/elm-lang/elm-compiler/issues/1560
    Json.lazy <| \_ -> Json.map TokenChildren (Json.list tokenDecoder)


decodeProject : String -> Model
decodeProject payload =
    case Json.decodeString modelDecoder payload of
        Ok model ->
            Debug.log "decodedModel" model

        Err message ->
            Debug.crash message ()


modelDecoder : Json.Decoder Model
modelDecoder =
    Json.succeed createModel
        |: (Json.field "files" (Json.list fileDecoder))
        |: (Json.field "activeFile" activeFileDecoder)
        |: (Json.field "scenes" (Json.list sceneDecoder))
        |: (Json.field "title" Json.string)
        |: (Json.field "author" Json.string)
        |: (Json.field "totalWordTarget" (Json.maybe Json.int))
        |: (Json.field "deadline" (Json.maybe dateDecoder))


activeFileDecoder : Json.Decoder (Maybe Int)
activeFileDecoder =
    Json.maybe Json.int


fileDecoder : Json.Decoder File
fileDecoder =
    Json.map5 File
        (Json.field "id" Json.int)
        (Json.field "parent" (Json.maybe Json.int))
        (Json.field "type_" fileTypeDecoder)
        (Json.field "name" Json.string)
        (Json.field "expanded" Json.bool)


fileTypeDecoder : Json.Decoder FileType
fileTypeDecoder =
    let
        stringToFileType : String -> Json.Decoder FileType
        stringToFileType ft =
            case ft of
                "scene" ->
                    Json.succeed SceneFile

                _ ->
                    Json.succeed SceneFile
    in
        Json.string |> Json.andThen stringToFileType


sceneDecoder : Json.Decoder Scene
sceneDecoder =
    Json.map7 Scene
        (Json.field "id" Json.int)
        (Json.field "parent" (Json.maybe Json.int))
        (Json.field "name" Json.string)
        (Json.field "content" (Json.list tokenDecoder))
        (Json.field "history" (Json.list (Json.list tokenDecoder)))
        (Json.field "commit" Json.int)
        (Json.field "wordTarget" Json.int)


tokenDecoder : Json.Decoder Token
tokenDecoder =
    Json.map2 Token
        (Json.field "token" tokenTypeDecoder)
        (Json.field "children" tokenChildrenDecoder)


tokenTypeDecoder : Json.Decoder TokenType
tokenTypeDecoder =
    let
        stringToTokenType : String -> Json.Decoder TokenType
        stringToTokenType tokenType =
            case tokenType of
                "paragraph" ->
                    Json.succeed Paragraph

                "speech" ->
                    Json.succeed Speech

                "emphasis" ->
                    Json.succeed Emphasis

                _ ->
                    let
                        value =
                            String.dropLeft 5 tokenType
                    in
                        Json.succeed (Text value)
    in
        Json.string |> Json.andThen stringToTokenType


dateDecoder : Json.Decoder Date
dateDecoder =
    Json.string
        |> Json.andThen
            (\timeString ->
                case String.toFloat timeString of
                    Ok time ->
                        Json.succeed <| Date.fromTime time

                    Err err ->
                        Json.fail err
            )
