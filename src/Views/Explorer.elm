module Views.Explorer exposing (view)

import Data.Activity as Activity
import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Styles exposing (..)
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)


view maybeActivity files activeFile search =
    case maybeActivity of
        Just activity ->
            column (Explorer ExplorerWrapper)
                [ width (px 240)
                  -- , spacing <| outerScale 3
                ]
                [ viewHeader activity
                , viewExplorer activity files activeFile search
                ]

        Nothing ->
            el NoStyle [] empty


viewHeader activity =
    let
        header =
            case activity of
                Activity.Manuscript ->
                    viewManuscriptHeader

                Activity.Characters ->
                    viewCharactersHeader

                Activity.Locations ->
                    viewLocationsHeader

                Activity.Search ->
                    viewSearchHeader

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
            |> Icon.gistSecret
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        , smallIcon
            |> Icon.fileDirectory
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        ]
    ]


viewLocationsHeader =
    [ el NoStyle [] <| text "Locations"
    , row NoStyle
        [ alignRight, spacing <| outerScale 1 ]
        [ smallIcon
            |> Icon.globe
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        , smallIcon
            |> Icon.fileDirectory
            |> html
            |> el (Explorer ExplorerHeaderAction) []
        ]
    ]


viewSearchHeader =
    [ el NoStyle [] <| text "Search" ]


viewExplorer activity files maybeActive search =
    case activity of
        Activity.Search ->
            viewSearch files search

        _ ->
            viewFolder activity files maybeActive


viewFolder activity files maybeActive =
    let
        filterByActivity fileId file =
            case file.fileType of
                SceneFile _ ->
                    activity == Activity.Manuscript

                CharacterFile _ ->
                    activity == Activity.Characters

                LocationFile ->
                    activity == Activity.Locations

        viewFileInner fileId file =
            viewFile
                (case maybeActive of
                    Just active ->
                        active == fileId

                    Nothing ->
                        False
                )
                fileId
                file.fileType
                file.name
    in
        column (Explorer ExplorerFolder) [] <|
            (Dict.values (Dict.map viewFileInner (Dict.filter filterByActivity files)))
                ++ [ viewAddFile activity ]


viewFile isActive fileId fileType name =
    row (Explorer ExplorerFile)
        [ paddingXY (innerScale 3) (innerScale 1)
        , spacing <| innerScale 1
        , onClick <| Ui <| OpenFile fileId
        , vary Active isActive
        ]
        [ smallIcon
            |> fileIcon fileType
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


viewAddFile activity =
    let
        ( msg, icon ) =
            case activity of
                Activity.Characters ->
                    ( Data AddCharacter, Icon.gistSecret )

                Activity.Manuscript ->
                    ( Data AddScene, Icon.file )

                Activity.Locations ->
                    ( Data AddLocation, Icon.globe )

                _ ->
                    ( NoOp, Icon.file )
    in
        row (Explorer ExplorerFile)
            [ paddingXY (innerScale 3) (innerScale 1)
            , spacing <| innerScale 1
            , vary Active False
            , onClick msg
            ]
            [ smallIcon
                |> icon
                |> html
                |> el NoStyle []
            , smallIcon
                |> Icon.plus
                |> html
                |> el NoStyle []
            ]


viewSearch files maybeSearch =
    column NoStyle
        [ paddingXY (innerScale 3) (innerScale 1)
        , spacing <| outerScale 3
        ]
        [ Input.text InputText
            [ padding <| innerScale 2 ]
            { onChange = (Ui << Messages.Search)
            , value =
                case maybeSearch of
                    Just search ->
                        search.term

                    Nothing ->
                        ""
            , label = Input.hiddenLabel "Scene Name"
            , options = []
            }
        , column NoStyle
            [ spacing <| innerScale 1 ]
            [ Input.checkbox NoStyle
                []
                { onChange = (\c -> NoOp)
                , checked = True
                , label = el NoStyle [] (text "Manuscript")
                , options = []
                }
            , Input.checkbox NoStyle
                []
                { onChange = (\c -> NoOp)
                , checked = True
                , label = el NoStyle [] (text "Characters")
                , options = []
                }
            ]
        , case maybeSearch of
            Just search ->
                let
                    viewContents =
                        case search.result.contents of
                            Just contents ->
                                viewSearchResults files contents

                            Nothing ->
                                [ el NoStyle [] empty ]
                in
                    column NoStyle [ spacing <| outerScale 2 ] viewContents

            Nothing ->
                el NoStyle [] empty
        ]


viewSearchResults files contents =
    let
        fileMatches fileId matches =
            case Dict.get fileId files of
                Just file ->
                    column NoStyle
                        [ spacing <| innerScale 1 ]
                        (([ row NoStyle
                                [ spacing <| innerScale 1 ]
                                [ smallIcon
                                    |> fileIcon file.fileType
                                    |> html
                                    |> el NoStyle []
                                , el NoStyle [] <| text file.name
                                ]
                          ]
                         )
                            ++ (List.map item matches)
                        )

                Nothing ->
                    el NoStyle [] empty

        item snippet =
            el NoStyle [ paddingLeft <| innerScale 2 ] <| text snippet
    in
        Dict.values <| Dict.map fileMatches contents
