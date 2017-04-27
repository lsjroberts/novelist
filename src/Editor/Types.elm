module Editor.Types exposing (..)

import Json.Encode
import Binder.Types
import Workspace.Types


type alias Model =
    { name : String
    , author : String
    , files : List File
    , open : List File
    , active : Maybe Int
    , lastFileId : Int
    }


empty =
    { name = "Title"
    , author = "Author"
    , files =
        [ File 0 None -1 "Manuscript"
        , File 1 None -1 "Notes"
        , File 2 None -1 "Characters"
        , File 3 None -1 "Locations"
        , File 4 Scene 0 "Chapter One"
        ]
    , open = []
    , active = Nothing
    , lastFileId = 4
    }


type alias FilePath =
    String


type FileType
    = None
    | Scene
    | Note
    | Character
    | Location


type alias File =
    { id : Int
    , fileType : FileType
    , parentId : Int
    , name : String
    }



-- type FileChildren
--     = FileChildren (List File)
--
--
-- fileChildren : File -> List File
-- fileChildren file =
--     let
--         get (FileChildren cs) =
--             cs
--     in
--         get file.children


type Msg
    = ShowOpenDialog
    | OpenProject String
    | AddFile Int
    | OpenFile Int
    | WorkspaceMsg Workspace.Types.Msg
    | BinderMsg Binder.Types.Msg
