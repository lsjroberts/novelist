module Views.Editor exposing (view)

import Html exposing (..)
import Data.Model exposing (Model, getTotalWordCount)
import Messages exposing (Msg(..))
import Styles exposing (class)
import Views.Binder
import Views.Common exposing (viewMenu)
import Views.Footer
import Views.Inspector
import Views.Workspace


view : Model -> Html Msg
view model =
    div [ class [ Styles.EditorWrapper ] ]
        [ viewMenu model.activeView
        , div
            [ class [ Styles.Editor ] ]
            [ Views.Binder.view model.files
            , Views.Workspace.view model
            , Views.Inspector.view model.deadline model.totalWordTarget (getTotalWordCount model)
            ]
        , Views.Footer.view model
        ]
