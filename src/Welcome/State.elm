module Welcome.State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Color
import Response exposing (..)
import Time
import Welcome.Types exposing (..)
import Interactable.Types
import Interactable.State


init : ( Model, Cmd Msg )
init =
    ( { projects = []
      , startButton =
            Interactable.Types.clickable
                { defaultStyle = [ Animation.backgroundColor (Color.rgb 143 63 175) ]
                , mouseOverStyle = [ Animation.backgroundColor (Color.rgb 156 86 184) ]
                , activeStyle = [ Animation.backgroundColor (Color.rgb 26 175 93) ]
                , interpolation =
                    Animation.spring
                        { stiffness = 400
                        , damping = 23
                        }
                }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartWizard ->
            ( model, Cmd.none )

        InteractableMsg msgTypesInteractable ->
            Interactable.State.update msgTypesInteractable model.startButton
                |> mapModel (\x -> { model | startButton = x })
                |> mapCmd InteractableMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map InteractableMsg (Interactable.State.subscriptions model.startButton)
        ]
