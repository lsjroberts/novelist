module Main exposing (..)

import Debug
import Html exposing (Html, program, div, span, h1, h2, h3)
import Styles exposing (class)


-- PROGRAM


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { ui : Ui
    , novel : Novel
    }


type alias Ui =
    { binder : Binder }


type alias Binder =
    { files : List File
    , activeFile : Maybe Int
    }


type alias File =
    { id : Int
    , parent : Maybe Int
    , type_ : FileType
    , name : String
    }


type FileType
    = SceneFile


type alias Novel =
    { scenes : List Scene
    }


type alias Scene =
    { id : Int
    , parent : Maybe Int
    , name : String
    , content : List Token
    }


type alias Token =
    { token : TokenType
    , children : TokenChildren
    }


type TokenType
    = Paragraph
    | Speech
    | Emphasis
    | Text String


type TokenChildren
    = TokenChildren (List Token)


init : ( Model, Cmd msg )
init =
    ( mock
    , Cmd.none
    )


empty : Model
empty =
    Model
        { binder =
            { files = []
            , activeFile = Nothing
            }
        }
        { scenes = []
        }


mock : Model
mock =
    Model
        { binder =
            { files =
                [ File 0 Nothing SceneFile "Chapter One"
                , File 1 (Just 0) SceneFile "Scene One"
                , File 2 Nothing SceneFile "Chapter Two"
                ]
            , activeFile = Just 0
            }
        }
        { scenes =
            [ Scene 0 Nothing "Chapter One" []
            , Scene 1 (Just 1) "Scene One" []
            , Scene 2 Nothing "Chapter Two" []
            ]
        }


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


getFileById : List File -> Int -> Maybe File
getFileById files id =
    files
        |> List.filter (\f -> f.id == id)
        |> List.head


getSceneById : List Scene -> Int -> Maybe Scene
getSceneById scenes id =
    scenes
        |> List.filter (\s -> s.id == id)
        |> List.head



-- VIEW


view : Model -> Html msg
view model =
    div [ class [ Styles.Root ] ]
        [ viewEditor (Debug.log "model" model)
        ]


viewEditor : Model -> Html msg
viewEditor model =
    div [ class [ Styles.EditorWrapper ] ]
        [ viewMenu model
        , div
            [ class [ Styles.Editor ] ]
            [ viewBinder model
            , viewWorkspace model
            , viewInspector model
            ]
        ]


viewMenu : Model -> Html msg
viewMenu model =
    div
        [ class [ Styles.Menu ] ]
        []


viewBinder : Model -> Html msg
viewBinder model =
    div
        [ class [ Styles.BinderWrapper ] ]
        [ viewPanel
            [ viewBinderInner model ]
        ]


viewBinderInner : Model -> Html msg
viewBinderInner model =
    let
        files =
            model.ui.binder.files

        manuscript =
            files
                |> getRootFiles
                |> getSceneFiles
                |> List.map (viewBinderFile files)
    in
        div [ class [ Styles.Binder ] ] <|
            [ h2 [] [ Html.text "Manuscript" ] ]
                ++ manuscript


viewBinderFile : List File -> File -> Html msg
viewBinderFile allFiles file =
    let
        children =
            getFileChildren allFiles file

        hasChildren =
            not <| List.isEmpty children

        nested =
            children |> List.map (viewBinderFile allFiles)
    in
        h3 [ class [ Styles.BinderFile ] ] <|
            [ Html.text file.name
            ]
                ++ nested


viewWorkspace : Model -> Html msg
viewWorkspace model =
    div [ class [ Styles.Workspace ] ]
        [ viewWorkspaceHeader
        , viewWorkspaceFile model
        ]


viewWorkspaceHeader : Html msg
viewWorkspaceHeader =
    div
        [ class [ Styles.WorkspaceHeader ] ]
        [ div [] [ Html.text "Title" ]
        , div [ class [ Styles.WorkspaceHeaderAuthor ] ] [ Html.text "Author" ]
        ]


viewWorkspaceFile : Model -> Html msg
viewWorkspaceFile model =
    let
        file =
            case model.ui.binder.activeFile of
                Just id ->
                    getFileById model.ui.binder.files id

                Nothing ->
                    Nothing

        sceneInner f =
            let
                scene =
                    getSceneById model.novel.scenes f.id
            in
                case scene of
                    Just s ->
                        viewScene s

                    Nothing ->
                        div [] []
    in
        case file of
            Just f ->
                case f.type_ of
                    SceneFile ->
                        sceneInner f

            Nothing ->
                div [] []


viewScene : Scene -> Html msg
viewScene scene =
    div [ class [ Styles.Scene ] ] [ viewSceneHeading scene ]


viewSceneHeading : Scene -> Html msg
viewSceneHeading scene =
    h1
        [ class [ Styles.SceneHeading ] ]
        [ Html.text scene.name ]


viewInspector : Model -> Html msg
viewInspector model =
    div
        [ class [ Styles.Inspector ] ]
        [ viewPanel
            []
        ]


viewPanel : List (Html msg) -> Html msg
viewPanel children =
    div [ class [ Styles.Panel ] ] children



-- STATE


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none
