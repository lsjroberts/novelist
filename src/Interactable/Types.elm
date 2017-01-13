module Interactable.Types exposing (..)

import Animation
import Animation.Messenger
import Color


type alias Model =
    { animation : Animation.Messenger.State Msg
    , interpolation : Animation.Interpolation
    , defaultStyle : List Animation.Property
    , mouseOverStyle : List Animation.Property
    , activeStyle : List Animation.Property
    , isMouseOver : Bool
    }


noInterpolation =
    Animation.spring { stiffness = 0, damping = 0 }


noAnimation =
    Animation.styleWith noInterpolation []


noStyle =
    []


static : Model
static =
    Model noAnimation noInterpolation noStyle noStyle noStyle False


hoverable { interpolation, defaultStyle, mouseOverStyle } =
    { animation = Animation.styleWith interpolation defaultStyle
    , interpolation = interpolation
    , defaultStyle = defaultStyle
    , mouseOverStyle = mouseOverStyle
    , activeStyle = noStyle
    , isMouseOver = False
    }


clickable { interpolation, defaultStyle, mouseOverStyle, activeStyle } =
    { animation = Animation.styleWith interpolation defaultStyle
    , interpolation = interpolation
    , defaultStyle = defaultStyle
    , mouseOverStyle = mouseOverStyle
    , activeStyle = activeStyle
    , isMouseOver = False
    }


type Msg
    = ToggleMouseOver
    | Click
    | Animate Animation.Msg
