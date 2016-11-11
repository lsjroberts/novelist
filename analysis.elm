module Analysis exposing (tokenise, parse)

import String exposing (toList)

type alias Token =
  { tokenType : String
  , value : String
  , kind : String
  }

type alias Leaf =
  { leafType : String
  , body : SyntaxTree
  }

type SyntaxTree =
  SyntaxTree (List Leaf)

tokenise : String -> List Token
tokenise text =
  text
    |> String.split ""
    |> tokeniseChars
    |> List.reverse

tokeniseChars : List String -> List Token
tokeniseChars chars =
  chars
    |> List.foldl tokeniseChar []

tokeniseChar : String -> List Token -> List Token
tokeniseChar char tokens =
  case char of
    "“" ->
      List.append [{ tokenType = "Punctuator", value = char, kind = "OpenSpeechMark" }] tokens
    "”" ->
      List.append [{ tokenType = "Punctuator", value = char, kind = "CloseSpeechMark" }] tokens
    "\n" ->
      List.append [{ tokenType = "NewLine", value = "\n", kind = "" }] tokens
    _ ->
      let
        first = List.head tokens
      in
        List.append
          [(case first of
              Maybe.Just a ->
                { a | value = a.value ++ char }
              Maybe.Nothing ->
                Maybe.withDefault { tokenType = "", value = "", kind = "" } first
          )]
          (List.drop 1 tokens)

  -- [ { tokenType = "Punctuator", value = "“", kind = "OpenSpeechMark" }
  -- , { tokenType = "Speech", value = "We should start back,", kind = "" }
  -- , { tokenType = "Punctuator", value = "”", kind = "CloseSpeechMark" }
  -- , { tokenType = "CharacterName", value = "Gared", kind = ""}
  -- , { tokenType = "Text", value = "urged as the woods began to grow dark around them.", kind = "" }
  -- , { tokenType = "Punctuator", value = "“", kind = "OpenSpeechMark" }
  -- , { tokenType = "Speech", value = "The wildings are dead.", kind = "" }
  -- , { tokenType = "Punctuator", value = "”", kind = "CloseSpeechMark" }
  -- , { tokenType = "NewLine", value = "\n", kind = "" }
  -- ]

parse : String -> Maybe Leaf
parse text =
  Nothing
