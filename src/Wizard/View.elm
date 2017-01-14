module Wizard.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, span, h1, label, input)
import Html.Attributes
import Html.Events exposing (onClick)
import Styles exposing (styles)
import Wizard.Types exposing (..)


root : Model -> Html Msg
root model =
    div
        [ styles
            [ displayFlex
              -- , flex3 0 1 auto
            , flexDirection column
              -- , alignItems center
            ]
        ]
        [ h1
            [ styles
                [ marginBottom (px 62)
                , fontSize (px 48)
                , fontWeight (int 400)
                , letterSpacing (px 8)
                , color (hex "333333")
                ]
            ]
            [ Html.text "Novelist" ]
        , formInput "What is your story called?" (textInput model.title)
        , formInput "How do you like to plan?"
            (choiceInput (SetPlanningMethod)
                [ "Story Grid"
                , "Snowflake"
                , "I don't need a plan!"
                ]
                model.planningMethod
            )
        ]


formInput labelText child =
    div
        [ styles
            [ marginBottom (em 2)
            ]
        ]
        [ label
            [ styles
                [ display block
                , fontSize (em 1)
                ]
            ]
            [ Html.text labelText ]
        , child
        ]


textInput value =
    input
        [ Html.Attributes.value value
        , styles
            [ display block
            , marginTop (em 0.5)
            , border (px 0)
            , outline none
            , width (pct 100)
            , fontFamilies [ "Quicksand" ]
            , fontSize (em 1.4)
            ]
        ]
        []


choiceInput msg choices value =
    div [] (List.map (radio msg value) choices)


radio msg value choice =
    label
        [ styles
            [ display block
            , marginTop (px 8)
            ]
        , onClick (msg choice)
        ]
        [ div
            [ styles
                [ display inlineBlock
                , marginRight (px 8)
                , border (px 1)
                , borderStyle solid
                , borderColor (hex "333333")
                , borderRadius (px 2)
                , width (px 10)
                , height (px 10)
                , padding (px 1)
                ]
            ]
            (if choice == value then
                [ div
                    [ styles
                        [ backgroundColor (hex "8f3faf")
                        , borderRadius (px 2)
                        , width (px 10)
                        , height (px 10)
                        ]
                    ]
                    []
                ]
             else
                []
            )
        , span [ styles [ fontSize (em 1.4) ] ] [ Html.text choice ]
        ]
