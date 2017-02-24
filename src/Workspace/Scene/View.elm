module Workspace.Scene.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, h1)
import Styles exposing (..)


root : Html msg
root =
    div
        [ styles
            [ paddingTop (px 72)
            , fontFamilies [ "Cochin" ]
            ]
        ]
        [ heading
        , content
        ]


heading : Html msg
heading =
    h1
        [ styles
            [ marginBottom (em 1)
            , fontSize (em 3)
            , textAlign center
            ]
        ]
        [ Html.text "Heading" ]


content : Html msg
content =
    div
        [ styles
            [ maxWidth (em 31)
            , margin auto
            , fontSize (em (18 / 16))
            , lineHeight (num 1.4)
            ]
        ]
        [ Html.text
            ("Sed posuere consectetur est at lobortis. Praesent commodo"
                ++ "cursus magna, vel scelerisque nisl consectetur et. Integer posuere"
                ++ "erat a ante venenatis dapibus posuere velit aliquet. Integer"
                ++ "posuere erat a ante venenatis dapibus posuere velit aliquet. Cras"
                ++ "justo odio, dapibus ac facilisis in, egestas eget quam. Donec"
                ++ "ullamcorper nulla non metus auctor fringilla. Praesent commodo"
            )
        ]
