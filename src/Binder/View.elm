module Binder.View exposing (root)

import Html exposing (Html, div, h2, h3)
import Html.Events exposing (onClick)
import Binder.Styles exposing (class, classList)
import Binder.Types exposing (..)
import Editor.Types


root : List Editor.Types.File -> Html Msg
root files =
    div [ class [ Binder.Styles.Root ] ] <|
        (files
            |> List.filter (\file -> file.parentId == -1)
            |> List.map (viewFile files)
        )


viewFile : List Editor.Types.File -> Editor.Types.File -> Html Msg
viewFile files file =
    let
        children =
            files |> List.filter (\f -> f.parentId == file.id)

        hasChildren =
            not (List.isEmpty children)

        nested =
            if hasChildren then
                [ div [ class [ Binder.Styles.Nested ] ]
                    (children
                        |> List.map (viewFile files)
                    )
                , viewAddFile file.id "Add"
                ]
            else
                [ viewAddFile file.id "Add"
                ]
    in
        div [] <|
            [ h2
                [ class [ Binder.Styles.File ]
                , onClick
                    (if hasChildren then
                        NoOp
                     else
                        OpenFile file.id
                    )
                ]
                [ Html.text file.name ]
            ]
                ++ nested


viewAddFile : Int -> String -> Html Msg
viewAddFile folderId label =
    div
        []
        [ h3 [ onClick (AddFile folderId) ] [ Html.text label ] ]
