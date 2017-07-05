module Views.Main exposing (view)

import Html exposing (..)
import Data.Model exposing (Model)
import Data.Ui exposing (ViewType(..))
import Messages exposing (Msg)
import Styles exposing (class)
import Views.Editor
import Views.Settings


view : Model -> Html Msg
view model =
    let
        activeView =
            case model.activeView of
                EditorView ->
                    Views.Editor.view

                SettingsView ->
                    Views.Settings.view
    in
        div [ class [ Styles.Root ] ]
            [ activeView (Debug.log "model" model) ]
