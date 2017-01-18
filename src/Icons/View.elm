-- <svg version="1.1" width="32" height="32" viewBox="0 0 16 16" class="octicon octicon-alert" aria-hidden="true"><use xlink:href="#alert" /></svg>


module Icons.View exposing (icon)

import Html exposing (Html)
import Html exposing (Attribute)
import Svg exposing (svg, line, use)
import Svg.Attributes exposing (width, height, viewBox, class, xlinkHref)


icon : List (Attribute msg) -> Int -> String -> Html msg
icon attrs size name =
    svg
        (attrs
            ++ [ width <| toString size
               , height <| toString size
               , viewBox <| "0 0 " ++ (toString (size // 2)) ++ " " ++ (toString (size // 2))
               , class ("octicon octicon-" ++ name)
               ]
        )
        [ use
            [ xlinkHref ("#" ++ name)
            ]
            []
        ]
