module Tests exposing (..)

import Test exposing (..)
import Test.Novelist


all : Test
all =
    describe "All"
        [ Test.Novelist.all
        ]
