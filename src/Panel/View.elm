module Panel.View exposing (root)

import Html exposing (Html, div)
import Panel.Styles exposing (class)


root : List (Html msg) -> Html msg
root children =
    div
        [ class [ Panel.Styles.Root ] ]
        children
