module Story.Types exposing (..)

import Scene.Types


type alias Model =
    { scene : Scene.Types.Model
    , scenes : List Scene.Types.Model
    }


type Route
    = SceneRoute String


type Msg
    = SceneMsg Scene.Types.Msg
