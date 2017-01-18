module Types exposing (..)

import Animation
import Animation.Messenger
import Set exposing (Set)
import Story.Types
import Welcome.Types
import Wizard.Types


type alias Model =
    { route : Route
    , nextRoute : Maybe Route
    , routeTransition : Animation.Messenger.State Msg
    , story : Story.Types.Model
    , welcome : Welcome.Types.Model
    , wizard : Wizard.Types.Model
    }


type Route
    = WelcomeRoute
    | WizardRoute
    | StoryRoute Story.Types.Route


type Msg
    = SetRoute Route
    | ChangeRoute Route
    | RouteTransition Animation.Msg
    | StoryMsg Story.Types.Msg
    | WelcomeMsg Welcome.Types.Msg
    | WizardMsg Wizard.Types.Msg
