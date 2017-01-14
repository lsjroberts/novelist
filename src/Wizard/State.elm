module Wizard.State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Color
import Dict
import Response exposing (..)
import Wizard.Types exposing (..)
import Interactable.Types
import Interactable.State


init : ( Model, Cmd Msg )
init =
    ( { fields =
            Dict.fromList
                [ ( "title", "Pride And Prejudice" )
                , ( "planningMethod", "Story Grid" )
                ]
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
        SetField field value ->
            ( { model | fields = Dict.insert field value model.fields }, Cmd.none )

        StartScene ->
            ( model, Cmd.none )

        StartButtonInteraction msgTypesInteractable ->
            Interactable.State.update msgTypesInteractable model.startButton
                |> mapModel (\x -> { model | startButton = x })
                |> mapCmd StartButtonInteraction


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map StartButtonInteraction (Interactable.State.subscriptions model.startButton)
        ]
