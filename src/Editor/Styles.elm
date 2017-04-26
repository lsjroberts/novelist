module Editor.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root
    | View
    | Binder
    | Inspector


css =
    (stylesheet << namespace "editor")
        [ Css.class Root [ height (pct 100) ]
        , Css.class View
            [ displayFlex
            , property "justify-content" "space-between"
            , height (pct 100)
            ]
        , Css.class Binder
            [ width (pct 20) ]
        , Css.class Inspector
            [ width (pct 20) ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "editor"
