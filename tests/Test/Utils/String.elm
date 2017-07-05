module Test.Utils.String exposing (all)

import Test exposing (..)
import Expect
import Utils.String exposing (..)


all : Test
all =
    describe "String Utils"
        [ getStringWordCount ]


getStringWordCount : Test
getStringWordCount =
    describe "getStringWordCount"
        [ test "gets single word count" <|
            \_ ->
                let
                    string =
                        "one"

                    expected =
                        1

                    actual =
                        Utils.String.getStringWordCount string
                in
                    Expect.equal expected actual
        , test "gets multiple word count" <|
            \_ ->
                let
                    string =
                        "one two three"

                    expected =
                        3

                    actual =
                        Utils.String.getStringWordCount string
                in
                    Expect.equal expected actual
        , test "gets word count with special chars" <|
            \_ ->
                let
                    string =
                        "one two, three !"

                    expected =
                        3

                    actual =
                        Utils.String.getStringWordCount string
                in
                    Expect.equal expected actual
        ]
