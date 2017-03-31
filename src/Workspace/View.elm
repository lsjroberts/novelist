module Workspace.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div)
import Styles exposing (..)
import Workspace.Types exposing (..)
import Workspace.Header.View
import Scene.State
import Scene.View


root : Html Msg
root =
    let
        ( scene, _ ) =
            Scene.State.init
    in
        div
            [ styles
                [ width (pct 60)
                , padding (px 34)
                ]
            ]
            [ Workspace.Header.View.root
            , Scene.View.root scene |> Html.map SceneMsg
            ]
