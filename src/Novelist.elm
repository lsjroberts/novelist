module Novelist exposing (..)

import Debug
import Html exposing (..)
import Html.Attributes
    exposing
        ( contenteditable
        , spellcheck
        , value
        )
import Html.Events exposing (..)
import Html.Keyed
import Json.Decode as Json
import Regex
import Styles exposing (class)
import Octicons as Icon


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
    , history : List (List Token)
    , commit : Int
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
                , File 3 (Just 0) SceneFile "Scene Two" False
                , File 4 (Just 0) SceneFile "Scene Three" False
                ]
            , editingName = Nothing
            }
        , workspace =
            { editingName = Nothing
            }
        , activeFile = Just 0
        }
        { scenes =
            [ Scene 0 Nothing "Chapter One" [] [] 0
            , Scene 1 (Just 0) "Scene One" [] [] 0
            , Scene 2 Nothing "Chapter Two" [] [] 0
            , Scene 3 (Just 0) "Scene Two" [] [] 0
            , Scene 4 (Just 0) "Scene Three" [] [] 0
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


getOpeningTag : Token -> Maybe String
getOpeningTag { token } =
    case token of
        Speech ->
            Just "“"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


getClosingTag : Token -> Maybe String
getClosingTag { token } =
    case token of
        Speech ->
            Just "”"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


getShowTags : Token -> Bool
getShowTags { token } =
    case token of
        Speech ->
            True

        _ ->
            False


getOpeningTagMatches : Token -> Maybe (List String)
getOpeningTagMatches { token } =
    case token of
        Speech ->
            Just [ "“", "\"" ]

        Emphasis ->
            Just [ "_" ]

        _ ->
            Nothing


getClosingTagMatches : Token -> Maybe (List String)
getClosingTagMatches { token } =
    case token of
        Speech ->
            Just [ "”", "\"" ]

        Emphasis ->
            Just [ "_" ]

        _ ->
            Nothing


getTokenValue : Token -> Maybe String
getTokenValue { token } =
    case token of
        Text v ->
            Just v

        _ ->
            Nothing


getTokenChildren : Token -> List Token
getTokenChildren token =
    let
        get (TokenChildren cs) =
            cs
    in
        get token.children



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

        onClickMsg =
            if hasChildren then
                ToggleFileExpanded file.id
            else
                SetActiveFile file.id

        wrapperClass =
            if hasChildren then
                [ Styles.BinderDirectory ]
            else
                [ Styles.BinderFile ]

        itemClass =
            if hasChildren then
                [ Styles.BinderHeader ]
            else
                []

        wrapperIcon =
            if hasChildren then
                if file.expanded then
                    span [ class [ Styles.BinderDirectoryIcon ] ] [ Icon.defaultChevrondown ]
                else
                    span [ class [ Styles.BinderDirectoryIcon ] ] [ Icon.defaultChevronright ]
            else
                span [] []

        itemIcon =
            if hasChildren then
                span [ class [ Styles.BinderIcon ] ] [ Icon.defaultFiledirectory ]
            else
                span [ class [ Styles.BinderIcon ] ] [ Icon.defaultFile ]
    in
        div [ class wrapperClass ] <|
            [ h3
                [ class itemClass, onClick onClickMsg ]
                [ wrapperIcon, itemIcon, Html.text file.name ]
            , div [ class [ Styles.BinderEntries ] ] nested
            ]


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
                        viewScene model s

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


viewScene : Model -> Scene -> Html Msg
viewScene model scene =
    div [ class [ Styles.Scene ] ]
        [ viewSceneHeading model scene
        , div [] [ Html.text (toString scene.commit) ]
        , viewSceneContent model scene
        , viewSceneDebug model scene
        ]


viewSceneDebug : Model -> Scene -> Html Msg
viewSceneDebug model scene =
    div [ class [ Styles.SceneDebug ] ]
        (List.map (\c -> div [] [ Html.text (toString c) ]) scene.content)


viewSceneHeading : Model -> Scene -> Html Msg
viewSceneHeading model scene =
    div []
        [ viewSceneParentHeading model scene
        , input
            [ class [ Styles.SceneHeading ]
            , onInput (SetSceneName scene.id)
            , value scene.name
            ]
            []
        ]


viewSceneParentHeading : Model -> Scene -> Html Msg
viewSceneParentHeading model scene =
    case scene.parent of
        Just parentId ->
            case (getSceneById model.novel.scenes parentId) of
                Just parent ->
                    input
                        [ class [ Styles.SceneParentHeading ]
                        , onInput (SetSceneName parent.id)
                        , value parent.name
                        ]
                        []

                Nothing ->
                    div [] []

        Nothing ->
            div [] []


viewSceneContent : Model -> Scene -> Html Msg
viewSceneContent model scene =
    div [ class [ Styles.SceneContent ] ] [ viewSceneContentEditor model scene ]


viewSceneContentEditor : Model -> Scene -> Html Msg
viewSceneContentEditor model scene =
    Html.Keyed.node "div"
        [ class [ Styles.SceneContentEditor ] ]
        [ ( toString scene.commit
          , article
                [ class [ Styles.SceneContentEditorArticle ]
                , contenteditable True
                , spellcheck False
                  -- , onFocus StartWriting
                , on "blur" (Json.map Write childrenContentDecoder)
                ]
                (List.map viewToken scene.content)
          )
        ]


viewToken : Token -> Html Msg
viewToken model =
    case model.token of
        Paragraph ->
            viewTokenParagraph model

        Speech ->
            viewTokenSpeech model

        Emphasis ->
            viewTokenEmphasis model

        Text a ->
            viewTokenText model


viewTokenParagraph : Token -> Html Msg
viewTokenParagraph token =
    viewTokenInner token.children
        |> p [ class [ Styles.TokenParagraph ] ]


viewTokenSpeech : Token -> Html Msg
viewTokenSpeech token =
    token
        |> viewTokenWrap
        |> span [ class [ Styles.TokenSpeech ] ]


viewTokenEmphasis : Token -> Html Msg
viewTokenEmphasis token =
    token
        |> viewTokenWrap
        |> span [ class [ Styles.TokenEmphasis ] ]


viewTokenWrap : Token -> List (Html Msg)
viewTokenWrap token =
    let
        before =
            case getOpeningTag token of
                Just b ->
                    if getShowTags token then
                        [ Html.text b ]
                    else
                        [ span [ class [ Styles.TokenWrap ] ] [ Html.text b ] ]

                Nothing ->
                    []

        after =
            case getClosingTag token of
                Just a ->
                    if getShowTags token then
                        [ Html.text a ]
                    else
                        [ span [ class [ Styles.TokenWrap ] ] [ Html.text a ] ]

                Nothing ->
                    []
    in
        before ++ viewTokenInner token.children ++ after


viewTokenInner : TokenChildren -> List (Html Msg)
viewTokenInner (TokenChildren children) =
    List.map viewToken children


viewTokenText : Token -> Html Msg
viewTokenText token =
    case token.token of
        Text value ->
            Html.text value

        _ ->
            Html.text ""


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
    = SetActiveFile Int
    | SetSceneName Int String
    | ToggleFileExpanded Int
    | Write String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        SetActiveFile id ->
            ( model |> setActiveFile (Just id)
            , Cmd.none
            )

        SetSceneName id name ->
            ( model
                |> setSceneName id name
                |> setFileName id name
            , Cmd.none
            )

        ToggleFileExpanded id ->
            ( model |> toggleFileExpanded id
            , Cmd.none
            )

        Write content ->
            case model.ui.activeFile of
                Just id ->
                    ( model |> setSceneContent id (markdownToTokens content)
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )


setUi : Ui -> Model -> Model
setUi ui model =
    { model | ui = ui }


setActiveFile : Maybe Int -> Model -> Model
setActiveFile activeFile model =
    let
        ui =
            model.ui
    in
        model |> setUi { ui | activeFile = activeFile }


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


setSceneContent : Int -> List Token -> Model -> Model
setSceneContent id content model =
    let
        maybeScene =
            getSceneById model.novel.scenes id
    in
        case maybeScene of
            Just scene ->
                model
                    |> setScene
                        { scene
                            | content = content
                            , history = scene.content :: scene.history
                            , commit = scene.commit + 1
                        }

            Nothing ->
                model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- DECODERS


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



-- FACTORIES


markdownToTokens : String -> List Token
markdownToTokens string =
    let
        cleanString =
            Regex.replace Regex.All (Regex.regex "\n+$") (\_ -> "") string

        tokens =
            if String.contains "\n" cleanString then
                cleanString
                    |> String.split "\n"
                    |> List.map paragraph
            else if String.contains "“" cleanString then
                tokenWrap2 "“" "”" speech text string
            else if String.contains "\"" cleanString then
                tokenWrap "\"" speech text string
            else if String.contains "_" cleanString then
                tokenWrap "_" emphasis text cleanString
            else
                [ text cleanString ]
    in
        tokens |> filterEmptyParagraphTokens


paragraph : String -> Token
paragraph string =
    string
        |> markdownToTokens
        |> TokenChildren
        |> Token Paragraph


speech : String -> Token
speech string =
    string
        |> Regex.replace Regex.All (Regex.regex "“|”|\"") (\_ -> "")
        |> markdownToTokens
        |> TokenChildren
        |> Token Speech


emphasis : String -> Token
emphasis string =
    string
        |> Regex.replace Regex.All (Regex.regex "_") (\_ -> "")
        |> markdownToTokens
        |> TokenChildren
        |> Token Emphasis


text : String -> Token
text string =
    Token (Text string) (TokenChildren [])



-- UTILS


tokenWrap char =
    tokenWrap2 char char


tokenWrap2 : String -> String -> (String -> Token) -> (String -> Token) -> String -> List Token
tokenWrap2 left right inside outside string =
    let
        exp =
            Regex.regex (left ++ ".+?" ++ right)

        insides =
            Regex.find Regex.All exp string
                |> List.map .match
                |> List.map inside

        outsides =
            Regex.split Regex.All exp string
                |> List.map outside
                |> filterEmptyTextTokens
    in
        if String.startsWith left string then
            zip insides outsides
        else
            zip outsides insides


filterEmptyParagraphTokens : List Token -> List Token
filterEmptyParagraphTokens =
    List.filter
        (\x ->
            if x.token == Paragraph then
                if List.length (filterEmptyTextTokens (getTokenChildren x)) == 0 then
                    True
                else
                    True
            else
                True
        )


filterEmptyTextTokens : List Token -> List Token
filterEmptyTextTokens =
    List.filter
        (\x ->
            case x.token of
                Text value ->
                    if String.length value > 0 then
                        True
                    else
                        False

                _ ->
                    False
        )


zip : List a -> List a -> List a
zip xs ys =
    case ( xs, ys ) of
        ( x :: xBack, y :: yBack ) ->
            [ x, y ] ++ zip xBack yBack

        ( x :: xBack, _ ) ->
            [ x ]

        ( _, y :: yBack ) ->
            [ y ]

        ( _, _ ) ->
            []
