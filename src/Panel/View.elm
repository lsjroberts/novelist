module Panel.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)


root : List (Html msg) -> Html msg
root children =
    div
        [ styles
            [ backgroundColor (rgba 245 245 245 1.0)
            , height (pct 100)
            , padding (px 34)
            ]
        ]
        children
