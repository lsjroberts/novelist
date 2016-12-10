module Welcome.Types exposing (..)

import Animation


type alias Model =
    { projects : List String
    , style : Animation.State
    }


type Msg
    = NoOp
