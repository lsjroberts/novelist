module Data.Encode exposing (..)

import Date exposing (Date)
import Json.Encode as Encode
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


modelEncoder : Model -> Encode.Value
modelEncoder model =
    Encode.object
        [ ( "files", Encode.list (List.map fileEncoder model.files) )
        , ( "editingFileName", maybeIntEncoder model.editingFileName )
        , ( "activeFile", maybeIntEncoder model.activeFile )
        , ( "activeView", viewTypeEncoder model.activeView )
        , ( "scenes", Encode.list (List.map sceneEncoder model.scenes) )
        , ( "title", Encode.string model.title )
        , ( "author", Encode.string model.author )
        , ( "totalWordTarget", maybeIntEncoder model.totalWordTarget )
        , ( "deadline", maybeDateEncoder model.deadline )
        ]


fileEncoder : File -> Encode.Value
fileEncoder file =
    Encode.object
        [ ( "id", Encode.int file.id )
        , ( "parent", maybeIntEncoder file.parent )
        , ( "type_", fileTypeEncoder file.type_ )
        , ( "name", Encode.string file.name )
        , ( "expanded", Encode.bool file.expanded )
        ]


fileTypeEncoder : FileType -> Encode.Value
fileTypeEncoder fileType =
    case fileType of
        SceneFile ->
            Encode.string "scene"

        PlanFile ->
            Encode.string "plan"

        CharacterFile ->
            Encode.string "character"

        LocationFile ->
            Encode.string "location"


viewTypeEncoder : ViewType -> Encode.Value
viewTypeEncoder viewType =
    case viewType of
        EditorView ->
            Encode.string "editor"

        SettingsView ->
            Encode.string "settings"


maybeIntEncoder : Maybe Int -> Encode.Value
maybeIntEncoder maybeInt =
    case maybeInt of
        Just i ->
            Encode.int i

        Nothing ->
            Encode.null


maybeDateEncoder : Maybe Date -> Encode.Value
maybeDateEncoder maybeDate =
    case maybeDate of
        Just date ->
            date
                |> Date.toTime
                |> toString
                |> Encode.string

        Nothing ->
            Encode.null


sceneEncoder : Scene -> Encode.Value
sceneEncoder scene =
    Encode.object
        [ ( "id", Encode.int scene.id )
        , ( "parent", maybeIntEncoder scene.parent )
        , ( "name", Encode.string scene.name )
        , ( "content", Encode.list (List.map tokenEncoder scene.content) )
        , ( "history", Encode.list (List.map (\h -> Encode.list (List.map tokenEncoder h)) scene.history) )
        , ( "commit", Encode.int scene.commit )
        , ( "wordTarget", Encode.int scene.wordTarget )
        ]


tokenEncoder : Token -> Encode.Value
tokenEncoder token =
    Encode.object
        [ ( "token", tokenTypeEncoder token.type_ )
        , ( "children", Encode.list (List.map tokenEncoder (getTokenChildren token)) )
        ]


tokenTypeEncoder : TokenType -> Encode.Value
tokenTypeEncoder tokenType =
    case tokenType of
        Paragraph ->
            Encode.string "paragraph"

        Speech ->
            Encode.string "speech"

        Emphasis ->
            Encode.string "emphasis"

        CommentTag _ ->
            Encode.string "comment"

        CharacterTag _ ->
            Encode.string "character"

        LocationTag _ ->
            Encode.string "location"

        Text value ->
            Encode.string ("text|" ++ value)
