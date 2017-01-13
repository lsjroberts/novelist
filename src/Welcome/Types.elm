module Welcome.Types exposing (..)

import Animation
import Animation.Messenger
import Interactable.Types


type alias Model =
    { projects : List String
    , startButton : Interactable.Types.Model
    }


type Msg
    = InteractableMsg Interactable.Types.Msg
