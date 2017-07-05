module Test.Token exposing (all)

import Test exposing (..)
import Extra.Fuzz exposing (string)
import Expect
import Novelist
    exposing
        ( Token
        , TokenChildren
        )


-- TESTS


all : Test
all =
    describe "Token"
        [ markdownToTokens
          -- , tokenWrap2
        ]


markdownToTokens : Test
markdownToTokens =
    describe "markdownToTokens"
        [ describe "GIVEN a string without markup"
            [ fuzz string "SHOULD return a list containing one Text token" <|
                \text ->
                    text
                        |> Novelist.markdownToTokens
                        |> Expect.equalLists [ mockText text [] ]
            ]
        , describe "GIVEN a speech"
            [ fuzz string "SHOULD return a list containing one Speech token" <|
                \text ->
                    let
                        wrapped =
                            "\"" ++ text ++ "\""
                    in
                        wrapped
                            |> Novelist.markdownToTokens
                            |> Expect.equalLists [ mockSpeech [ mockText text [] ] ]
            ]
          -- , describe "GIVEN a speech with suffixed attribution"
          --     [ test "SHOULD return a list containing a AttributedSpeech token with Speech and Attribution children" <|
          --         \() ->
          --             let
          --                 input =
          --                     "\"Lorem ipsum dolor sit amet,\" said Caecilius"
          --
          --                 output =
          --                     [ attributedSpeechToken
          --                         [ speechToken [ textToken "Lorem ipsum dolor sit amet," [] ]
          --                         , attributionToken [ textToken " said Caecilius" [] ]
          --                         ]
          --                     ]
          --             in
          --                 input
          --                     |> markdownToTokens
          --                     |> Expect.equalLists output
          --     ]
        ]



-- tokenWrap2 : Test
-- tokenWrap2 =
--     describe "tokenWrap2"
--         [ describe "GIVEN some things"
--             [ fuzz string "AND a string" <|
--                 \text ->
--                     Novelist.tokenWrap2 "\"" "\"" (Novelist.speech) (Novelist.text) text
--                         |> Expect.equalLists []
--             ]
--         ]
-- MOCKS


mockText string cs =
    Token (Novelist.Text string) (mockTokenChildren cs)


mockSpeech cs =
    Token Novelist.Speech (mockTokenChildren cs)



-- attributedSpeechToken cs =
--     Token AttributedSpeech Nothing Nothing False Nothing (children cs)
--
--
-- attributionToken cs =
--     Token AttributionToken Nothing Nothing False Nothing (children cs)


mockTokenChildren =
    Novelist.TokenChildren
