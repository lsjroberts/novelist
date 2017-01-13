module State exposing (init, update, subscriptions)

import Response exposing (..)
import Types exposing (..)
import Scene.State
import Scene.Types
import Welcome.State
import Welcome.Types


init : ( Model, Cmd Msg )
init =
    let
        ( scene, _ ) =
            Scene.State.init

        ( welcome, _ ) =
            Welcome.State.init
    in
        ( Model scene welcome, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SceneMsg sceneMsg ->
            Scene.State.update sceneMsg model.scene
                |> mapModel (\x -> { model | scene = x })
                |> mapCmd SceneMsg

        WelcomeMsg welcomeMsg ->
            Welcome.State.update welcomeMsg model.welcome
                |> mapModel (\x -> { model | welcome = x })
                |> mapCmd WelcomeMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WelcomeMsg (Welcome.State.subscriptions model.welcome)
        , Sub.map SceneMsg (Scene.State.subscriptions model.scene)
        ]
