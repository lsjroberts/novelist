module Data.Model exposing (..)

import Date exposing (Date)
import Data.File exposing (File, FileType(..))
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
import Messages exposing (Msg(..))
import Utils.String exposing (getStringWordCount)


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
    }


mock : Model
mock =
    { files =
        [ File 0 Nothing SceneFile "Chapter One" False
        , File 1 (Just 0) SceneFile "Scene One" False
        , File 2 Nothing SceneFile "Chapter Two" False
        , File 3 (Just 0) SceneFile "Scene Two" False
        , File 4 (Just 0) SceneFile "Scene Three" False
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
        ]
    , title = "Title"
    , author = "Author"
    , totalWordTarget = Nothing
    , deadline = Nothing
    , time = 0
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


getSceneWordCount : Scene -> Int
getSceneWordCount =
    .content >> tokensToPlainText >> getStringWordCount


getTotalWordCount : Model -> Int
getTotalWordCount =
    .scenes >> List.map getSceneWordCount >> List.sum


getRootFiles : List File -> List File
getRootFiles files =
    files |> List.filter (\f -> f.parent == Nothing)


getSceneFiles : List File -> List File
getSceneFiles files =
    files |> List.filter (\f -> f.type_ == SceneFile)


getFileChildren : List File -> File -> List File
getFileChildren files file =
    files
        |> List.filter
            (\f ->
                case f.parent of
                    Just parent ->
                        parent == file.id

                    Nothing ->
                        False
            )


getById : List { a | id : Int } -> Int -> Maybe { a | id : Int }
getById xs id =
    xs
        |> List.filter (\x -> x.id == id)
        |> List.head
