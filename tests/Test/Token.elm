module Test.Token exposing (all)

import Test exposing (..)
import Extra.Fuzz exposing (string)
import Expect
import Token.Types exposing (Model)


all : Test
all =
    describe "Token"
        [ markdownToTokens ]


markdownToTokens : Test
markdownToTokens =
    describe "markdownToTokens"
        [ describe "GIVEN a string without markup"
            [ fuzz string "SHOULD return a list containing one Text token" <|
                \text ->
                    text
                        |> Token.Types.markdownToTokens
                        |> Expect.equalLists [ textToken text [] ]
            ]
        , describe "GIVEN a speech"
            [ fuzz string "SHOULD return a list containing one Speech token" <|
                \text ->
                    let
                        wrapped =
                            "\"" ++ text ++ "\""
                    in
                        wrapped
                            |> Token.Types.markdownToTokens
                            |> Expect.equalLists [ speechToken [ textToken text [] ] ]
            ]
        , describe "GIVEN a speech with suffixed attribution"
            [ test "SHOULD return a list containing a AttributedSpeech token with Speech and Attribution children" <|
                \() ->
                    let
                        input =
                            "\"Lorem ipsum dolor sit amet,\" said Caecilius"

                        output =
                            [ attributedSpeechToken
                                [ speechToken [ textToken "Lorem ipsum dolor sit amet," [] ]
                                , attributionToken [ textToken " said Caecilius" [] ]
                                ]
                            ]
                    in
                        input
                            |> Token.Types.markdownToTokens
                            |> Expect.equalLists output
            ]
        ]


textToken string cs =
    Model Token.Types.Text Nothing Nothing False (Just string) (children cs)


speechToken cs =
    Model Token.Types.Speech (Just "“") (Just "”") True Nothing (children cs)


attributedSpeechToken cs =
    Model Token.Types.AttributedSpeech Nothing Nothing False Nothing (children cs)


attributionToken cs =
    Model Token.Types.AttributionToken Nothing Nothing False Nothing (children cs)


children =
    Token.Types.Children
