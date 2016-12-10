module Welcome.View exposing (root)

import Css exposing (..)
import Html exposing (Html, div, h1, button)
import Svg exposing (svg, line)
import Svg.Attributes exposing (x1, x2, y1, y2, stroke, strokeWidth)
import Styles exposing (styles)
import Welcome.Types exposing (..)


root : Model -> Html Msg
root model =
    div
        [ styles
            [ displayFlex
              -- , flex3 0 1 auto
            , flexDirection column
            , alignItems center
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
        , button
            [ styles
                [ backgroundColor (hex "8f3faf")
                , padding2 (px 19) (px 29)
                , border (px 0)
                , borderRadius (px 2)
                , boxShadow4 (px 0) (px 2) (px 4) (rgba 0 0 0 0.5)
                , cursor pointer
                , fontSize (px 24)
                , fontWeight (int 200)
                , color (hex "ffffff")
                , hover
                    [ backgroundColor (hex "9c56b8") ]
                ]
            ]
            [ Html.text "Start writing your first story"
            , svg
                [ Svg.Attributes.width "17", Svg.Attributes.height "32", styles [ verticalAlign middle, marginLeft (px 28) ] ]
                [ line [ x1 "0", y1 "0", x2 "17", y2 "16.5", strokeWidth "2", stroke "white" ] []
                , line [ x1 "0", y1 "32", x2 "17", y2 "15.5", strokeWidth "2", stroke "white" ] []
                ]
            ]
        ]
