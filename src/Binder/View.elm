module Binder.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, h2)
import Styles exposing (..)


root : Html msg
root =
    div
        [ styles
            [ height (pct 100) ]
        ]
        [ folder "Manuscript" []
        , folder "Plans" []
        , folder "Notes" []
        , folder "Characters" []
        , folder "Locations" []
        ]


folder : String -> List String -> Html msg
folder title files =
    div [] <|
        [ h2 [] [ Html.text title ] ]
            ++ (List.map (\fs -> folder fs []) files)
