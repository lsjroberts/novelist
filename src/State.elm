module State exposing (init, update, subscriptions)

import Set
import Response exposing (..)
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
        router =
            Router "welcome" (Set.fromList [ "welcome", "wizard", "scene" ])

        ( scene, _ ) =
            Scene.State.init

        ( welcome, _ ) =
            Welcome.State.init

        ( wizard, _ ) =
            Wizard.State.init
    in
        ( Model router scene welcome wizard, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute route ->
            let
                router =
                    model.router
            in
                ( { model | router = { router | route = route } }, Cmd.none )

        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg

        WelcomeMsg welcomeMsg ->
            case welcomeMsg of
                Welcome.Types.StartWizard ->
                    update (SetRoute "wizard") model

                _ ->
                    Welcome.State.update welcomeMsg model.welcome
                        |> mapModel (\x -> { model | welcome = x })
                        |> mapCmd WelcomeMsg

        WizardMsg wizardMsg ->
            Wizard.State.update wizardMsg model.wizard
                |> mapModel (\x -> { model | wizard = x })
                |> mapCmd WizardMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SceneMsg (Scene.State.subscriptions model.scene)
        , Sub.map WelcomeMsg (Welcome.State.subscriptions model.welcome)
        , Sub.map WizardMsg (Wizard.State.subscriptions model.wizard)
        ]
