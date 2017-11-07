module Views.Palette exposing (..)

import Data.File exposing (..)
import Data.Palette exposing (..)
import Dict
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Styles exposing (..)
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (..)


view files paletteStatus =
    case paletteStatus of
        Closed ->
            el NoStyle [] empty

        Files search ->
            viewFiles files search


viewFiles files search =
    screen <|
        el (Palette PaletteWrapper)
            [ center
            , width (percent 50)
            , paddingXY (innerScale 2) (innerScale 1)
            ]
        <|
            column NoStyle
                [ spacing <| outerScale 1 ]
                [ Input.text InputText
                    [ padding <| innerScale 2 ]
                    { onChange = Ui << SearchName
                    , value = search
                    , label = Input.hiddenLabel "Search by name"
                    , options = []
                    }
                , column NoStyle
                    []
                  <|
                    Dict.values <|
                        Dict.map
                            (\fileId file ->
                                row (Palette PaletteItem)
                                    [ padding <| innerScale 1
                                    , spacing <| innerScale 1
                                    , onClick (Ui <| OpenFile fileId)
                                    ]
                                    [ smallIcon
                                        |> (case file.fileType of
                                                SceneFile _ ->
                                                    Icon.file

                                                CharacterFile _ ->
                                                    Icon.gistSecret

                                                _ ->
                                                    Icon.file
                                           )
                                        |> html
                                        |> el NoStyle []
                                    , text file.name
                                    ]
                            )
                            (filterFiles files search)
                ]


filterFiles files search =
    files
        |> Dict.filter
            (\fileId file ->
                String.contains
                    (String.toLower search)
                    (String.toLower file.name)
            )
