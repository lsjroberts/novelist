module Messages exposing (..)

import Time exposing (Time)
import Data.Ui exposing (ViewType)


type Msg
    = GoToSettings String
    | NewTime Time
    | OpenProject String
    | SetActiveFile Int
    | SetActiveView ViewType
    | SetSceneName Int String
    | SetSceneWordTarget Int String
    | SetAuthor String
    | SetDeadline String
    | SetTargetWordCount String
    | SetTitle String
    | ToggleFileExpanded Int
    | Write Int String
