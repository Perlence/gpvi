; Global Mode, Repeat, AwaitsMotion
SetKeyDelay 20, 20

/** Reset state to default and set values from given object. */
ResetState(State:="") {
    State := State != "" ? State : {}
    Global Mode, Repeat, AwaitsMotion
    Mode := State.HasKey("Mode") ? State["Mode"] : "NORMAL"
    Repeat := State.HasKey("Repeat") ? State["Repeat"] : 1
    AwaitsMotion := State.HasKey("AwaitsMotion") ? State["AwaitsMotion"] : ""
}

/** Set state from the values of given object. */
SetState(State:="") {
    State := State != "" ? State : {}
    Global Mode, Repeat, AwaitsMotion
    If (State.HasKey("Mode"))
        Mode := State["Mode"]
    If (State.HasKey("Repeat"))
        Repeat := State["Repeat"]
    If (State.HasKey("AwaitsMotion"))
        AwaitsMotion := State["AwaitsMotion"]
}

ResetState()

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
    Direction := (NumberOfBeats > 0) ? "Right" : "Left"
    If (NumberOfBeats < 0) {
        Send {Left}
    }
    Times := Abs(NumberOfBeats) - 1
    Send {Shift Down}{%Direction% %Times%}{Shift Up}
}

SelectBars(NumberOfBars) {
    Direction := (NumberOfBars > 0) ? "Right" : "Left"
    Send {Ctrl Down}{Shift Down}{%Direction% %NumberOfBars%}
    Send {Ctrl Up}{Shift Up}
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
    SelectBars(NumberOfBars)
    Send {Delete}
    If (NumberOfBars > 1) {
        Times := NumberOfBars - 1
        Send {Left %Times%}
    }
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
        ResetState()
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
        ; TODO: Input repeat times greater than 10

        ; Cursor keys
        h::
            If (AwaitsMotion = "d") {
                DeleteBeats(-Repeat)
            } Else {
                MoveCursor("Left", Repeat)
            }
            ResetState()
            Return
        j::
            MoveCursor("Down", Repeat)
            ResetState()
            Return
        k::
            MoveCursor("Up", Repeat)
            ResetState()
            Return
        l::
            If (AwaitsMotion = "d") {
                DeleteBeats(Repeat)
            } Else {
                MoveCursor("Right", Repeat)
            }
            ResetState()
            Return

        ; Bar navigation
        e::
            If (AwaitsMotion = "d") {
                DeleteBeatsToTheEnd(Repeat)
            } Else {
                GoToTheEnd(Repeat)
            }
            ResetState()
            Return
        b::
            If (AwaitsMotion = "d") {
                DeleteBeatsToTheBeginning(Repeat)
            } Else {
                GoToTheBeginning(Repeat)
            }
            ResetState()
            Return
        w::
            If (AwaitsMotion = "d") {
                ; SelectBeatsToTheBeginningOfTheNextBar(Repeat)
                DeleteBeatsToTheEnd(Repeat)
            } Else {
                GoToTheBeginningOfTheNextBar(Repeat)
            }
            ResetState()
            Return

        ; Deletion keys
        x::
            DeleteNotes(Repeat)
            ResetState()
            Return
        +x::
            DeleteNotes(-Repeat)
            ResetState()
            Return
        d::
            If (AwaitsMotion = "d") {
                DeleteBars(Repeat)
                ResetState()
            } Else {
                SetState({AwaitsMotion: "d"})
            }
            Return
        +d::
            ; Does not return to the same beat if Repeat > 1
            DeleteBeatsToTheEnd(Repeat)
            ResetState()
            Return

        ; Undo/Redo keys
        u::
            Undo(Repeat)
            ResetState()
            Return
        ^r::
            Redo(Repeat)
            ResetState()
            Return

        i::
            InsertBeat()
            ResetState({Mode: "INSERT"})
            Return
        +i::
            InsertBeatToTheBeginning()
            ResetState({Mode: "INSERT"})
            Return
        a::
            AppendBeat()
            ResetState({Mode: "INSERT"})
            Return
        +a::
            AppendBeatToTheEnd()
            ResetState({Mode: "INSERT"})
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
            ResetState({Mode: "INSERT"})
            Return
        s::
            SubstitueBeats(Repeat)
            ResetState({Mode: "INSERT"})
            Return
        +s::
            ClearBars(Repeat)
            ResetState({Mode: "INSERT"})
            Return
