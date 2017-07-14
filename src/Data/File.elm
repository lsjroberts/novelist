module Data.File exposing (..)


type alias File =
    { id : Int
    , parent : Maybe Int
    , type_ : FileType
    , name : String
    , expanded : Bool
    }


type FileType
    = SceneFile
    | PlanFile
    | CharacterFile
    | LocationFile


getRootFiles : List File -> List File
getRootFiles files =
    files |> List.filter (\f -> f.parent == Nothing)


getSceneFiles : List File -> List File
getSceneFiles =
    getFilesByType SceneFile


getPlanFiles : List File -> List File
getPlanFiles =
    getFilesByType PlanFile


getCharacterFiles : List File -> List File
getCharacterFiles =
    getFilesByType CharacterFile


getLocationFiles : List File -> List File
getLocationFiles =
    getFilesByType LocationFile


getFilesByType : FileType -> List File -> List File
getFilesByType type_ =
    List.filter (\f -> f.type_ == type_)


getFileChildren : List File -> File -> List File
getFileChildren files file =
    files
        |> List.filter
            (\f ->
                case f.parent of
                    Just parent ->
                        parent == file.id

                    Nothing ->
                        False
            )
