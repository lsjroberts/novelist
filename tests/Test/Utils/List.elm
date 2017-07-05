module Test.Utils.List exposing (all)

import Test exposing (..)
import Expect
import Utils.List exposing (..)


all : Test
all =
    describe "List Utils"
        [ getById ]


getById : Test
getById =
    describe "getById"
        [ test "gets just item by id" <|
            \_ ->
                let
                    xs =
                        [ { id = 1 }, { id = 99 }, { id = 123 }, { id = 124 } ]

                    expected =
                        Just { id = 123 }

                    actual =
                        Utils.List.getById xs 123
                in
                    Expect.equal expected actual
        , test "gets nothing if id does not exist" <|
            \_ ->
                let
                    xs =
                        [ { id = 1 }, { id = 99 }, { id = 123 }, { id = 124 } ]

                    expected =
                        Nothing

                    actual =
                        Utils.List.getById xs 100
                in
                    Expect.equal expected actual
        ]
