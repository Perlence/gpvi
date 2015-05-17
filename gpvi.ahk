Mode := "NORMAL"
Repeat := 1
AwaitsMotion := ""

MoveCursor(Direction, Times) {
    Send {%Direction% %Times%}
}

GoToTheEnd(Times) {
    Loop %Times% {
        Send {Right}{End}
    }
}

GoToTheBeginning(Times) {
    Loop %Times% {
        Send {Home}{Left}
    }
}

GoToTheBeginningOfTheNextBar(Times) {
    Loop %Times% {
        Send {End}{Right}
    }
}

SelectBeats(NumberOfBeats) {
    Direction := (NumberOfBeats > 0) ? "{Right}" : "{Left}"
    If (NumberOfBeats < 0) {
        Send {Left}
    }
    Send {Shift Down}
    Loop % Abs(NumberOfBeats) - 1 {
        Send %Direction%
    }
    Send {Shift Up}
}

SelectBars(NumberOfBars) {
    Direction := (NumberOfBars > 0) ? "Right" : "Left"
    Send {Ctrl Down}{Shift Down}
    Loop %NumberOfBars% {
        Send {%Direction% Down}
        Sleep 10
        Send {%Direction% Up}
    }
    Send {Shift Up}{Ctrl Up}
}

SelectBeatsToTheEnd(Times) {
    Send {Shift Down}
    GoToTheEnd(Times)
    Send {Shift Up}
}

SelectBeatsToTheBeginning(Times) {
    Send {Left}{Shift Down}
    Times -= 1
    GoToTheBeginning(Times)
    Send {Home}{Shift Up}
}

SelectBeatsToTheBeginningOfTheNextBar(Times) {
    Send {Shift Down}
    GoToTheBeginningOfTheNextBar(Times)
    Send {Shift Up}
}

DeleteNotes(NumberOfNotes) {
    Loop % Abs(NumberOfNotes) {
        If (NumberOfNotes > 0) {
            Send {Delete}{Right}
        } Else {
            Send {Left}{Delete}
        }
    }
}

DeleteBeats(Times) {
    If (Abs(Times) = 1) {
        If (Times < 0) {
            Send {Left}
        }
        Send {Ctrl Down}{Delete}{Ctrl Up}
    } Else {
        SelectBeats(Times)
        Send {Delete}
    }
}

DeleteBars(NumberOfBars) {
    If (NumberOfBars > 1) {
        SelectBars(NumberOfBars)
    }
    Send {Ctrl Down}x{Ctrl Up}{Enter}
}

DeleteBeatsToTheEnd(Times) {
    SelectBeatsToTheEnd(Times)
    Send {Delete}{Right}
}

DeleteBeatsToTheBeginning(Times) {
    SelectBeatsToTheBeginning(Times)
    Send {Delete}
}

ClearBars(NumberOfBars) {
    If (NumberOfBars > 1) {
        SelectBars(NumberOfBars)
    }
    Send {Ctrl Down}{Shift Down}x{Ctrl Up}{Shift Up}{Enter}
}

Undo(Times) {
    Loop %Times% {
        Send {Ctrl Down}z{Ctrl Up}
    }
}

Redo(Times) {
    Loop %Times% {
        Send {Ctrl Down}Z{Ctrl Up}
    }
}

InsertBeat() {
    Send {Insert}
}

InsertBeatToTheBeginning() {
    Send {Home}{Insert}
}

AppendBeat() {
    Send {Enter}
}

AppendBeatToTheEnd() {
    Send {End}{Enter}
}

SubstitueBeats(NumberOfBeats) {
    If (NumberOfBeats = 1) {
        DeleteBeats(NumberOfBeats)
        InsertBeat()
    } Else {
        ; Inconsistency on the end of the bar
        Send {Insert}{Right}
        DeleteBeats(NumberOfBeats)
        Send {Left}
    }
}

#If WinActive("Guitar Pro 5")
    Escape::
        Send {Escape}
        Mode := "NORMAL"
        Repeat := 1
        AwaitsMotion := ""
        Return

    #If WinActive("Guitar Pro 5") and Mode == "NORMAL"
        ; Number keys
        1::Repeat := 1
        2::Repeat := 2
        3::Repeat := 3
        4::Repeat := 4
        5::Repeat := 5
        6::Repeat := 6
        7::Repeat := 7
        8::Repeat := 8
        9::Repeat := 9

        ; Cursor keys
        h::
            If (AwaitsMotion = "d") {
                DeleteBeats(-Repeat)
            } Else {
                MoveCursor("Left", Repeat)
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        j::
            MoveCursor("Down", Repeat)
            Repeat := 1
            AwaitsMotion := ""
            Return
        k::
            MoveCursor("Up", Repeat)
            Repeat := 1
            AwaitsMotion := ""
            Return
        l::
            If (AwaitsMotion = "d") {
                DeleteBeats(Repeat)
            } Else {
                MoveCursor("Right", Repeat)
            }
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Bar navigation
        e::
            If (AwaitsMotion = "d") {
                DeleteBeatsToTheEnd(Repeat)
            } Else {
                GoToTheEnd(Repeat)
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        b::
            If (AwaitsMotion = "d") {
                DeleteBeatsToTheBeginning(Repeat)
            } Else {
                GoToTheBeginning(Repeat)
            }
            Repeat := 1
            AwaitsMotion := ""
            Return
        w::
            If (AwaitsMotion = "d") {
                ; SelectBeatsToTheBeginningOfTheNextBar(Repeat)
                DeleteBeatsToTheEnd(Repeat)
            } Else {
                GoToTheBeginningOfTheNextBar(Repeat)
            }
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Deletion keys
        x::
            DeleteNotes(Repeat)
            Repeat := 1
            Return
        +x::
            DeleteNotes(-Repeat)
            Repeat := 1
            Return
        d::
            If (AwaitsMotion = "d") {
                DeleteBars(Repeat)
                Repeat := 1
                AwaitsMotion := ""
            } Else {
                AwaitsMotion := "d"
            }
            Return
        +d::
            ; Does not return to the same beat if Repeat > 1
            DeleteBeatsToTheEnd(Repeat)
            Repeat := 1
            AwaitsMotion := ""
            Return

        ; Undo/Redo keys
        u::
            Undo(Repeat)
            Repeat := 1
            Return
        ^r::
            Redo(Repeat)
            Repeat := 1
            Return

        i::
            InsertBeat()
            Mode := "INSERT"
            Return
        +i::
            InsertBeatToTheBeginning()
            Mode := "INSERT"
            Return
        a::
            AppendBeat()
            Mode := "INSERT"
            Return
        +a::
            AppendBeatToTheEnd()
            Mode := "INSERT"
            Return
        ; c::
        ;     If (AwaitsMotion = "c") {
        ;         DeleteBars(Repeat)
        ;         Repeat := 1
        ;         AwaitsMotion := ""
        ;         Mode := "INSERT"
        ;     } Else {
        ;         AwaitsMotion := "c"
        ;     }
        ;     Return
        +c::
            DeleteBeatsToTheEnd(Repeat)
            Repeat := 1
            AwaitsMotion := ""
            Mode := "INSERT"
            Return
        s::
            SubstitueBeats(Repeat)
            Repeat := 1
            AwaitsMotion := ""
            Mode := "INSERT"
            Return
