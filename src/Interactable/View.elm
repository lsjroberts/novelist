module Interactable.View exposing (attributes)

import Animation
import Html exposing (Html, button, text)
import Html.Events exposing (onMouseOver, onMouseOut, onMouseDown)
import Interactable.Types exposing (..)


attributes : Model -> List (Html.Attribute Msg)
attributes model =
    Animation.render model.animation
        ++ [ onMouseOver ToggleMouseOver
           , onMouseOut ToggleMouseOver
           , onMouseDown Click
           ]
