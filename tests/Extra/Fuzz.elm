module Extra.Fuzz exposing (..)

import Char
import Test exposing (..)
import Fuzz exposing (Fuzzer, custom)
import Shrink exposing (Shrinker)
import Random.Pcg as Random exposing (..)


validStringCodes : List Int
validStringCodes =
    (List.range 32 33)
        ++ (List.range 35 94)
        ++ (List.range 96 120)


lengthString : Generator Char -> Int -> Generator String
lengthString charGenerator stringLength =
    list stringLength charGenerator
        |> map String.fromList


charGenerator : Generator Char
charGenerator =
    (Random.map Char.fromCode (Random.sample validStringCodes |> Random.map (Maybe.withDefault 32)))


string : Fuzzer String
string =
    let
        generator : Generator String
        generator =
            Random.frequency
                [ ( 3, Random.int 1 10 )
                  -- , ( 0.2, Random.constant 0 )
                , ( 1, Random.int 11 50 )
                , ( 1, Random.int 50 1000 )
                ]
                |> Random.andThen (lengthString charGenerator)
    in
        custom generator Shrink.string
