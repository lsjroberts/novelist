module Frame.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (styles)


root : Html a -> Html a
root child =
    div [ styles [ height (pct 100) ] ] [ child ]


menuBar =
    div
        [ styles
            [ property "background" "linear-gradient(180deg, #d9d9d9, #d2d2d2)"
            , padding4 (px 1) (px 0) (px 1) (px 0)
            , height (pct 100)
            , fontFamilies [ "'Slabo 27px'" ]
            , textAlign center
            , color (hex "333")
            ]
        ]
        [ Html.text "Novelist" ]
