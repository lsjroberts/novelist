module Views.Icons exposing (..)

import Styles exposing (fontScale)
import Octicons as Icon


smallIcon =
    Icon.defaultOptions
        |> Icon.color "black"
        |> Icon.size (fontScale 1 |> floor)


largeIcon =
    Icon.defaultOptions
        |> Icon.color "black"
        |> Icon.size (fontScale 4 |> floor)
