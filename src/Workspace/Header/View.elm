module Workspace.Header.View exposing (root)

import Html exposing (Html, div)
import Workspace.Styles exposing (class)


root : Html msg
root =
    div
        [ class [ Workspace.Styles.Header ] ]
        [ div [] [ Html.text "Title" ]
        , div [ class [ Workspace.Styles.HeaderAuthor ] ] [ Html.text "Author" ]
        ]
