module View exposing (root)

import Animation
import Css exposing (..)
import Html exposing (Html, div, span)
import Types exposing (..)
import Frame.View
import Story.Types
import Story.View
import Welcome.Types
import Welcome.View
import Wizard.Types
import Wizard.View
import Styles exposing (..)


root : Model -> Html Msg
root model =
    Frame.View.root <|
        div
            [ styles
                [ fontFamilies [ "Quicksand" ]
                , color (hex "#333333")
                , overflow hidden
                , height (pct 100)
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
                    , height (pct 100)
                    ]
                ]
                [ p ]
    in
        div
            (Animation.render model.routeTransition
                ++ [ styles
                        [ width (pct 200)
                        , height (pct 100)
                        ]
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

        StoryRoute storyRoute ->
            storyView model


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


storyView model =
    Story.View.root model.story |> Html.map StoryMsg
