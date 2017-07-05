module Tests exposing (..)

import Test exposing (..)
import Test.Utils.Date
import Test.Utils.List
import Test.Utils.String


all : Test
all =
    describe "All"
        [ Test.Utils.Date.all
        , Test.Utils.List.all
        , Test.Utils.String.all
        ]
