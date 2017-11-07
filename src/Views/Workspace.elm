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
        [ paddingTop <| innerScale 2
        , paddingBottom <| innerScale 2
        , paddingLeft <| innerScale 3
        , paddingRight <| innerScale 3
        , spacing <| innerScale 1
        , vary Active isActive
        ]
        [ smallIcon
            |> icon
            |> html
            |> el NoStyle []
        , el NoStyle [ onClick (Ui <| OpenFile fileId) ] <| text name
        , smallIcon
            |> Icon.color "grey"
            |> Icon.x
            |> html
            |> el NoStyle [ onClick (Ui <| CloseFile fileId) ]
        ]


viewEditor : Dict FileId File -> Maybe FileId -> Element Styles Variations Msg
viewEditor files activeFile =
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
                            --viewMonacoEditor activeFile
                            el Placeholder [ width fill, height fill ] empty

                        CharacterFile character ->
                            viewCharacterEditor fileId file character

                        _ ->
                            el Placeholder [ width fill, height fill ] empty

                _ ->
                    el Placeholder [ width fill, height fill ] empty
    in
        column NoStyle
            [ width fill
            , height fill
            , paddingTop <| innerScale 4
            , paddingRight <| innerScale 6
            , paddingBottom <| innerScale 4
            , paddingLeft <| innerScale 6
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


viewCharacterEditor : FileId -> File -> Character -> Element Styles Variations Msg
viewCharacterEditor fileId file character =
    let
        input label value =
            Input.text InputText
                [ padding <| innerScale 2 ]
                { onChange = (\s -> NoOp)
                , value = value
                , label = Input.hiddenLabel label
                , options = []
                }

        multiline label value =
            Input.multiline InputText
                [ padding <| innerScale 2, height (px (fontScale 8)) ]
                { onChange = (\s -> NoOp)
                , value = value
                , label = Input.hiddenLabel label
                , options = []
                }
    in
        column (Workspace CharacterEditor)
            [ width fill, height fill, spacing <| outerScale 3 ]
            [ el (Workspace CharacterEditorTitle) [] <|
                Input.text InputText
                    [ padding (innerScale 2)
                    , vary Light True
                    ]
                    { onChange = Data << RenameFile fileId
                    , value = file.name
                    , label = Input.hiddenLabel "Name"
                    , options = [ Input.textKey file.name ]
                    }
            , column NoStyle
                [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
              <|
                [ el NoStyle [] <| text "Also known as:" ]
                    ++ (List.map (input "Alias") character.aliases)
                    ++ [ input "New Alias" "" ]
            , column NoStyle
                [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
                [ el NoStyle [] <| text "Description"
                , multiline "Description" ""
                ]
            , column NoStyle
                [ spacing <| outerScale 1, width (percent 80), paddingXY (innerScale 2) 0 ]
                [ el NoStyle [] <| text "Relationships"
                  -- , multiline "Description" ""
                ]
            ]


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
