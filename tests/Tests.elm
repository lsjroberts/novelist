module Tests exposing (..)

import Test exposing (..)
import Test.Token as Token


all : Test
all =
    describe "Novelist"
        [ Token.all
        ]
