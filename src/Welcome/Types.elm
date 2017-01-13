module Welcome.Types exposing (..)

import Animation
import Animation.Messenger


type alias Model =
    { projects : List String
    , buttonAnimation : Animation.Messenger.State Msg
    , buttonIsHovered : Bool
    }


type Msg
    = NoOp
    | ToggleHoverButton
    | ClickButton
    | Animate Animation.Msg
