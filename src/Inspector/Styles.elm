module Inspector.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root


css =
    (stylesheet << namespace "inspector")
        [ Css.class Root [ height (pct 100) ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "inspector"
