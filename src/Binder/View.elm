module Binder.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, h2, h3)
import Styles exposing (..)
import Binder.Types exposing (..)


root : List File -> Html msg
root folders =
    div [ styles [ height (pct 100) ] ] <|
        List.map viewFolder folders


viewFolder : File -> Html msg
viewFolder folder =
    div [ styles [ marginBottom (em 1) ] ] <|
        [ h2 [] [ Html.text folder.name ] ]
            ++ (List.map viewFile (fileChildren folder))


viewFile : File -> Html msg
viewFile file =
    div
        [ styles
            [ padding (em 1)
            ]
        ]
        [ h3 [] [ Html.text file.name ] ]
