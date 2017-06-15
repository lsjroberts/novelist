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
import Json.Decode.Extra exposing ((|:))
import Regex
import Styles exposing (class)
import Task
import Time exposing (Time)
import Octicons as Icon
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


-- MODEL


type alias Model =
    Novel (Ui {})


init : ( Model, Cmd Msg )
init =
    ( mock
    , Cmd.none
    )


createModel : List File -> Maybe Int -> List Scene -> String -> String -> Maybe Int -> Maybe Date -> Model
createModel files activeFile scenes title author targetWordCount deadline =
    { files = files
    , editingFileName = Nothing
    , activeFile = activeFile
    , activeView = EditorView
    , scenes = scenes
    , title = title
    , author = author
    , targetWordCount = targetWordCount
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
    , targetWordCount = Nothing
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
    , activeFile = Just 0
    , activeView = EditorView
    , scenes =
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
    , title = "Title"
    , author = "Author"
    , targetWordCount = Nothing
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



-- VIEW


view : Model -> Html Msg
view model =
    let
        activeView =
            case model.activeView of
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
        [ viewMenu model.activeView
        , div
            [ class [ Styles.Editor ] ]
            [ viewBinder model.files
            , viewWorkspace model
            , viewInspector
            ]
        , viewFooter model
        ]


viewMenu : ViewType -> Html Msg
viewMenu activeView =
    let
        viewToggle =
            case activeView of
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


viewBinder : List File -> Html Msg
viewBinder files =
    div
        [ class [ Styles.BinderWrapper ] ]
        [ viewPanel
            [ viewBinderInner files ]
        ]


viewBinderInner : List File -> Html Msg
viewBinderInner files =
    let
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
        [ viewWorkspaceHeader model.title model.author
        , viewWorkspaceFile model.activeFile model.files model.scenes
        ]


viewWorkspaceHeader : String -> String -> Html Msg
viewWorkspaceHeader title author =
    div
        [ class [ Styles.WorkspaceHeader ] ]
        [ div [] [ Html.text title ]
        , div [ class [ Styles.WorkspaceHeaderAuthor ] ] [ Html.text author ]
        ]


viewWorkspaceFile : Maybe Int -> List File -> List Scene -> Html Msg
viewWorkspaceFile activeFile files scenes =
    let
        file =
            case activeFile of
                Just id ->
                    getById files id

                Nothing ->
                    Nothing

        sceneInner f =
            let
                scene =
                    getById scenes f.id
            in
                case scene of
                    Just s ->
                        viewScene scenes s

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


viewScene : List Scene -> Scene -> Html Msg
viewScene scenes scene =
    div [ class [ Styles.Scene ] ]
        [ viewSceneHeading scenes scene
        , viewSceneContent scene
          -- , viewSceneDebug model scene
        ]



-- viewSceneDebug : Model -> Scene -> Html Msg
-- viewSceneDebug model scene =
--     div [ class [ Styles.SceneDebug ] ]
--         (List.map (\c -> div [] [ Html.text (toString c) ]) scene.content)


viewSceneHeading : List Scene -> Scene -> Html Msg
viewSceneHeading scenes scene =
    div []
        [ viewSceneParentHeading scenes scene
        , input
            [ class [ Styles.SceneHeading ]
            , onInput (SetSceneName scene.id)
            , value scene.name
            ]
            []
        ]


viewSceneParentHeading : List Scene -> Scene -> Html Msg
viewSceneParentHeading scenes scene =
    case scene.parent of
        Just parentId ->
            case (getById scenes parentId) of
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


viewSceneContent : Scene -> Html Msg
viewSceneContent scene =
    div [ class [ Styles.SceneContent ] ]
        [ viewSceneContentEditor scene ]


viewSceneContentEditor : Scene -> Html Msg
viewSceneContentEditor scene =
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
viewToken token =
    case token.type_ of
        Paragraph ->
            viewTokenParagraph token

        Speech ->
            viewTokenSpeech token

        Emphasis ->
            viewTokenEmphasis token

        Text a ->
            viewTokenText token


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
    case token.type_ of
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


viewInspector : Html Msg
viewInspector =
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
        [ viewMenu model.activeView
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
    div [ class [ Styles.SettingsSection ] ]
        [ h2 [ class [ Styles.SettingsSectionHeader ] ] [ Html.text "Project" ]
        , viewFormInput
            "Title"
            (Just "The title of your story, displayed on the blah blah")
            (input
                [ class [ Styles.FormInputText ]
                , onInput SetTitle
                , value model.title
                ]
                []
            )
        , viewFormInput
            "Author"
            (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
            (input
                [ class [ Styles.FormInputText ]
                , onInput SetAuthor
                , value model.author
                ]
                []
            )
        , viewFormInput
            "Total Word Target"
            (Just "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
            (input
                [ class [ Styles.FormInputText ]
                , Html.Attributes.type_ "number"
                , Html.Attributes.placeholder "Default: 80000"
                , onInput SetTargetWordCount
                  -- use Maybe.Extra.mapDefault "" toString
                , model.targetWordCount
                    |> Maybe.withDefault 0
                    |> toString
                    |> value
                ]
                []
            )
        , viewFormInput
            ("Deadline ("
                ++ (timeUntilDeadline model.time model.deadline)
                ++ ")"
            )
            (Just
                ("Cras mattis consectetur purus sit amet fermentum.")
            )
            (input
                [ class [ Styles.FormInputText ]
                , Html.Attributes.type_ "date"
                , onInput SetDeadline
                ]
                []
            )
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
    | NewTime Time
    | OpenProject String
    | SetActiveFile Int
    | SetActiveView ViewType
    | SetSceneName Int String
    | SetSceneWordTarget Int String
    | SetAuthor String
    | SetDeadline String
    | SetTargetWordCount String
    | SetTitle String
    | ToggleFileExpanded Int
    | Write String


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        newModel =
            update msg model
    in
        ( newModel
        , setStorage (modelEncoder newModel)
        )



-- TODO: Review how I approach the update now the model is not nested


update : Msg -> Model -> Model
update msg model =
    case (Debug.log "msg" msg) of
        -- MAYBE DONT DO THIS
        GoToSettings _ ->
            model |> update (SetActiveView SettingsView)

        NewTime time ->
            { model | time = time }

        OpenProject project ->
            decodeProject project

        SetActiveFile id ->
            { model | activeFile = Just id }

        SetActiveView activeView ->
            { model | activeView = activeView }

        SetSceneName id name ->
            model
                |> setSceneName id name
                |> setFileName id name

        SetSceneWordTarget id targetString ->
            model |> setSceneWordTarget id (Result.withDefault 0 (String.toInt targetString))

        SetAuthor author ->
            { model | author = author }

        SetDeadline deadlineString ->
            let
                deadlineResult =
                    Date.fromString (deadlineString ++ " 00:00:00")
            in
                case deadlineResult of
                    Ok deadline ->
                        { model | deadline = Just deadline }

                    Err err ->
                        Debug.log err model

        SetTitle title ->
            { model | title = title }

        SetTargetWordCount targetString ->
            { model
                | targetWordCount =
                    targetString
                        |> String.toInt
                        |> Result.withDefault 0
                        |> Just
            }

        ToggleFileExpanded id ->
            model |> toggleFileExpanded id

        Write content ->
            case model.activeFile of
                Just id ->
                    model |> setSceneContent id (markdownToTokens content)

                Nothing ->
                    model


setFile : File -> Model -> Model
setFile file model =
    let
        files =
            model.files
                |> List.map
                    (\f ->
                        if f.id == file.id then
                            file
                        else
                            f
                    )
    in
        { model | files = files }


setFileName : Int -> String -> Model -> Model
setFileName id name model =
    let
        maybeFile =
            getById model.files id
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
            getById model.files id
    in
        case maybeFile of
            Just file ->
                model |> setFile { file | expanded = not file.expanded }

            Nothing ->
                model


setScene : Scene -> Model -> Model
setScene scene model =
    let
        scenes =
            model.scenes
                |> List.map
                    (\s ->
                        if s.id == scene.id then
                            scene
                        else
                            s
                    )
    in
        { model | scenes = scenes }


setSceneName : Int -> String -> Model -> Model
setSceneName id name model =
    let
        maybeScene =
            getById model.scenes id
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
            getById model.scenes id
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
            getById model.scenes id
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
        , Time.every Time.minute NewTime
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
    Json.succeed createModel
        |: (Json.field "files" (Json.list fileDecoder))
        |: (Json.field "activeFile" activeFileDecoder)
        |: (Json.field "scenes" (Json.list sceneDecoder))
        |: (Json.field "title" Json.string)
        |: (Json.field "author" Json.string)
        |: (Json.field "targetWordCount" (Json.maybe Json.int))
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
        [ ( "files", Encode.list (List.map fileEncoder model.files) )
        , ( "editingFileName", maybeIntEncoder model.editingFileName )
        , ( "activeFile", maybeIntEncoder model.activeFile )
        , ( "activeView", viewTypeEncoder model.activeView )
        , ( "scenes", Encode.list (List.map sceneEncoder model.scenes) )
        , ( "title", Encode.string model.title )
        , ( "author", Encode.string model.author )
        , ( "targetWordCount", maybeIntEncoder model.targetWordCount )
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

        Text value ->
            Encode.string ("text|" ++ value)



-- UTILS


timeUntilDeadline : Time -> Maybe Date -> String
timeUntilDeadline time deadline =
    case deadline of
        Just deadlineDate ->
            deadlineDate
                |> Date.toTime
                |> timeUntil time

        Nothing ->
            ""


timeUntil : Time -> Time -> String
timeUntil timeFrom timeTo =
    let
        timeDiff =
            timeTo - timeFrom

        timeSeconds =
            Time.inSeconds timeDiff

        timeMinutes =
            Time.inMinutes timeDiff

        timeHours =
            Time.inHours timeDiff

        timeDays =
            timeHours / 24.0

        timeWeeks =
            timeDays / 7.0

        format time unit =
            let
                floorTime =
                    floor time

                withUnit =
                    (toString floorTime) ++ " " ++ unit
            in
                if floorTime /= 1 then
                    withUnit ++ "s"
                else
                    withUnit
    in
        if timeWeeks < 4.0 then
            if timeDays < 1.0 then
                if timeHours < 1.0 then
                    if timeMinutes < 1.0 then
                        if timeSeconds < 1.0 then
                            "now"
                        else
                            format timeSeconds "second"
                    else
                        format timeMinutes "minute"
                else
                    format timeHours "hour"
            else
                format timeDays "day"
        else
            format timeWeeks "week"
