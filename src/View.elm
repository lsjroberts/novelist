module View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
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
            ]
        ]
        [ activeView model ]


activeView : Model -> Html Msg
activeView model =
    case model.router.route of
        "welcome" ->
            Welcome.View.root model.welcome |> Html.map WelcomeMsg

        "wizard" ->
            Wizard.View.root model.wizard |> Html.map WizardMsg

        "scene" ->
            Scene.View.root model.scene |> Html.map SceneMsg

        _ ->
            div [] [ Html.text "An error occurred, please restart Novelist" ]
