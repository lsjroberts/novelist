module Views.Welcome exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Messages exposing (..)
import Styles exposing (..)
import Octicons as Icon
import Views.Icons exposing (largeIcon)


view =
    column (Welcome WelcomeWrapper)
        [ width fill
        , spacing <| outerScale 5
        , paddingXY (innerScale 6) (innerScale 5)
        ]
        [ h1 (Welcome WelcomeTitle) [] <| text "Novelist"
        , row NoStyle
            [ width fill ]
            [ column NoStyle
                [ spacing <| outerScale 5, width fill ]
                [ column NoStyle
                    [ spacing <| outerScale 2 ]
                    [ h2 (Welcome WelcomeHeading) [] <| text "Start"
                    , row Link
                        [ spacing <| innerScale 2
                        , verticalCenter
                        , onClick (Data AddScene)
                        ]
                        [ largeIcon
                            |> Icon.file
                            |> html
                            |> el NoStyle []
                        , text "Add a new scene"
                        ]
                    ]
                , column NoStyle
                    [ spacing <| outerScale 2 ]
                    [ h2 (Welcome WelcomeHeading) [] <| text "Recent Projects"
                    , column NoStyle
                        []
                        [ row Link
                            [ spacing <| innerScale 2
                            , verticalCenter
                            , onClick (Data AddScene)
                            ]
                            [ largeIcon
                                |> Icon.book
                                |> html
                                |> el NoStyle []
                            , text "Pride and Prejudice"
                            ]
                        ]
                    ]
                , column NoStyle
                    [ spacing <| outerScale 2 ]
                    [ h2 (Welcome WelcomeHeading) [] <| text "Help"
                    , row Link
                        [ spacing <| innerScale 2
                        , verticalCenter
                        , onClick (Data AddScene)
                        ]
                        [ text "novelist.io/help"
                        ]
                    ]
                ]
            , column NoStyle
                [ spacing <| outerScale 5, width fill ]
                [ column NoStyle
                    [ spacing <| outerScale 2 ]
                    [ h2 (Welcome WelcomeHeading) [] <| text "Customise"
                    , row Link
                        [ spacing <| innerScale 2
                        , verticalCenter
                        , onClick (Data AddScene)
                        ]
                        [ largeIcon
                            |> Icon.rocket
                            |> html
                            |> el NoStyle []
                        , text "Themes"
                        ]
                    ]
                ]
            ]
        ]
