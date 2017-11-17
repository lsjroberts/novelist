module Views.Workspace exposing (view)

import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Styles exposing (..)
import Maybe.Extra
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)
import Views.Welcome
import Views.Workspace.Character
import Views.Workspace.Folder


view files openFiles activeFile fileContents wordTarget =
    case activeFile of
        Just _ ->
            column NoStyle
                [ width fill ]
                [ viewTabBar files openFiles activeFile
                , viewEditor files activeFile fileContents
                , viewStatusBar wordTarget
                ]

        Nothing ->
            Views.Welcome.view


viewTabBar files openFiles activeFile =
    let
        tab fileId =
            case Dict.get fileId files of
                Just file ->
                    viewTab fileId file (Maybe.Extra.unwrap False (\a -> fileId == a) activeFile)

                Nothing ->
                    el NoStyle [] empty
    in
        row (Workspace TabBar) [ id "workspace-tab-bar" ] <|
            (openFiles |> List.map tab)


viewTab fileId file isActive =
    row
        (Workspace Tab)
        [ paddingTop <| innerScale 2
        , paddingBottom <| innerScale 2
        , paddingLeft <| innerScale 3
        , paddingRight <| innerScale 3
        , spacing <| innerScale 1
        , vary Active isActive
        ]
        [ smallIcon
            |> fileIcon file.fileType
            |> html
            |> el NoStyle []
        , el NoStyle [ onClick (Ui <| OpenFile fileId) ] <| text file.name
        , smallIcon
            |> Icon.color "grey"
            |> Icon.x
            |> html
            |> el NoStyle [ onClick (Ui <| CloseFile fileId) ]
        ]


viewEditor : Dict FileId File -> Maybe FileId -> Maybe String -> Element Styles Variations Msg
viewEditor files activeFile fileContents =
    let
        maybeFile =
            Maybe.Extra.unwrap
                Nothing
                (\fileId -> Dict.get fileId files)
                activeFile

        viewFile =
            case ( activeFile, maybeFile ) of
                ( Just fileId, Just file ) ->
                    case file.fileType of
                        SceneFile scene ->
                            viewMonacoEditor fileContents

                        CharacterFile character ->
                            Views.Workspace.Character.view (characters files) fileId file character

                        FolderFile _ ->
                            Views.Workspace.Folder.view files fileId file

                        _ ->
                            el Placeholder [ width fill, height fill ] empty

                _ ->
                    el Placeholder [ width fill, height fill ] empty
    in
        viewFile


viewMonacoEditor maybeFileContents =
    let
        monaco =
            case maybeFileContents of
                Just fileContents ->
                    el NoStyle
                        [ width fill
                        , height fill
                        , id "monaco-editor"
                        , attribute "contents" fileContents
                        ]
                        empty

                Nothing ->
                    el NoStyle [] empty
    in
        el (Workspace SceneEditor)
            [ width fill
            , height fill
            , paddingTop <| innerScale 4
            , paddingRight <| innerScale 6
            , paddingBottom <| innerScale 4
            , paddingLeft <| innerScale 6
            ]
            monaco


viewStatusBar maybeWordTarget =
    row (StatusBar StatusBarWrapper)
        [ alignRight
        , spacing <| outerScale 1
        , paddingXY (innerScale 2) (innerScale 1)
        ]
        [ case maybeWordTarget of
            Just wordTarget ->
                el NoStyle [] <| text ("500 / " ++ (toString wordTarget) ++ " words")

            Nothing ->
                el NoStyle [] <| text "500 words"
        , el NoStyle [] <| text "2500 characters"
        , case maybeWordTarget of
            Just wordTarget ->
                el NoStyle [] <| text ((toString (100 * 500 / (toFloat wordTarget))) ++ "%")

            Nothing ->
                el NoStyle [] empty
        ]
