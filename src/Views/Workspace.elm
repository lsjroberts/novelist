module Views.Workspace exposing (view)

import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Set exposing (Set)
import Styles exposing (..)
import Maybe.Extra
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)


view files openFiles activeFile wordTarget =
    column NoStyle
        [ width fill ]
        [ viewTabBar files openFiles activeFile
        , viewEditor files activeFile
        , viewStatusBar wordTarget
        ]


viewTabBar files openFiles activeFile =
    let
        tab fileId =
            viewTab Icon.file
                fileId
                (Maybe.Extra.unwrap "" (\f -> f.name) (Dict.get fileId files))
                (Maybe.Extra.unwrap False (\a -> fileId == a) activeFile)
    in
        row (Workspace TabBar) [] <|
            (openFiles |> List.map tab)


viewTab icon fileId name isActive =
    row
        (Workspace Tab)
        [ paddingTop <| paddingScale 2
        , paddingBottom <| paddingScale 2
        , paddingLeft <| paddingScale 3
        , paddingRight <| paddingScale 3
        , spacing <| paddingScale 1
        , vary Active isActive
        ]
        [ smallIcon
            |> icon
            |> html
            |> el NoStyle []
        , el NoStyle [ onClick (OpenFile fileId) ] <| text name
        , smallIcon
            |> Icon.color "grey"
            |> Icon.x
            |> html
            |> el NoStyle [ onClick (CloseFile fileId) ]
        ]


viewEditor : Dict FileId File -> Maybe FileId -> Element Styles Variations Msg
viewEditor files activeFile =
    let
        maybeFile =
            Maybe.Extra.unwrap Nothing (\fileId -> Dict.get fileId files) activeFile

        viewFile =
            case maybeFile of
                Just file ->
                    case file.fileType of
                        SceneFile scene ->
                            --viewMonacoEditor activeFile
                            el Placeholder [ width fill, height fill ] empty

                        CharacterFile character ->
                            viewCharacterEditor file character

                        _ ->
                            el Placeholder [ width fill, height fill ] empty

                Nothing ->
                    el Placeholder [ width fill, height fill ] empty
    in
        column NoStyle
            [ width fill
            , height fill
            , paddingTop <| paddingScale 4
            , paddingRight <| paddingScale 6
            , paddingBottom <| paddingScale 4
            , paddingLeft <| paddingScale 6
            ]
            [ viewFile ]


viewMonacoEditor activeFile =
    case activeFile of
        Just fileId ->
            html <|
                Html.iframe
                    [ Html.Attributes.src ("http://localhost:8080/editor/editor.html?file=/stubs/PrideAndPrejudice.novel/manuscript/" ++ (toString fileId) ++ ".txt")
                    , Html.Attributes.style
                        [ ( "width", "100%" )
                        , ( "height", "100%" )
                        , ( "border", "none" )
                        ]
                    ]
                    []

        Nothing ->
            el NoStyle [] empty


viewCharacterEditor : File -> Character -> Element Styles Variations Msg
viewCharacterEditor file character =
    let
        input label value =
            Input.text InputText
                [ padding <| paddingScale 2 ]
                { onChange = (\s -> NoOp)
                , value = value
                , label = Input.hiddenLabel label
                , options = []
                }

        multiline label value =
            Input.multiline InputText
                [ padding <| paddingScale 2, height (px (fontScale 8)) ]
                { onChange = (\s -> NoOp)
                , value = value
                , label = Input.hiddenLabel label
                , options = []
                }
    in
        column (Workspace CharacterEditor)
            [ width fill, height fill, spacing <| spacingScale 3 ]
            [ h1 (Workspace CharacterEditorTitle) [] <|
                Input.text InputText
                    [ padding (paddingScale 2)
                    , vary Light True
                    ]
                    { onChange = (\s -> NoOp)
                    , value = file.name
                    , label = Input.hiddenLabel "Name"
                    , options = []
                    }
            , column NoStyle
                [ spacing <| spacingScale 1, width (percent 80), paddingXY (paddingScale 2) 0 ]
              <|
                [ el NoStyle [] <| text "Also known as:" ]
                    ++ (List.map (input "Alias") character.aliases)
                    ++ [ input "New Alias" "" ]
            , column NoStyle
                [ spacing <| spacingScale 1, width (percent 80), paddingXY (paddingScale 2) 0 ]
                [ el NoStyle [] <| text "Description"
                , multiline "Description" ""
                ]
            , column NoStyle
                [ spacing <| spacingScale 1, width (percent 80), paddingXY (paddingScale 2) 0 ]
                [ el NoStyle [] <| text "Relationships"
                  -- , multiline "Description" ""
                ]
            ]


viewStatusBar maybeWordTarget =
    row (StatusBar StatusBarWrapper)
        [ alignRight
        , spacing <| spacingScale 1
        , paddingXY (paddingScale 2) (paddingScale 1)
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
