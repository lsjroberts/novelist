module Interactable.State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Time
import Interactable.Types exposing (..)


init : Model -> ( Model, Cmd Msg )
init model =
    ( model
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleMouseOver ->
            if model.isMouseOver then
                mouseOut |> animate { model | isMouseOver = False }
            else
                mouseOver |> animate { model | isMouseOver = True }

        Click ->
            click |> animate model

        Animate time ->
            let
                ( newAnimation, cmds ) =
                    Animation.Messenger.update time model.animation
            in
                ( { model | animation = newAnimation }
                , cmds
                )


animate model fn =
    ( { model | animation = fn model model.animation }
    , Cmd.none
    )


mouseOver { defaultStyle, mouseOverStyle } =
    Animation.interrupt
        [ Animation.set defaultStyle
        , Animation.to mouseOverStyle
        ]


mouseOut { defaultStyle } =
    Animation.interrupt
        [ Animation.set defaultStyle
        ]


click { mouseOverStyle, activeStyle } =
    Animation.interrupt
        [ Animation.set mouseOverStyle
        , Animation.to activeStyle
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.animation ]
