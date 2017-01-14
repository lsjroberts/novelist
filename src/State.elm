module State exposing (init, update, subscriptions)

import Animation
import Animation.Messenger
import Response exposing (..)
import Set
import Types exposing (..)
import Scene.State
import Scene.Types
import Welcome.State
import Welcome.Types
import Wizard.State
import Wizard.Types


init : ( Model, Cmd Msg )
init =
    let
        ( scene, _ ) =
            Scene.State.init

        ( welcome, _ ) =
            Welcome.State.init

        ( wizard, _ ) =
            Wizard.State.init
    in
        ( { route = WelcomeRoute
          , nextRoute = Nothing
          , routeTransition = (Animation.style [])
          , scene = scene
          , welcome = welcome
          , wizard = wizard
          }
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute route ->
            ( { model
                | route = route
                , nextRoute = Nothing
              }
            , Cmd.none
            )

        ChangeRoute route ->
            ( { model
                | route =
                    case model.nextRoute of
                        Just r ->
                            r

                        Nothing ->
                            WelcomeRoute
                , nextRoute = Just route
                , routeTransition = nextRouteAnimation model.routeTransition
              }
            , Cmd.none
            )

        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg

        WelcomeMsg welcomeMsg ->
            case welcomeMsg of
                Welcome.Types.StartWizard ->
                    update (ChangeRoute WizardRoute) model

                _ ->
                    Welcome.State.update welcomeMsg model.welcome
                        |> mapModel (\x -> { model | welcome = x })
                        |> mapCmd WelcomeMsg

        WizardMsg wizardMsg ->
            case wizardMsg of
                Wizard.Types.StartScene ->
                    update (ChangeRoute SceneRoute) model

                _ ->
                    Wizard.State.update wizardMsg model.wizard
                        |> mapModel (\x -> { model | wizard = x })
                        |> mapCmd WizardMsg

        RouteTransition time ->
            let
                ( newAnimation, cmds ) =
                    Animation.Messenger.update time model.routeTransition
            in
                ( { model | routeTransition = newAnimation }
                , cmds
                )


routeFromStyle =
    [ Animation.marginLeft (Animation.percent 0) ]


routeToStyle =
    [ Animation.marginLeft (Animation.percent -100) ]


nextRouteAnimation =
    Animation.queue
        [ Animation.set routeFromStyle
        , Animation.to routeToStyle
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription RouteTransition [ model.routeTransition ]
        , Sub.map SceneMsg (Scene.State.subscriptions model.scene)
        , Sub.map WelcomeMsg (Welcome.State.subscriptions model.welcome)
        , Sub.map WizardMsg (Wizard.State.subscriptions model.wizard)
        ]
