module Test.Utils.Date exposing (all)

import Test exposing (..)
import Date
import Expect
import Utils.Date exposing (..)


all : Test
all =
    describe "Date Utils"
        [ formatDateShort
        , formatDateHuman
        ]


formatDateShort : Test
formatDateShort =
    describe "formatDateShort"
        [ test "formats a date" <|
            \_ ->
                let
                    date =
                        Date.fromTime 1499286885000

                    expected =
                        "2017-07-05"

                    actual =
                        Utils.Date.formatDateShort date
                in
                    Expect.equal expected actual
        ]


formatDateHuman : Test
formatDateHuman =
    describe "formatDateHuman"
        [ test "formats a date to human readable format" <|
            \_ ->
                let
                    date =
                        Date.fromTime 1499286885000

                    expected =
                        "5th July, 2017"

                    actual =
                        Utils.Date.formatDateHuman date
                in
                    Expect.equal expected actual
        ]
