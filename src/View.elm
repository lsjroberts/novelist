module View exposing (root)

import Animation
import Css exposing (..)
import Html exposing (Html, div, span)
import Types exposing (..)
import Frame.View
import Editor.Types
import Editor.View
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
            [ activeView model
            ]


activeView : Model -> Html Msg
activeView model =
    view model.route model


view : Route -> Model -> Html Msg
view route model =
    case route of
        EditorRoute ->
            editorView model


maybeView : Maybe Route -> Model -> Html Msg
maybeView maybeRoute model =
    case maybeRoute of
        Just route ->
            view route model

        Nothing ->
            span [] []


editorView model =
    Editor.View.root model.editor |> Html.map EditorMsg
