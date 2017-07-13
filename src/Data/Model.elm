module Data.Model exposing (..)

import Date exposing (Date)
import Data.File exposing (File, FileType(..))
import Data.Novel exposing (Novel)
import Data.Scene exposing (Scene, getSceneWordCount)
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
import Messages exposing (Msg(..))
import Utils.String exposing (getStringWordCount)
import Utils.List exposing (getById)


type alias Model =
    Novel (Ui {})


init : ( Model, Cmd Msg )
init =
    ( mock
    , Cmd.none
    )


createModel : List File -> Maybe Int -> List Scene -> String -> String -> Maybe Int -> Maybe Date -> Model
createModel files activeFile scenes title author totalWordTarget deadline =
    { files = files
    , editingFileName = Nothing
    , activeFile = activeFile
    , activeView = EditorView
    , scenes = scenes
    , title = title
    , author = author
    , totalWordTarget = totalWordTarget
    , deadline = deadline
    , time = 0
    , selection = Nothing
    }


empty : Model
empty =
    { files = []
    , editingFileName = Nothing
    , activeFile = Nothing
    , activeView = EditorView
    , scenes = []
    , title = "Title"
    , author = "Author"
    , totalWordTarget = Nothing
    , deadline = Nothing
    , time = 0
    , selection = Nothing
    }


mock : Model
mock =
    { files =
        [ File 0 Nothing SceneFile "Chapter One" False
        , File 1 (Just 0) SceneFile "Scene One" False
        , File 2 Nothing SceneFile "Chapter Two" False
        , File 3 (Just 0) SceneFile "Scene Two" False
        , File 4 (Just 0) SceneFile "Scene Three" False
        , File 5 (Just 2) SceneFile "Scene Four" False
        ]
    , editingFileName = Nothing
    , activeFile = Just 1
    , activeView = EditorView
    , scenes =
        [ Scene 0 Nothing "Chapter One" [] [] 0 0
        , Scene 1
            (Just 0)
            "Scene One"
            [ Token Paragraph (TokenChildren [ Token (Text "New scene") (TokenChildren []) ])
            ]
            []
            0
            2000
        , Scene 2 Nothing "Chapter Two" [] [] 0 0
        , Scene 3 (Just 0) "Scene Two" [] [] 0 0
        , Scene 4 (Just 0) "Scene Three" [] [] 0 0
        , Scene 5 (Just 2) "Scene Four" [] [] 0 0
        ]
    , title = "Title"
    , author = "Author"
    , totalWordTarget = Nothing
    , deadline = Nothing
    , time = 0
    , selection = Nothing
    }


getActiveScene : Model -> Maybe Scene
getActiveScene model =
    case model.activeFile of
        Just id ->
            getById model.scenes id

        Nothing ->
            Nothing


getActiveSceneWordCount : Model -> Int
getActiveSceneWordCount model =
    case getActiveScene model of
        Just scene ->
            getSceneWordCount scene

        Nothing ->
            0


getTotalWordCount : Model -> Int
getTotalWordCount =
    .scenes >> List.map getSceneWordCount >> List.sum
