module Views.Workspace exposing (view)

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
import Data.Decode exposing (childrenContentDecoder)
import Data.File exposing (File, FileType(..))
import Data.Model exposing (Model)
import Data.Scene exposing (Scene)
import Data.Token
    exposing
        ( Token
        , TokenChildren(..)
        , TokenType(..)
        , getClosingTag
        , getOpeningTag
        , getShowTags
        , markdownToTokens
        )
import Styles exposing (class)
import Messages exposing (Msg(..))
import Utils.List exposing (getById)
import Views.Common exposing (viewPanel)


view : Model -> Html Msg
view model =
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

                    PlanFile ->
                        div [] []

                    CharacterFile ->
                        div [] []

                    LocationFile ->
                        div [] []

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
        [ --viewSceneParentHeading scenes scene
          input
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
                , on "blur" (Json.map (Write scene.id) childrenContentDecoder)
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

        CommentTag _ ->
            viewTokenComment token

        CharacterTag _ ->
            viewTokenCharacter token

        LocationTag _ ->
            viewTokenLocation token

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


viewTokenComment : Token -> Html Msg
viewTokenComment token =
    viewTokenInner token.children
        |> span []


viewTokenCharacter : Token -> Html Msg
viewTokenCharacter token =
    viewTokenInner token.children
        |> span []


viewTokenLocation : Token -> Html Msg
viewTokenLocation token =
    viewTokenInner token.children
        |> span []


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
