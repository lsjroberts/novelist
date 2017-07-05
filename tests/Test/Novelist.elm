module Test.Novelist exposing (all)

import Test exposing (..)
import Date
import Expect
import Novelist


all : Test
all =
    describe "Novelist"
        [ dateUtils ]


dateUtils : Test
dateUtils =
    describe "Date Utils"
        [ formatDateShort ]


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
                        Novelist.formatDateShort date
                in
                    Expect.equal expected actual
        ]
