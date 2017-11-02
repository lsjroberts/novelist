module Views.MetaPanel exposing (view)

import Data.File exposing (..)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Input as Input
import Styles exposing (..)
import Maybe.Extra
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (smallIcon)


view files activeFile =
    case activeFile of
        Just file ->
            case file.fileType of
                CharacterFile character ->
                    viewCharacterMeta file character

                SceneFile scene ->
                    viewSceneMeta files scene

                _ ->
                    el NoStyle [] empty

        Nothing ->
            el NoStyle [] empty


viewCharacterMeta file character =
    column (Meta MetaWrapper)
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 4 ]
        [ column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text file.name ]
        ]


viewSceneMeta files scene =
    column (Meta MetaWrapper)
        [ width (px 300), padding <| paddingScale 3, spacing <| spacingScale 4 ]
        [ column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Synopsis"
            , Input.multiline InputText
                [ paddingXY (paddingScale 2) (paddingScale 2)
                , minHeight (px (fontScale 9))
                ]
                { onChange = (\s -> NoOp)
                , value = scene.synopsis
                , label = Input.hiddenLabel "Synopsis"
                , options = []
                }
            , el (Meta MetaStatus)
                [ alignLeft
                , paddingXY (paddingScale 2) (paddingScale 1)
                ]
              <|
                text scene.status
            , row NoStyle
                [ spacing <| spacingScale 1 ]
              <|
                List.map (\tag -> el (Meta MetaTag) [ paddingXY (paddingScale 2) (paddingScale 1) ] <| text tag) scene.tags
            ]
        , viewSceneCharacters files scene.characters
        , column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Locations"
            , row NoStyle
                [ spacing <| paddingScale 1 ]
                [ smallIcon
                    |> Icon.globe
                    |> html
                    |> el NoStyle []
                , text "Longbourn House"
                ]
            ]
        , column NoStyle
            [ spacing <| spacingScale 1 ]
            [ el (Meta MetaHeading) [] <| text "Word Target"
            , Input.text InputText
                [ paddingXY (paddingScale 2) (paddingScale 2) ]
                { onChange = SetWordTarget
                , value = Maybe.Extra.unwrap "" toString scene.wordTarget
                , label = Input.hiddenLabel "Word Target"
                , options = []
                }
            ]
        ]


viewSceneCharacters files characters =
    let
        viewCharacter characterId sceneCharacter =
            let
                maybeCharacterFile =
                    Dict.get characterId files
            in
                case maybeCharacterFile of
                    Just characterFile ->
                        row NoStyle
                            [ spacing <| paddingScale 1 ]
                            [ smallIcon
                                |> Icon.gistSecret
                                |> html
                                |> el NoStyle []
                            , text characterFile.name
                            , if sceneCharacter.speaking then
                                smallIcon
                                    |> Icon.megaphone
                                    |> html
                                    |> el NoStyle []
                              else
                                el NoStyle [] empty
                            ]

                    Nothing ->
                        el NoStyle [] empty
    in
        column NoStyle
            [ spacing <| spacingScale 1 ]
            ([ el (Meta MetaHeading) [] <| text "Characters" ]
                ++ (Dict.values <|
                        Dict.map
                            viewCharacter
                            characters
                   )
            )
