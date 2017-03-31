module Binder.Types exposing (..)


type Msg
    = NoOp


type alias File =
    { name : String
    , children : FileChildren
    }


type FileChildren
    = FileChildren (List File)


fileChildren : File -> List File
fileChildren file =
    let
        get (FileChildren cs) =
            cs
    in
        get file.children
