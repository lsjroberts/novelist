module Views.Explorer exposing (view)

import Data.Activity exposing (..)
import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Styles exposing (..)
import Maybe.Extra
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)


view activity files activeFile =
    column (Explorer ExplorerWrapper)
        [ width (px 240)
          -- , spacing <| outerScale 3
        ]
        [ viewHeader activity
        , viewFolder activity files activeFile
        , row (Explorer ExplorerFile)
            [ paddingXY (innerScale 3) (innerScale 1)
            , spacing <| innerScale 1
            , vary Active False
            , onClick (Data AddScene)
            ]
            [ smallIcon
                |> Icon.file
                |> html
                |> el NoStyle []
            , smallIcon
                |> Icon.plus
                |> html
                |> el NoStyle []
            ]
        ]


viewHeader activity =
    let
        header =
            case activity of
                Manuscript ->
                    viewManuscriptHeader

                Characters ->
                    viewCharactersHeader

                _ ->
                    [ el NoStyle [] empty ]
    in
        row NoStyle
            [ paddingXY (innerScale 3) (innerScale 2)
            , spacing <| outerScale 1
            ]
            header


viewManuscriptHeader =
    [ el NoStyle [] <| text "Manuscript"
    , row NoStyle
        [ alignRight, spacing <| outerScale 1 ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el (Explorer ExplorerHeaderAction) [ onClick (Data AddScene) ]
        , smallIcon
            |> Icon.fileDirectory
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        ]
    ]


viewCharactersHeader =
    [ el NoStyle [] <| text "Characters"
    , row NoStyle
        [ alignRight, spacing <| outerScale 1 ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        , smallIcon
            |> Icon.fileDirectory
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        ]
    ]



-- viewExplorerGroup label items =
--     column (Explorer Group)
--         [ spacing <| outerScale 2 ]
--         [ el NoStyle [] <| text label
--         , viewExplorerFolder items
--         ]


viewFolder activity files maybeActive =
    let
        filterByActivity fileId file =
            case file.fileType of
                SceneFile _ ->
                    activity == Manuscript

                CharacterFile _ ->
                    activity == Characters

                _ ->
                    False

        viewFileInner fileId file =
            viewFile
                (case maybeActive of
                    Just active ->
                        active == fileId

                    Nothing ->
                        False
                )
                fileId
                file.name
    in
        column (Explorer ExplorerFolder) [] <|
            Dict.values (Dict.map viewFileInner (Dict.filter filterByActivity files))


viewFile isActive fileId name =
    row (Explorer ExplorerFile)
        [ paddingXY (innerScale 3) (innerScale 1)
        , spacing <| innerScale 1
        , onClick <| Ui <| OpenFile fileId
        , vary Active isActive
        ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el NoStyle []
        , if isActive then
            Input.text InputText
                []
                { onChange = Data << RenameFile fileId
                , value = name
                , label = Input.hiddenLabel "Scene Name"
                , options = []
                }
          else
            text name
        ]
