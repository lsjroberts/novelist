module Views.Explorer exposing (view)

import Data.Activity exposing (..)
import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Styles exposing (..)
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)


view activity files activeFile =
    column (Explorer ExplorerWrapper)
        [ width (px 240)
          -- , spacing <| spacingScale 3
        ]
        [ viewExplorerHeader activity
        , viewExplorerFolder activity files activeFile
        , row (Explorer ExplorerFile)
            [ paddingXY (paddingScale 3) (paddingScale 1)
            , spacing <| paddingScale 1
            , vary Active False
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


viewExplorerHeader activity =
    let
        header =
            case activity of
                Manuscript ->
                    viewManuscriptExplorerHeader

                Characters ->
                    viewCharactersExplorerHeader

                _ ->
                    [ el NoStyle [] empty ]
    in
        row NoStyle
            [ paddingXY (paddingScale 3) (paddingScale 2)
            , spacing <| spacingScale 1
            ]
            header


viewManuscriptExplorerHeader =
    [ el NoStyle [] <| text "Manuscript"
    , row NoStyle
        [ alignRight, spacing <| spacingScale 1 ]
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


viewCharactersExplorerHeader =
    [ el NoStyle [] <| text "Characters"
    , row NoStyle
        [ alignRight, spacing <| spacingScale 1 ]
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
--         [ spacing <| spacingScale 2 ]
--         [ el NoStyle [] <| text label
--         , viewExplorerFolder items
--         ]


viewExplorerFolder activity files maybeActive =
    let
        filterByActivity fileId file =
            case file.fileType of
                SceneFile _ ->
                    activity == Manuscript

                CharacterFile _ ->
                    activity == Characters

                _ ->
                    False

        viewFile fileId file =
            viewExplorerFile
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
            Dict.values (Dict.map viewFile (Dict.filter filterByActivity files))


viewExplorerFile isActive fileId name =
    row (Explorer ExplorerFile)
        [ paddingXY (paddingScale 3) (paddingScale 1)
        , spacing <| paddingScale 1
        , onClick (OpenFile fileId)
        , vary Active isActive
        ]
        [ smallIcon
            |> Icon.file
            |> html
            |> el NoStyle []
        , text name
        ]
