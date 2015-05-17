/* global mode, repeat, awaitsMotion */
#noEnv
#singleInstance, force
sendMode, input
setWorkingDir, %A_ScriptDir%
setKeyDelay, 20, 20

/**
 * Reset state to default and set values from given object.
 */
resetState(state:="") {
    state := state ? state : {}
    global mode, repeat, awaitsMotion
    mode := state.hasKey("mode") ? state["mode"] : "NORMAL"
    repeat := state.hasKey("repeat") ? state["repeat"] : 1
    awaitsMotion := state.hasKey("awaitsMotion") ? state["awaitsMotion"] : ""
}

/**
 * Set state from the values of given object.
 */
setState(state:="") {
    state := state ? state : {}
    global mode, repeat, awaitsMotion
    if (state.hasKey("mode"))
        mode := state["mode"]
    if (state.hasKey("repeat"))
        repeat := state["repeat"]
    if (state.hasKey("awaitsMotion"))
        awaitsMotion := state["awaitsMotion"]
}

resetState()

moveCursor(direction, times) {
    send, {%direction% %times%}
}

goToEnd(times) {
    loop, %times% {
        send, {right}{end}
    }
}

goToBeginning(times) {
    loop, %times% {
        send, {left}{home}
    }
}

goToBeginningOfNextBar(times) {
    loop, %times% {
        send, {end}{right}
    }
}

selectBeats(numberOfBeats) {
    direction := (numberOfBeats > 0) ? "right" : "left"
    if (numberOfBeats < 0) {
        send {left}
    }
    times := abs(numberOfBeats) - 1
    send {shift down}{%direction% %times%}{shift up}
}

selectBars(numberOfBars) {
    direction := (numberOfBars > 0) ? "right" : "left"
    send, {ctrl down}{shift down}{%direction% %numberOfBars%}
    send, {ctrl up}{shift up}
}

selectBeatsToEnd(times) {
    send, {shift down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times) {
    send, {left}{shift down}
    times -= 1
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times) {
    send, {shift down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

deleteNotes(numberOfNotes) {
    loop, % abs(numberOfNotes) {
        if (numberOfNotes > 0) {
            send, {delete}{right}
        } else {
            send, {left}{delete}
        }
    }
}

deleteBeats(times) {
    if (abs(times) = 1) {
        if (times < 0) {
            send, {left}
        }
        send, {ctrl down}{delete}{ctrl up}
    } else {
        selectBeats(times)
        send, {delete}
    }
}

deleteBars(numberOfBars) {
    if (numberOfBars > 1) {
        selectBars(numberOfBars)
    }
    send, {ctrl down}x{ctrl up}{enter}
}

deleteBeatsToEnd(times) {
    selectBeatsToEnd(times)
    send, {delete}{right}
}

deleteBeatsToBeginning(times) {
    selectBeatsToBeginning(times)
    send, {delete}
}

clearBars(numberOfBars) {
    selectBars(numberOfBars)
    send, {delete}
    if (numberOfBars > 1) {
        times := numberOfBars - 1
        send, {left %times%}
    }
}

undo(times) {
    loop, %times% {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times) {
    loop, %times% {
        send, {ctrl down}Z{ctrl up}
    }
}

insertBeat() {
    send, {insert}
}

insertBeatToBeginning() {
    send, {home}{insert}
}

appendBeat() {
    send, {enter}
}

appendBeatToEnd() {
    send, {end}{enter}
}

substitueBeats(numberOfBeats) {
    if (numberOfBeats = 1) {
        deleteBeats(numberOfBeats)
        insertBeat()
    } else {
        ; Inconsistency on the end of the bar
        send, {insert}{right}
        deleteBeats(numberOfBeats)
        send, {left}
    }
}

#if WinActive("Guitar Pro 5")
    escape::
        send, {escape}
        resetState()
        return

    #if WinActive("Guitar Pro 5") and mode == "NORMAL"
        ; Number keys
        1::repeat := 1
        2::repeat := 2
        3::repeat := 3
        4::repeat := 4
        5::repeat := 5
        6::repeat := 6
        7::repeat := 7
        8::repeat := 8
        9::repeat := 9

        ; Cursor keys
        h::
            if (awaitsMotion = "d") {
                deleteBeats(-repeat)
            } else {
                moveCursor("left", repeat)
            }
            resetState()
            return
        j::
            moveCursor("down", repeat)
            resetState()
            return
        k::
            moveCursor("up", repeat)
            resetState()
            return
        l::
            if (awaitsMotion = "d") {
                deleteBeats(repeat)
            } else {
                moveCursor("right", repeat)
            }
            resetState()
            return

        ; Bar navigation
        e::
            if (awaitsMotion = "d") {
                deleteBeatsToEnd(repeat)
            } else {
                goToEnd(repeat)
            }
            resetState()
            return
        b::
            if (awaitsMotion = "d") {
                deleteBeatsToBeginning(repeat)
            } else {
                goToBeginning(repeat)
            }
            resetState()
            return
        w::
            if (awaitsMotion = "d") {
                ; selectBeatsToBeginningOfNextBar(repeat)
                deleteBeatsToEnd(repeat)
            } else {
                goToBeginningOfNextBar(repeat)
            }
            resetState()
            return

        ; Deletion keys
        x::
            deleteNotes(repeat)
            resetState()
            return
        +x::
            deleteNotes(-repeat)
            resetState()
            return
        d::
            if (awaitsMotion = "d") {
                deleteBars(repeat)
                resetState()
            } else {
                setState({awaitsMotion: "d"})
            }
            return
        +d::
            ; Does not return to the same beat if repeat > 1
            deleteBeatsToEnd(repeat)
            resetState()
            return

        ; undo/redo keys
        u::
            undo(repeat)
            resetState()
            return
        ^r::
            redo(repeat)
            resetState()
            return

        i::
            insertBeat()
            resetState({mode: "INSERT"})
            return
        +i::
            insertBeatToBeginning()
            resetState({mode: "INSERT"})
            return
        a::
            appendBeat()
            resetState({mode: "INSERT"})
            return
        +a::
            appendBeatToEnd()
            resetState({mode: "INSERT"})
            return
        ; c::
        ;     if (awaitsMotion = "c") {
        ;         deleteBars(repeat)
        ;         repeat := 1
        ;         awaitsMotion := ""
        ;         mode := "INSERT"
        ;     } else {
        ;         awaitsMotion := "c"
        ;     }
        ;     return
        +c::
            deleteBeatsToEnd(repeat)
            resetState({mode: "INSERT"})
            return
        s::
            substitueBeats(repeat)
            resetState({mode: "INSERT"})
            return
        +s::
            clearBars(repeat)
            resetState({mode: "INSERT"})
            return
