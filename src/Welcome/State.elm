module Welcome.State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Color
import Time
import Welcome.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { projects = []
      , buttonAnimation = Animation.styleWith buttonInterpolation buttonDefaultStyle
      , buttonIsHovered = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleHoverButton ->
            if model.buttonIsHovered then
                ( { model
                    | buttonAnimation = buttonUnHover model.buttonAnimation
                    , buttonIsHovered = False
                  }
                , Cmd.none
                )
            else
                ( { model
                    | buttonAnimation = buttonHover model.buttonAnimation
                    , buttonIsHovered = True
                  }
                , Cmd.none
                )

        ClickButton ->
            animateButton model buttonClick

        Animate time ->
            let
                ( newAnimation, cmds ) =
                    Animation.Messenger.update time model.buttonAnimation
            in
                ( { model
                    | buttonAnimation = newAnimation
                  }
                , cmds
                )


animateButton model animation =
    ( { model
        | buttonAnimation = animation model.buttonAnimation
      }
    , Cmd.none
    )


buttonInterpolation =
    Animation.spring
        { stiffness = 400
        , damping = 23
        }


buttonTo =
    Animation.toWith buttonInterpolation


buttonDefaultStyle =
    [ Animation.backgroundColor (Color.rgb 143 63 175) ]


buttonHoveredStyle =
    [ Animation.backgroundColor (Color.rgb 156 86 184) ]


buttonClickedStyle =
    [ Animation.backgroundColor (Color.rgb 26 175 93) ]


buttonHover =
    Animation.interrupt
        [ buttonTo buttonDefaultStyle
        , buttonTo buttonHoveredStyle
        ]


buttonUnHover =
    Animation.interrupt
        [ buttonTo buttonDefaultStyle
        ]


buttonClick =
    Animation.interrupt
        [ buttonTo buttonHoveredStyle
        , buttonTo buttonClickedStyle
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.buttonAnimation ]
