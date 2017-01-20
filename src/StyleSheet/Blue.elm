module StyleSheet.Blue exposing (stylesheet)

import Style exposing (..)
import Html exposing (Html)
import Color exposing (Color)
import StyleSheet.Shared exposing (..)
import StyleSheet.Types exposing (Class(..), Palette)


-- Palettes


colors =
    { white = Color.white
    , black = Color.black
    , transparent = Color.rgba 255 255 255 0
    , blue =
        { light = (Color.rgb 232 235 237)
        , dark = (Color.rgb 4 32 46)
        }
    }


palette : Palette
palette =
    { standard =
        Style.mix
            [ backgroundColor colors.transparent
            , textColor colors.black
            ]
    , editor =
        Style.mix
            [ backgroundColor colors.blue.light
            , textColor colors.blue.dark
            ]
    }



-- Base style


common : List Style.Property
common =
    Style.foundation
        ++ [ palette.standard
           , fonts.body.normal
           , transition
                { property = "all"
                , duration = 300
                , easing = "ease-out"
                , delay = 0
                }
           ]


stylesheet : Style.StyleSheet Class msg
stylesheet =
    Style.renderWith
        [ Style.base common ]
        [ class Base
            [ property "overflow" "hidden"
            , height (percent 100)
            ]
        ]
