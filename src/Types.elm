module Types exposing (..)

import Animation
import Animation.Messenger
import Set exposing (Set)
import Scene.Types
import Welcome.Types
import Wizard.Types


type alias Model =
    { route : Route
    , nextRoute : Maybe Route
    , routeTransition : Animation.Messenger.State Msg
    , scene : Scene.Types.Model
    , welcome : Welcome.Types.Model
    , wizard : Wizard.Types.Model
    }


type Route
    = WelcomeRoute
    | WizardRoute
    | SceneRoute


type Msg
    = SetRoute Route
    | ChangeRoute Route
    | RouteTransition Animation.Msg
    | SceneMsg Scene.Types.Msg
    | WelcomeMsg Welcome.Types.Msg
    | WizardMsg Wizard.Types.Msg
