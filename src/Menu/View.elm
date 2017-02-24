module Menu.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)


root : Html msg
root =
    div
        [ styles
            [ backgroundColor (rgba 235 235 235 1.0)
            , height (px 38)
            ]
        ]
        []
