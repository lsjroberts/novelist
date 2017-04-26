module Workspace.Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


type CssClasses
    = Root
    | Header
    | HeaderAuthor


css =
    (stylesheet << namespace "workspace")
        [ Css.class Root
            [ width (pct 60)
            , padding (px 34)
            ]
        , Css.class Header
            [ displayFlex
            , property "justify-content" "space-between"
            ]
        , Css.class HeaderAuthor
            [ textAlign right ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "workspace"
