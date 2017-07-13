module Views.Binder exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import Octicons as Icon
import Data.File exposing (File, getFileChildren, getRootFiles, getSceneFiles)
import Data.Model exposing (Model)
import Styles exposing (class)
import Messages exposing (Msg(..))
import Views.Common exposing (viewPanel)


view : List File -> Maybe Int -> Html Msg
view files maybeActiveFile =
    div
        [ class [ Styles.BinderWrapper ] ]
        [ viewPanel
            [ viewBinderInner files maybeActiveFile ]
        ]


viewBinderInner : List File -> Maybe Int -> Html Msg
viewBinderInner files maybeActiveFile =
    let
        manuscript =
            files
                |> getRootFiles
                |> getSceneFiles
                |> List.map (viewBinderFile files maybeActiveFile)
    in
        div [ class [ Styles.Binder ] ] <|
            [ h2
                [ class [ Styles.BinderGroupTitle ] ]
                [ span [ class [ Styles.BinderGroupIcon ] ]
                    [ Icon.defaultOptions
                        |> Icon.color "white"
                        |> Icon.size 28
                        |> Icon.repo
                    ]
                , Html.text "Manuscript"
                ]
            ]
                ++ manuscript


viewBinderFile : List File -> Maybe Int -> File -> Html Msg
viewBinderFile allFiles maybeActiveFile file =
    let
        children =
            getFileChildren allFiles file

        hasChildren =
            not <| List.isEmpty children

        nested =
            if file.expanded then
                children |> List.map (viewBinderFile allFiles maybeActiveFile)
            else
                []

        onClickMsg =
            if hasChildren then
                ToggleFileExpanded file.id
            else
                SetActiveFile file.id

        wrapperClass =
            if hasChildren then
                [ Styles.BinderDirectory ]
            else if isActiveFile then
                [ Styles.BinderFile, Styles.BinderFileActive ]
            else
                [ Styles.BinderFile ]

        itemClass =
            if hasChildren then
                [ Styles.BinderHeader ]
            else
                []

        isActiveFile =
            case maybeActiveFile of
                Just activeFile ->
                    activeFile == file.id

                Nothing ->
                    False

        wrapperIcon =
            if hasChildren then
                if file.expanded then
                    span [ class [ Styles.BinderDirectoryIcon ] ]
                        [ Icon.defaultOptions |> Icon.size 18 |> Icon.chevronDown ]
                else
                    span [ class [ Styles.BinderDirectoryIcon ] ]
                        [ Icon.defaultOptions |> Icon.size 18 |> Icon.chevronRight ]
            else
                span [] []

        itemIcon =
            if hasChildren then
                span [ class [ Styles.BinderIcon ] ]
                    [ Icon.defaultOptions |> Icon.size 18 |> Icon.fileDirectory
                    ]
            else if isActiveFile then
                span [ class [ Styles.BinderIcon ] ]
                    [ Icon.defaultOptions |> Icon.size 18 |> Icon.color "white" |> Icon.file ]
            else
                span [ class [ Styles.BinderIcon ] ]
                    [ Icon.defaultOptions |> Icon.size 18 |> Icon.file ]
    in
        div [ class wrapperClass ] <|
            [ h3
                [ class itemClass, onClick onClickMsg ]
                [ wrapperIcon, itemIcon, Html.text file.name ]
            , div [ class [ Styles.BinderEntries ] ] nested
            ]
