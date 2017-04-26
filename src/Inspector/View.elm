module Inspector.View exposing (root)

import Html exposing (Html, div)
import Inspector.Styles exposing (class)


root : Html msg
root =
    div
        [ class [ Inspector.Styles.Root ] ]
        []
