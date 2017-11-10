module Data.Theme exposing (..)

import Color exposing (Color, rgb)


type alias Theme =
    { primary : Color
    , secondary : Color
    , tertiary : Color
    , background : Color
    , text : Color
    , textSecondary : Color
    , active : Color
    , link : Color
    }


novelistLightTheme : Theme
novelistLightTheme =
    { primary = rgb 241 200 200
    , secondary = rgb 200 200 241
    , tertiary = rgb 200 200 241
    , background = rgb 241 241 241
    , text = rgb 30 30 30
    , textSecondary = rgb 170 170 170
    , active = rgb 229 229 229
    , link = rgb 241 50 50
    }


novelistDarkTheme : Theme
novelistDarkTheme =
    { primary = rgb 141 100 100
    , secondary = rgb 100 100 141
    , tertiary = rgb 100 100 141
    , background = rgb 40 44 52
    , text = rgb 220 220 220
    , textSecondary = rgb 200 200 200
    , active = rgb 80 88 104
    , link = rgb 209 154 102
    }
