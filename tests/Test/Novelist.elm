module Test.Novelist exposing (all)

import Test exposing (..)
import Date
import Expect
import Novelist


all : Test
all =
    describe "Novelist"
        [ dateUtils
        , stringUtils
        ]


dateUtils : Test
dateUtils =
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
                        Novelist.formatDateShort date
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
                        Novelist.formatDateHuman date
                in
                    Expect.equal expected actual
        ]


stringUtils : Test
stringUtils =
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
                        Novelist.getStringWordCount string
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
                        Novelist.getStringWordCount string
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
                        Novelist.getStringWordCount string
                in
                    Expect.equal expected actual
        ]
