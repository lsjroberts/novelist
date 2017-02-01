module Story.Types exposing (..)

import Scene.Types


type alias Model =
    { scenes : List Scene.Types.Model
    }


type Route
    = SceneRoute String


type Msg
    = SceneMsg Scene.Types.Msg
