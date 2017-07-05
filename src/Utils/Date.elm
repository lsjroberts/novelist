module Utils.Date exposing (..)

import Date exposing (Date)
import Time exposing (Time)


timeUntilDeadline : Time -> Maybe Date -> String
timeUntilDeadline time deadline =
    case deadline of
        Just deadlineDate ->
            deadlineDate
                |> Date.toTime
                |> timeUntil time

        Nothing ->
            ""


timeUntil : Time -> Time -> String
timeUntil timeFrom timeTo =
    let
        timeDiff =
            timeTo - timeFrom

        timeSeconds =
            Time.inSeconds timeDiff

        timeMinutes =
            Time.inMinutes timeDiff

        timeHours =
            Time.inHours timeDiff

        timeDays =
            timeHours / 24.0

        timeWeeks =
            timeDays / 7.0

        format time unit =
            let
                floorTime =
                    floor time

                withUnit =
                    (toString floorTime) ++ " " ++ unit
            in
                if floorTime /= 1 then
                    withUnit ++ "s"
                else
                    withUnit
    in
        if timeSeconds < 1.0 then
            "now"
        else if timeMinutes < 1.0 then
            format timeSeconds "second"
        else if timeHours < 1.0 then
            format timeMinutes "minute"
        else if timeDays < 1.0 then
            format timeHours "hour"
        else if timeWeeks < 4.0 then
            format timeDays "day"
        else
            format timeWeeks "week"


formatDateShort : Date -> String
formatDateShort date =
    let
        year =
            dateYear date

        month =
            dateMonthNumber date

        day =
            dateDayPadded date
    in
        year ++ "-" ++ month ++ "-" ++ day


formatDateHuman : Date -> String
formatDateHuman date =
    let
        year =
            dateYear date

        month =
            dateMonth date

        day =
            dateDay date

        daySuffix =
            dateDaySuffix date
    in
        day ++ daySuffix ++ " " ++ month ++ ", " ++ year


dateYear : Date -> String
dateYear =
    Date.year >> toString


dateMonthNumber : Date -> String
dateMonthNumber =
    let
        monthToString month =
            case month of
                Date.Jan ->
                    "01"

                Date.Feb ->
                    "02"

                Date.Mar ->
                    "03"

                Date.Apr ->
                    "04"

                Date.May ->
                    "05"

                Date.Jun ->
                    "06"

                Date.Jul ->
                    "07"

                Date.Aug ->
                    "08"

                Date.Sep ->
                    "09"

                Date.Oct ->
                    "10"

                Date.Nov ->
                    "11"

                Date.Dec ->
                    "12"
    in
        Date.month >> monthToString


dateMonth : Date -> String
dateMonth =
    let
        monthToString month =
            case month of
                Date.Jan ->
                    "January"

                Date.Feb ->
                    "February"

                Date.Mar ->
                    "March"

                Date.Apr ->
                    "April"

                Date.May ->
                    "May"

                Date.Jun ->
                    "June"

                Date.Jul ->
                    "July"

                Date.Aug ->
                    "August"

                Date.Sep ->
                    "September"

                Date.Oct ->
                    "October"

                Date.Nov ->
                    "November"

                Date.Dec ->
                    "December"
    in
        Date.month >> monthToString


dateDay : Date -> String
dateDay =
    Date.day >> toString


dateDayPadded : Date -> String
dateDayPadded =
    dateDay >> String.padLeft 2 '0'


dateDaySuffix : Date -> String
dateDaySuffix =
    let
        dayToSuffix day =
            case day of
                "1" ->
                    "st"

                "21" ->
                    "st"

                "31" ->
                    "st"

                "2" ->
                    "nd"

                "22" ->
                    "nd"

                "3" ->
                    "rd"

                "23" ->
                    "rd"

                _ ->
                    "th"
    in
        dateDay >> dayToSuffix
