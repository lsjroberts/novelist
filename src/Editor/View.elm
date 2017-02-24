module Editor.View exposing (root)

import Css exposing (..)
import Styles exposing (styles)
import Html exposing (Html, div, h1)
import Html.Events exposing (onClick)
import Editor.Types exposing (..)
import Menu.View
import Binder.View
import Inspector.View
import Panel.View
import Workspace.View


root : Model -> Html Msg
root model =
    div [ styles [ height (pct 100) ] ]
        [ div
            [ styles
                [ height (pct 100)
                ]
            ]
            [ Menu.View.root
            , div
                [ styles
                    [ displayFlex
                    , property "justify-content" "space-between"
                    , height (pct 100)
                    ]
                ]
                [ binderPanel
                , Workspace.View.root
                , inspectorPanel
                ]
            ]
        ]


binderPanel : Html msg
binderPanel =
    div
        [ styles
            [ width (pct 20) ]
        ]
        [ Panel.View.root [ Binder.View.root ] ]


inspectorPanel : Html msg
inspectorPanel =
    div
        [ styles
            [ width (pct 20) ]
        ]
        [ Panel.View.root [ Inspector.View.root ] ]
