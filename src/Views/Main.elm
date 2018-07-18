module Views.Main exposing (view)

import Data.Activity
import Data.File exposing (..)
import Data.Model exposing (..)
import Dict exposing (Dict)
import Html5.DragDrop as DragDrop
import Html exposing (Html)
import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (Html, program)
import Messages exposing (..)
import Styles exposing (..)
import Views.ActivityBar
import Views.EditorMode
import Views.Explorer
import Views.MetaPanel
import Views.Palette
import Views.Workspace


view : Model -> Html Msg
view model =
    let
        activeFile =
            case model.activeFile of
                Just fileId ->
                    Dict.get fileId model.files

                Nothing ->
                    Nothing

        wordTarget =
            case activeFile of
                Just file ->
                    case file.fileType of
                        SceneFile scene ->
                            scene.wordTarget

                        _ ->
                            Nothing

                Nothing ->
                    Nothing

        dropId =
            DragDrop.getDropId model.dragDropFiles

        viewActivity =
            Views.ActivityBar.view model.activity

        viewEditorMode =
            Views.EditorMode.view

        viewExplorer =
            Views.Explorer.view model.activity model.files model.activeFile dropId model.search

        viewWorkspace =
            Views.Workspace.view model.files model.openFiles model.activeFile model.fileContents model.prose wordTarget

        viewMetaPanel =
            Views.MetaPanel.view model.files activeFile

        viewPalette =
            Views.Palette.view model.files model.palette

        viewSections =
            case model.activity of
                Just (Data.Activity.Editor) ->
                    [ viewActivity
                    , viewExplorer
                    , viewWorkspace
                    , viewPalette
                    ]

                _ ->
                    [ viewActivity
                    , viewExplorer
                    , viewWorkspace
                    , viewMetaPanel
                    , viewPalette
                    ]
    in
        Element.viewport (styleSheet model.theme) <|
            row Body
                [ height (percent 100) ]
                viewSections
