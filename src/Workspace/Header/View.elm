module Workspace.Header.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)


root : Html msg
root =
    div
        [ styles
            [ displayFlex
            , property "justify-content" "space-between"
            ]
        ]
        [ div [] [ Html.text "Title" ]
        , div [ styles [ textAlign right ] ] [ Html.text "Author" ]
        ]
