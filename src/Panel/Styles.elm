module Panel.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root


css =
    (stylesheet << namespace "panel")
        [ Css.class Root
            [ backgroundColor (rgba 245 245 245 1.0)
            , height (pct 100)
            , padding (px 34)
            ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "panel"
