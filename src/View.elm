module View exposing (root)

import Animation
import Css exposing (..)
import Html exposing (Html, div, span)
import Types exposing (..)
import Scene.Types
import Scene.View
import Welcome.Types
import Welcome.View
import Wizard.Types
import Wizard.View
import Styles exposing (..)


root : Model -> Html Msg
root model =
    div
        [ styles
            [ padding (px 30)
            , fontFamilies [ "Quicksand" ]
            , overflowX hidden
            ]
        ]
        [ slidingView model ]


activeView : Model -> Html Msg
activeView model =
    view model.route model


slidingView : Model -> Html Msg
slidingView model =
    let
        page p =
            div
                [ styles
                    [ display inlineBlock
                    , verticalAlign top
                    , width (pct 50)
                    ]
                ]
                [ p ]
    in
        div
            (Animation.render model.routeTransition
                ++ [ styles
                        [ width (pct 200) ]
                   ]
            )
            [ view model.route model |> page
            , maybeView model.nextRoute model |> page
            ]


view : Route -> Model -> Html Msg
view route model =
    case route of
        WelcomeRoute ->
            welcomeView model

        WizardRoute ->
            wizardView model

        SceneRoute ->
            sceneView model


maybeView : Maybe Route -> Model -> Html Msg
maybeView maybeRoute model =
    case maybeRoute of
        Just route ->
            view route model

        Nothing ->
            span [] []


welcomeView model =
    Welcome.View.root model.welcome |> Html.map WelcomeMsg


wizardView model =
    Wizard.View.root model.wizard |> Html.map WizardMsg


sceneView model =
    Scene.View.root model.scene |> Html.map SceneMsg
