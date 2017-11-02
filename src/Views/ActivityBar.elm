module Views.ActivityBar exposing (view)

import Data.Activity exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Styles exposing (..)
import Messages exposing (..)
import Octicons as Icon
import Views.Icons


view activity =
    column (Activity ActivityWrapper)
        []
        [ item activity Manuscript Icon.book
        , item activity Characters Icon.gistSecret
        , item activity Locations Icon.globe
        , item activity Search Icon.search
        , item activity Plan Icon.gitBranch
        , item activity Editor Icon.checklist
        ]


item activeActivity activity icon =
    Views.Icons.largeIcon
        |> icon
        |> html
        |> el (Activity ActivityItem)
            [ padding <| paddingScale 2
            , onClick (SetActivity activity)
            , vary Active (activity == activeActivity)
            ]
