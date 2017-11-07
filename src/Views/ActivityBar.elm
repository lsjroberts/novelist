module Views.ActivityBar exposing (view)

import Data.Activity exposing (..)
import Data.Palette exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Styles exposing (..)
import Messages exposing (..)
import Octicons as Icon
import Views.Icons exposing (largeIcon)


view : Activity -> Element Styles Variations Msg
view activity =
    column (Activity ActivityWrapper)
        []
        [ item activity Manuscript Icon.book
        , item activity Characters Icon.gistSecret
        , item activity Locations Icon.globe
        , item activity Search Icon.search
        , item activity Plan Icon.gitBranch
        , item activity Editor Icon.checklist
        , largeIcon
            |> Icon.alert
            |> html
            |> el (Activity ActivityItem)
                [ padding <| innerScale 2
                , onClick (Ui <| OpenPalette (Files ""))
                ]
        ]


item activeActivity activity icon =
    largeIcon
        |> icon
        |> html
        |> el (Activity ActivityItem)
            [ padding <| innerScale 2
            , onClick (Ui <| SetActivity activity)
            , vary Active (activity == activeActivity)
            ]
