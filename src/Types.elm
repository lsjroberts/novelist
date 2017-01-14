module Types exposing (..)

import Set exposing (Set)
import Scene.Types
import Welcome.Types
import Wizard.Types


type alias Model =
    { router : Router
    , scene : Scene.Types.Model
    , welcome : Welcome.Types.Model
    , wizard : Wizard.Types.Model
    }


type alias Router =
    { route : String
    , routes : Set String
    }


type Msg
    = SetRoute String
    | SceneMsg Scene.Types.Msg
    | WelcomeMsg Welcome.Types.Msg
    | WizardMsg Wizard.Types.Msg
