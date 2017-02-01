module Types exposing (..)

import Animation
import Animation.Messenger
import Set exposing (Set)
import Welcome.Types
import Wizard.Types
import Editor.Types


type alias Model =
    { route : Route
    , nextRoute : Maybe Route
    , routeTransition : Animation.Messenger.State Msg
    , welcome : Welcome.Types.Model
    , wizard : Wizard.Types.Model
    , editor : Editor.Types.Model
    }


type Route
    = WelcomeRoute
    | WizardRoute
    | EditorRoute


type Msg
    = SetRoute Route
    | ChangeRoute Route
    | RouteTransition Animation.Msg
    | EditorMsg Editor.Types.Msg
    | WelcomeMsg Welcome.Types.Msg
    | WizardMsg Wizard.Types.Msg
