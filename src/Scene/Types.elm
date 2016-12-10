module Scene.Types exposing (..)

import Token.Types


type alias Model =
    { name : String
    , content : List Token.Types.Model
    , commit : Int
    , history : List ( Int, List Token.Types.Model )
    , children : Children
    , isWriting : Bool
    }


type Children
    = Children (List Model)


type Msg
    = SetName String
    | StartWriting
    | Write String
    | TokenMsg Token.Types.Msg
