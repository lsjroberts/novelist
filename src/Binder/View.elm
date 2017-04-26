module Binder.View exposing (root)

import Html exposing (Html, div, h2, h3)
import Binder.Styles exposing (class)
import Binder.Types exposing (..)


root : List File -> Html msg
root folders =
    div [ class [ Binder.Styles.Root ] ] <|
        List.map viewFolder folders


viewFolder : File -> Html msg
viewFolder folder =
    div [ class [ Binder.Styles.Folder ] ] <|
        [ h2 [] [ Html.text folder.name ] ]
            ++ (List.map viewFile (fileChildren folder))


viewFile : File -> Html msg
viewFile file =
    div
        [ class [ Binder.Styles.File ] ]
        [ h3 [] [ Html.text file.name ] ]
