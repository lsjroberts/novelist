module Messages exposing (..)

import Data.Activity exposing (Activity)
import Data.File exposing (FileId)


type Msg
    = NoOp
    | AddScene
    | CloseFile FileId
    | OpenFile FileId
    | NewUuid
    | SetActivity Activity
    | SetWordTarget String
