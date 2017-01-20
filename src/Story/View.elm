module Story.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, span, h1)
import Html.Attributes exposing (class)
import Icons.View exposing (icon)
import Styles exposing (styles)
import Story.Types exposing (..)
import Scene.Types
import Scene.View


root : Model -> Html Msg
root model =
    div [ styles [ height (pct 100) ] ]
        [ div
            [ styles
                [ height (pct 100) ]
            ]
            [ viewManuscript model
            , viewScene model.scene
            , viewInspector model.scene
            ]
        ]


viewMenu : Html Msg
viewMenu =
    div
        [ styles
            [ height (px 100)
            , borderTop3 (px 1) solid (hex "999796")
            , borderBottom3 (px 1) solid (hex "999796")
            , backgroundColor (hex "f2f2f2")
            ]
        ]
        [ Html.text "menu" ]


viewManuscript : Model -> Html Msg
viewManuscript model =
    div
        [ styles
            [ position fixed
            , top (px 0)
            , left (px 0)
            , padding (px 32)
            , width (pct 20)
            , height (pct 100)
            , overflowY scroll
              -- , backgroundColor (hex "f5f5f5")
            , backgroundColor (hex "e2e7e9")
            , color (hex "48809e")
            ]
        ]
        [ h1
            [ styles
                [ marginBottom (em 1)
                , fontSize (px 18)
                , fontWeight (int 400)
                ]
            ]
            [ Html.text "Manuscript" ]
        , div [] <|
            List.map manuscriptScene model.scenes
        ]


viewInspector : Scene.Types.Model -> Html Msg
viewInspector scene =
    div
        [ styles
            [ padding2 (em 8) (em 0)
            , fontSize (px 1)
            , position fixed
            , top (px 0)
            , right (px 0)
            , width (pct 2.3)
            , height (pct 100)
            , overflowY scroll
            ]
        ]
        [ Scene.View.root scene |> Html.map SceneMsg
        ]


viewScene : Scene.Types.Model -> Html Msg
viewScene scene =
    div
        [ styles
            [ padding2 (em 8) (em 0)
            , position fixed
            , top (px 0)
            , left (pct 20)
            , width (pct 72)
            , height (pct 100)
            , overflowY scroll
              -- , boxShadow5 (px 0) (px 3) (px 2) (px 2) (rgba 0 0 0 0.1)
            , overflow scroll
            , backgroundColor (hex "e8ebed")
              -- , color (hex "6197b3")
            , color (hex "04202e")
            ]
        ]
        [ div
            [ styles
                [ margin2 (px 0) auto
                , maxWidth (em 34)
                ]
            ]
            [ Scene.View.root scene |> Html.map SceneMsg ]
        ]


manuscriptScene : Scene.Types.Model -> Html Msg
manuscriptScene scene =
    if Scene.Types.hasChildren scene then
        manuscriptFolder scene
    else
        manuscriptFile scene


manuscriptFolder : Scene.Types.Model -> Html Msg
manuscriptFolder scene =
    div
        [ styles
            [ marginBottom (em 1)
            , fontSize (px 14)
            ]
        ]
    <|
        [ div
            [ styles
                [ padding2 (em 0.5) (em 0)
                , cursor pointer
                ]
            ]
            [ icon [ styles [ paddingRight (em 0.8) ] ] 14 "file-directory"
            , Html.text scene.name
            ]
        ]
            ++ (scene
                    |> Scene.Types.children
                    |> List.map manuscriptScene
               )


manuscriptFile : Scene.Types.Model -> Html Msg
manuscriptFile scene =
    div [ styles [ padding4 (em 0.5) (em 0) (em 0.5) (em 1) ] ]
        [ icon [ styles [ paddingRight (em 0.8) ] ] 14 "file"
        , Html.text scene.name
        ]
