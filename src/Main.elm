module Main exposing (..)

import Debug
import Html
    exposing
        ( Html
        , program
        , div
        , span
        , h1
        , h2
        , h3
        , input
        )
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Styles exposing (class)
import Octicons as Icon


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
    { binder : Binder
    , workspace : Workspace
    , activeFile : Maybe Int
    }


type alias Binder =
    { files : List File
    , editingName : Maybe Int
    }


type alias Workspace =
    { editingName : Maybe Int }


type alias File =
    { id : Int
    , parent : Maybe Int
    , type_ : FileType
    , name : String
    , expanded : Bool
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


init : ( Model, Cmd Msg )
init =
    ( mock
    , Cmd.none
    )


empty : Model
empty =
    Model
        { binder =
            { files = []
            , editingName = Nothing
            }
        , workspace =
            { editingName = Nothing
            }
        , activeFile = Nothing
        }
        { scenes = []
        }


mock : Model
mock =
    Model
        { binder =
            { files =
                [ File 0 Nothing SceneFile "Chapter One" False
                , File 1 (Just 0) SceneFile "Scene One" False
                , File 2 Nothing SceneFile "Chapter Two" False
                ]
            , editingName = Nothing
            }
        , workspace =
            { editingName = Nothing
            }
        , activeFile = Just 0
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


view : Model -> Html Msg
view model =
    div [ class [ Styles.Root ] ]
        [ viewEditor (Debug.log "model" model)
        ]


viewEditor : Model -> Html Msg
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


viewMenu : Model -> Html Msg
viewMenu model =
    div
        [ class [ Styles.Menu ] ]
        []


viewBinder : Model -> Html Msg
viewBinder model =
    div
        [ class [ Styles.BinderWrapper ] ]
        [ viewPanel
            [ viewBinderInner model ]
        ]


viewBinderInner : Model -> Html Msg
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


viewBinderFile : List File -> File -> Html Msg
viewBinderFile allFiles file =
    let
        children =
            getFileChildren allFiles file

        hasChildren =
            not <| List.isEmpty children

        nested =
            if file.expanded then
                children |> List.map (viewBinderFile allFiles)
            else
                []

        ( classes, icon ) =
            if hasChildren then
                if file.expanded then
                    ( [ Styles.BinderFolder, Styles.BinderFolderExpanded ]
                    , Icon.defaultChevrondown
                    )
                else
                    ( [ Styles.BinderFolder ]
                    , Icon.defaultChevronright
                    )
            else
                ( [ Styles.BinderFile ], Icon.defaultFile )
    in
        h3
            [ class classes
            , onClick (ToggleFileExpanded file.id)
            ]
        <|
            [ span [ class [ Styles.BinderIcon ] ] [ icon ]
            , Html.text file.name
            ]
                ++ nested


viewWorkspace : Model -> Html Msg
viewWorkspace model =
    div [ class [ Styles.Workspace ] ]
        [ viewWorkspaceHeader
        , viewWorkspaceFile model
        ]


viewWorkspaceHeader : Html Msg
viewWorkspaceHeader =
    div
        [ class [ Styles.WorkspaceHeader ] ]
        [ div [] [ Html.text "Title" ]
        , div [ class [ Styles.WorkspaceHeaderAuthor ] ] [ Html.text "Author" ]
        ]


viewWorkspaceFile : Model -> Html Msg
viewWorkspaceFile model =
    let
        file =
            case model.ui.activeFile of
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
                        viewScene model.ui.workspace s

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


viewScene : Workspace -> Scene -> Html Msg
viewScene workspace scene =
    div [ class [ Styles.Scene ] ] [ viewSceneHeading workspace scene ]


viewSceneHeading : Workspace -> Scene -> Html Msg
viewSceneHeading workspace scene =
    input
        [ class [ Styles.SceneHeading ]
        , onInput (SetSceneName scene.id)
        , value scene.name
        ]
        []


viewInspector : Model -> Html Msg
viewInspector model =
    div
        [ class [ Styles.Inspector ] ]
        [ viewPanel
            []
        ]


viewPanel : List (Html Msg) -> Html Msg
viewPanel children =
    div [ class [ Styles.Panel ] ] children



-- STATE


type Msg
    = SetSceneName Int String
    | ToggleFileExpanded Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        ToggleFileExpanded id ->
            ( model |> toggleFileExpanded id
            , Cmd.none
            )

        SetSceneName id name ->
            ( model
                |> setSceneName id name
                |> setFileName id name
            , Cmd.none
            )


setUi : Ui -> Model -> Model
setUi ui model =
    { model | ui = ui }


setBinder : Binder -> Model -> Model
setBinder binder model =
    let
        ui =
            model.ui
    in
        model |> setUi { ui | binder = binder }


setFile : File -> Model -> Model
setFile file model =
    let
        binder =
            model.ui.binder

        files =
            binder.files
                |> List.map
                    (\f ->
                        if f.id == file.id then
                            file
                        else
                            f
                    )
    in
        model |> setBinder { binder | files = files }


setFileName : Int -> String -> Model -> Model
setFileName id name model =
    let
        maybeFile =
            getFileById model.ui.binder.files id
    in
        case maybeFile of
            Just file ->
                model |> setFile { file | name = name }

            Nothing ->
                model


toggleFileExpanded : Int -> Model -> Model
toggleFileExpanded id model =
    let
        maybeFile =
            getFileById model.ui.binder.files id
    in
        case maybeFile of
            Just file ->
                model |> setFile { file | expanded = not file.expanded }

            Nothing ->
                model


setWorkspace : Workspace -> Model -> Model
setWorkspace workspace model =
    let
        ui =
            model.ui
    in
        model |> setUi { ui | workspace = workspace }


setWorkspaceEditingName : Maybe Int -> Model -> Model
setWorkspaceEditingName maybeId model =
    let
        workspace =
            model.ui.workspace
    in
        model |> setWorkspace { workspace | editingName = maybeId }


setNovel : Novel -> Model -> Model
setNovel novel model =
    { model | novel = novel }


setScene : Scene -> Model -> Model
setScene scene model =
    let
        novel =
            model.novel

        scenes =
            novel.scenes
                |> List.map
                    (\s ->
                        if s.id == scene.id then
                            scene
                        else
                            s
                    )
    in
        model |> setNovel { novel | scenes = scenes }


setSceneName : Int -> String -> Model -> Model
setSceneName id name model =
    let
        maybeScene =
            getSceneById model.novel.scenes id
    in
        case maybeScene of
            Just scene ->
                model |> setScene { scene | name = name }

            Nothing ->
                model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
