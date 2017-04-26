module Feature.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root


css =
    (stylesheet << namespace "feature")
        [ Css.class Root []
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "feature"
