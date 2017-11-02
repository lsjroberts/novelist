module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)


type Msg
    = NoOp
    | SetActivity Activity
    | OpenFile FileId
    | CloseFile FileId
    | SetWordTarget String
