module Styles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Html.CssHelpers


styles : List Mixin -> Attribute msg
styles =
    Css.asPairs >> style


type CssClasses
    = Root


css =
    (stylesheet << namespace "app")
        [ Css.class Root
            [ fontFamilies [ "Quicksand" ]
            , color (hex "#333333")
            , overflow hidden
            , height (pct 100)
            ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace "app"
