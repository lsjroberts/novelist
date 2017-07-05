module Views.Binder exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import Octicons as Icon
import Data.File exposing (File, getFileChildren, getRootFiles, getSceneFiles)
import Data.Model exposing (Model)
import Styles exposing (class)
import Messages exposing (Msg(..))
import Views.Common exposing (viewPanel)


view : List File -> Html Msg
view files =
    div
        [ class [ Styles.BinderWrapper ] ]
        [ viewPanel
            [ viewBinderInner files ]
        ]


viewBinderInner : List File -> Html Msg
viewBinderInner files =
    let
        manuscript =
            files
                |> getRootFiles
                |> getSceneFiles
                |> List.map (viewBinderFile files)
    in
        div [ class [ Styles.Binder ] ] <|
            [ h2 [] [ Html.text "Manuscript" ] ]
                ++ manuscript


viewBinderFile : List File -> File -> Html Msg
viewBinderFile allFiles file =
    let
        children =
            getFileChildren allFiles file

        hasChildren =
            not <| List.isEmpty children

        nested =
            if file.expanded then
                children |> List.map (viewBinderFile allFiles)
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
            else
                [ Styles.BinderFile ]

        itemClass =
            if hasChildren then
                [ Styles.BinderHeader ]
            else
                []

        wrapperIcon =
            if hasChildren then
                if file.expanded then
                    span [ class [ Styles.BinderDirectoryIcon ] ] [ Icon.defaultChevrondown ]
                else
                    span [ class [ Styles.BinderDirectoryIcon ] ] [ Icon.defaultChevronright ]
            else
                span [] []

        itemIcon =
            if hasChildren then
                span [ class [ Styles.BinderIcon ] ] [ Icon.defaultFiledirectory ]
            else
                span [ class [ Styles.BinderIcon ] ] [ Icon.defaultFile ]
    in
        div [ class wrapperClass ] <|
            [ h3
                [ class itemClass, onClick onClickMsg ]
                [ wrapperIcon, itemIcon, Html.text file.name ]
            , div [ class [ Styles.BinderEntries ] ] nested
            ]
