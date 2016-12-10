module Styles exposing (..)

import Css exposing (Mixin)
import Html exposing (Attribute)
import Html.Attributes exposing (style)


styles : List Mixin -> Attribute msg
styles =
    Css.asPairs >> style
