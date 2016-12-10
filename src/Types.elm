module Types exposing (..)

import Scene.Types
import Welcome.Types


type alias Model =
    { scene : Scene.Types.Model
    , welcome : Welcome.Types.Model
    }


type Msg
    = SceneMsg Scene.Types.Msg
    | WelcomeMsg Welcome.Types.Msg
