module Workspace.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)
import Workspace.Header.View
import Scene.View


root : Html msg
root =
    div
        [ styles
            [ width (pct 60)
            , padding (px 34)
            ]
        ]
        [ Workspace.Header.View.root
        , Scene.View.root
        ]
