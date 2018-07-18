module Data.Prose exposing (Prose)


type alias Prose =
    { paragraphs : List String
    , activeParagraph : Maybe Int
    }
