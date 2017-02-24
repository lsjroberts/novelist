module Inspector.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)


root : Html msg
root =
    div
        [ styles
            [ height (pct 100) ]
        ]
        []
