port module Novelist exposing (..)

import Date exposing (Date)
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
import Json.Encode as Encode
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
    , activeView : ViewType
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


type ViewType
    = EditorView
    | SettingsView


type alias Novel =
    { scenes : List Scene
    , meta : Meta
    }


type alias Scene =
    { id : Int
    , parent : Maybe Int
    , name : String
    , content : List Token
    , history : List (List Token)
    , commit : Int
    , wordTarget : Int
    }


type alias Meta =
    { title : String
    , author : String
    , targetWordCount : Maybe Int
    , deadline : Maybe Date
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
        , activeView = EditorView
        }
        { scenes = []
        , meta =
            { title = "Title"
            , author = "Author"
            , targetWordCount = Nothing
            , deadline = Nothing
            }
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
        , activeView = EditorView
        }
        { scenes =
            [ Scene 0
                Nothing
                "Chapter One"
                [ Token Paragraph (TokenChildren [ Token (Text "New scene") (TokenChildren []) ])
                ]
                []
                0
                2000
            , Scene 1 (Just 0) "Scene One" [] [] 0 0
            , Scene 2 Nothing "Chapter Two" [] [] 0 0
            , Scene 3 (Just 0) "Scene Two" [] [] 0 0
            , Scene 4 (Just 0) "Scene Three" [] [] 0 0
            ]
        , meta =
            { title = "Title"
            , author = "Author"
            , targetWordCount = Nothing
            , deadline = Nothing
            }
        }


getActiveScene : Model -> Maybe Scene
getActiveScene model =
    case model.ui.activeFile of
        Just id ->
            getById model.novel.scenes id

        Nothing ->
            Nothing


getWordCount : Model -> Int
getWordCount model =
    case getActiveScene model of
        Just scene ->
            scene
                |> .content
                |> tokensToPlainText
                -- then replace all non-alphanumeric and space characters
                |>
                    String.split " "
                |> List.length

        Nothing ->
            0


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

        Emphasis ->
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
    let
        activeView =
            case model.ui.activeView of
                EditorView ->
                    viewEditor

                SettingsView ->
                    viewSettings
    in
        div [ class [ Styles.Root ] ]
            [ activeView (Debug.log "model" model) ]


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
        , viewFooter model
        ]


viewMenu : Model -> Html Msg
viewMenu model =
    let
        viewToggle =
            case model.ui.activeView of
                EditorView ->
                    div [ onClick (SetActiveView SettingsView) ]
                        [ Html.text "Settings" ]

                SettingsView ->
                    div [ onClick (SetActiveView EditorView) ]
                        [ Html.text "Editor" ]
    in
        div
            [ class [ Styles.Menu ] ]
            [ viewToggle ]


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
        [ viewWorkspaceHeader model
        , viewWorkspaceFile model
        ]


viewWorkspaceHeader : Model -> Html Msg
viewWorkspaceHeader model =
    div
        [ class [ Styles.WorkspaceHeader ] ]
        [ div [] [ Html.text model.novel.meta.title ]
        , div [ class [ Styles.WorkspaceHeaderAuthor ] ] [ Html.text "Author" ]
        ]


viewWorkspaceFile : Model -> Html Msg
viewWorkspaceFile model =
    let
        file =
            case model.ui.activeFile of
                Just id ->
                    getById model.ui.binder.files id

                Nothing ->
                    Nothing

        sceneInner f =
            let
                scene =
                    getById model.novel.scenes f.id
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
        , viewSceneContent model scene
          -- , viewSceneDebug model scene
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
            case (getById model.novel.scenes parentId) of
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
    div [ class [ Styles.SceneContent ] ]
        [ viewSceneContentEditor model scene ]


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


viewTokenText : Token -> Html Msg
viewTokenText token =
    case token.token of
        Text value ->
            Html.text value

        _ ->
            Html.text ""


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


viewInspector : Model -> Html Msg
viewInspector model =
    div
        [ class [ Styles.Inspector ] ]
        [ viewPanel
            []
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    div
        [ class [ Styles.Footer ] ]
        [ viewFooterCommit model
        , viewFooterWordCount model
        ]


viewFooterCommit : Model -> Html Msg
viewFooterCommit model =
    let
        commitCount =
            case getActiveScene model of
                Just scene ->
                    scene.commit

                Nothing ->
                    0

        commit =
            commitCount
                |> toString
                |> Html.text
    in
        div [ class [ Styles.FooterCommit ] ]
            [ commit ]


viewFooterWordCount : Model -> Html Msg
viewFooterWordCount model =
    let
        wordCount =
            model
                |> getWordCount
                |> toString
                |> Html.text
    in
        div [ class [ Styles.FooterWordCount ] ]
            [ wordCount
            , viewFooterWordTarget model
            ]


viewFooterWordTarget : Model -> Html Msg
viewFooterWordTarget model =
    let
        maybeScene =
            getActiveScene model

        wordTarget =
            case maybeScene of
                Just scene ->
                    scene.wordTarget

                Nothing ->
                    0

        wordTargetInput =
            case maybeScene of
                Just scene ->
                    input
                        [ class [ Styles.FooterWordTarget ]
                        , onInput (SetSceneWordTarget scene.id)
                        , value (toString wordTarget)
                        ]
                        []

                Nothing ->
                    span [] []
    in
        if wordTarget > 0 then
            span []
                [ Html.text " of "
                , wordTargetInput
                ]
        else
            span [] []


viewPanel : List (Html Msg) -> Html Msg
viewPanel children =
    div [ class [ Styles.Panel ] ] children


viewSettings : Model -> Html Msg
viewSettings model =
    div [ class [ Styles.SettingsWrapper ] ]
        [ viewMenu model
        , div
            [ class [ Styles.Settings ] ]
            [ h1 [ class [ Styles.SettingsHeader ] ] [ Html.text "Settings" ]
            , viewProjectMeta model
            , viewEditorSettings model
            , viewCompileSettings model
            ]
        ]


viewProjectMeta : Model -> Html Msg
viewProjectMeta model =
    let
        meta =
            model.novel.meta
    in
        div [ class [ Styles.SettingsSection ] ]
            [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Project" ]
            , viewFormInput
                "Title"
                (Just "The title of your story, displayed on the blah blah")
                (input [ class [ Styles.FormInputText ], value meta.title ] [])
            , viewFormInput
                "Author"
                (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
                (input [ class [ Styles.FormInputText ], value meta.author ] [])
            , viewFormInput
                "Total Word Target"
                (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
                (input
                    [ class [ Styles.FormInputText ]
                    , Html.Attributes.type_ "number"
                    , Html.Attributes.placeholder "Default: 80000"
                    ]
                    []
                )
            , viewFormInput
                "Deadline"
                (Just "Cras mattis consectetur purus sit amet fermentum.")
                (input [ class [ Styles.FormInputText ] ] [])
            ]


viewEditorSettings : Model -> Html Msg
viewEditorSettings model =
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Editor" ]
        , viewFormInput
            "Theme"
            (Just "Sed posuere consectetur est at lobortis.")
            (input
                [ class [ Styles.FormInputText ]
                , Html.Attributes.placeholder "Default: Solarized Light"
                ]
                []
            )
        , viewFormInput
            "Font Size"
            (Just "The base font size for the editor, this does not affect the font size in your compiled book")
            (input
                [ class [ Styles.FormInputText ]
                , Html.Attributes.type_ "number"
                , Html.Attributes.placeholder "Default: 16"
                ]
                []
            )
        ]


viewCompileSettings : Model -> Html Msg
viewCompileSettings model =
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Compile" ]
        , viewFormInputOption
            ".pdf"
            (Just "Create a .pdf when you click the 'compile' button")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxChecked
                    ]
                ]
                [ Html.text "Y" ]
            )
        , viewFormInputOption
            ".epub"
            (Just "Coming soon!")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxDisabled
                    ]
                ]
                []
            )
        , viewFormInputOption
            ".mobi"
            (Just "Coming soon!")
            (div
                [ class
                    [ Styles.FormInputCheckbox
                    , Styles.FormInputCheckboxDisabled
                    ]
                ]
                []
            )
        ]


viewFormInput : String -> Maybe String -> Html Msg -> Html Msg
viewFormInput label maybeDesc formInput =
    div [ class [ Styles.FormInput ] ]
        [ div [ class [ Styles.FormInputLabel ] ] [ Html.text label ]
        , case maybeDesc of
            Just desc ->
                div [ class [ Styles.FormInputDescription ] ] [ Html.text desc ]

            Nothing ->
                span [] []
        , formInput
        ]


viewFormInputOption : String -> Maybe String -> Html Msg -> Html Msg
viewFormInputOption label maybeDesc formInput =
    div [ class [ Styles.FormInputOption ] ]
        [ div [ class [ Styles.FormInputOptionInput ] ] [ formInput ]
        , div [ class [ Styles.FormInputLabel ] ] [ Html.text label ]
        , case maybeDesc of
            Just desc ->
                div [ class [ Styles.FormInputDescription ] ] [ Html.text desc ]

            Nothing ->
                span [] []
        ]



-- STATE


type Msg
    = GoToSettings String
    | OpenProject String
    | SetActiveFile Int
    | SetActiveView ViewType
    | SetSceneName Int String
    | SetSceneWordTarget Int String
    | ToggleFileExpanded Int
    | Write String


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
        ( newModel
        , Cmd.batch [ setStorage (modelEncoder newModel), cmds ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        GoToSettings _ ->
            update (SetActiveView SettingsView) model

        OpenProject project ->
            ( decodeProject project, Cmd.none )

        SetActiveFile id ->
            ( model |> setActiveFile (Just id)
            , Cmd.none
            )

        SetActiveView viewType ->
            ( model |> setActiveView viewType
            , Cmd.none
            )

        SetSceneName id name ->
            ( model
                |> setSceneName id name
                |> setFileName id name
            , Cmd.none
            )

        SetSceneWordTarget id targetString ->
            let
                targetInt =
                    String.toInt targetString

                target =
                    case targetInt of
                        Ok int ->
                            int

                        Err errorMsg ->
                            0
            in
                ( model |> setSceneWordTarget id target
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


setActiveView : ViewType -> Model -> Model
setActiveView activeView model =
    let
        ui =
            model.ui
    in
        model |> setUi { ui | activeView = activeView }


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
            getById model.ui.binder.files id
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
            getById model.ui.binder.files id
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
            getById model.novel.scenes id
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
            getById model.novel.scenes id
    in
        case maybeScene of
            Just scene ->
                if content == scene.content then
                    model
                else
                    model
                        |> setScene
                            { scene
                                | content = content
                                , history = scene.content :: scene.history
                                , commit = scene.commit + 1
                            }

            Nothing ->
                model


setSceneWordTarget : Int -> Int -> Model -> Model
setSceneWordTarget id wordTarget model =
    let
        maybeScene =
            getById model.novel.scenes id
    in
        case maybeScene of
            Just scene ->
                model |> setScene { scene | wordTarget = wordTarget }

            Nothing ->
                model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openProject OpenProject
        , gotoSettings GoToSettings
        ]



-- PORTS


port openProject : (String -> msg) -> Sub msg


port gotoSettings : (String -> msg) -> Sub msg


port setStorage : Encode.Value -> Cmd msg



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


decodeProject : String -> Model
decodeProject payload =
    case Json.decodeString modelDecoder payload of
        Ok model ->
            Debug.log "decodedModel" model

        Err message ->
            Debug.crash message ()


modelDecoder : Json.Decoder Model
modelDecoder =
    Json.map2 Model
        (Json.field "ui" uiDecoder)
        (Json.field "novel" novelDecoder)


uiDecoder : Json.Decoder Ui
uiDecoder =
    Json.map4 Ui
        (Json.field "binder" binderDecoder)
        (Json.field "workspace" workspaceDecoder)
        (Json.field "activeFile" activeFileDecoder)
        (Json.field "activeView" activeViewDecoder)


binderDecoder : Json.Decoder Binder
binderDecoder =
    Json.map2 Binder
        (Json.field "files" (Json.list fileDecoder))
        (Json.field "editingName" editingNameDecoder)


workspaceDecoder : Json.Decoder Workspace
workspaceDecoder =
    Json.map Workspace
        (Json.field "editingName" editingNameDecoder)


activeFileDecoder : Json.Decoder (Maybe Int)
activeFileDecoder =
    Json.maybe Json.int


activeViewDecoder : Json.Decoder ViewType
activeViewDecoder =
    let
        stringToViewType : String -> Json.Decoder ViewType
        stringToViewType viewType =
            case viewType of
                "editor" ->
                    Json.succeed EditorView

                "settings" ->
                    Json.succeed SettingsView

                _ ->
                    Json.succeed EditorView
    in
        Json.string |> Json.andThen stringToViewType


editingNameDecoder : Json.Decoder (Maybe Int)
editingNameDecoder =
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


novelDecoder : Json.Decoder Novel
novelDecoder =
    Json.map2 Novel
        (Json.field "scenes" (Json.list sceneDecoder))
        (Json.field "meta" metaDecoder)


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


metaDecoder : Json.Decoder Meta
metaDecoder =
    Json.map4 Meta
        (Json.field "title" Json.string)
        (Json.field "author" Json.string)
        (Json.field "targetWordCount" (Json.maybe Json.int))
        (Json.field "deadline" (Json.maybe dateDecoder))


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


tokenChildrenDecoder : Json.Decoder TokenChildren
tokenChildrenDecoder =
    -- This definition must be above `decodeProject`
    -- @see https://github.com/elm-lang/elm-compiler/issues/1560
    Json.lazy <| \_ -> Json.map TokenChildren (Json.list tokenDecoder)


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



-- ENCODERS


modelEncoder : Model -> Encode.Value
modelEncoder model =
    Encode.object
        [ ( "ui", uiEncoder model.ui )
        , ( "novel", novelEncoder model.novel )
        ]


uiEncoder : Ui -> Encode.Value
uiEncoder ui =
    Encode.object
        [ ( "binder", binderEncoder ui.binder )
        , ( "workspace", workspaceEncoder ui.workspace )
        , ( "activeFile", maybeIntEncoder ui.activeFile )
        , ( "activeView", viewTypeEncoder ui.activeView )
        ]


binderEncoder : Binder -> Encode.Value
binderEncoder binder =
    Encode.object
        [ ( "files", Encode.list (List.map fileEncoder binder.files) )
        , ( "editingName", maybeIntEncoder binder.editingName )
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


workspaceEncoder : Workspace -> Encode.Value
workspaceEncoder workspace =
    Encode.object
        [ ( "editingName", maybeIntEncoder workspace.editingName ) ]


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
            Encode.float (Date.toTime date)

        Nothing ->
            Encode.null


novelEncoder : Novel -> Encode.Value
novelEncoder novel =
    Encode.object
        [ ( "scenes", Encode.list (List.map sceneEncoder novel.scenes) )
        , ( "meta", metaEncoder novel.meta )
        ]


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


metaEncoder : Meta -> Encode.Value
metaEncoder meta =
    Encode.object
        [ ( "title", Encode.string meta.title )
        , ( "author", Encode.string meta.author )
        , ( "targetWordCount", maybeIntEncoder meta.targetWordCount )
        , ( "deadline", maybeDateEncoder meta.deadline )
        ]


tokenEncoder : Token -> Encode.Value
tokenEncoder token =
    Encode.object
        [ ( "token", tokenTypeEncoder token.token )
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

        Text value ->
            Encode.string ("text|" ++ value)



-- FACTORIES


markdownToTokens : String -> List Token
markdownToTokens string =
    let
        cleanString =
            Regex.replace Regex.All (Regex.regex "\n+$") (\_ -> "\n") string

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
                    False
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


tokensToPlainText : List Token -> String
tokensToPlainText tokens =
    tokens
        |> List.map tokenToPlainText
        |> List.foldl (++) ""


tokenToPlainText : Token -> String
tokenToPlainText token =
    let
        children =
            getTokenChildren token
    in
        case getTokenValue token of
            Just value ->
                String.trim value

            Nothing ->
                if List.isEmpty children then
                    ""
                else
                    tokensToPlainText children


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
