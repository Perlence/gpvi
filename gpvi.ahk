/* global mode, repeat, awaitsMotion */
#noEnv
#singleInstance, force
sendMode, input
setWorkingDir, %A_ScriptDir%

; Wait for dialog to show up.
DIALOG_DELAY := 50

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
resetState()

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

transitState() {
    global awaitsMotion, mode
    state := {}
    if (awaitsMotion = "c")
        state["mode"] := "INSERT"
    else if (mode = "VISUAL")
        state["mode"] := "VISUAL"
    resetState(state)
}

moveCursor(direction, times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    send, {%direction% %times%}
    if (mode = "VISUAL")
        send, {shift up}
}

goToEnd(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
}

goToBeginning(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
}

goToBeginningOfNextBar(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
}

selectBeats(numberOfBeats) {
    direction := (numberOfBeats > 0) ? "right" : "left"
    if (numberOfBeats < 0) {
        send {left}
    }
    times := abs(numberOfBeats) - 1
    send {shift down}{up}{down}{%direction% %times%}{shift up}
}

selectBars(numberOfBars) {
    direction := (numberOfBars > 0) ? "right" : "left"
    send, {home}{shift down}{end}
    loop, % abs(numberOfBars) - 1
    {
        send, {%direction%}{end}
    }
    send, {shift up}
}

selectBeatsToEnd(times) {
    send, {shift down}{up}{down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times) {
    send, {left}{shift down}{up}{down}
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times) {
    send, {shift down}{up}{down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

deleteNotes(numberOfNotes) {
    loop, % abs(numberOfNotes)
    {
        if (numberOfNotes > 0)
        {
            send, {delete}{right}
        }
        else
        {
            send, {left}{delete}
        }
    }
}

deleteBeats(times) {
    if (abs(times) = 1)
    {
        if (times < 0)
        {
            send, {left}
        }
        send, {ctrl down}{delete}{ctrl up}
    }
    else
    {
        selectBeats(times)
        send, {delete}
    }
}

deleteBeatsToEnd(times) {
    selectBeatsToEnd(times)
    send, {delete}
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBeatsToBeginning(times) {
    selectBeatsToBeginning(times)
    send, {delete}
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBars(numberOfBars) {
    if (numberOfBars > 1)
    {
        selectBars(numberOfBars)
    }
    send, {ctrl down}x{ctrl up}
    sleep, DIALOG_DELAY
    send, {enter}
}

clearBars(numberOfBars) {
    selectBars(numberOfBars)
    send, {delete}
    if (numberOfBars > 1)
    {
        times := numberOfBars - 1
        send, {left %times%}
    }
}

changeBars(numberOfBars) {
    if (numberOfBars > 1)
        deleteBars(numberOfBars - 1)
    clearBars(1)
}

substituteBeats(numberOfBeats) {
    if (numberOfBeats = 1)
    {
        deleteBeats(numberOfBeats)
        insertBeat()
    }
    else
    {
        ; Inconsistency on the end of the bar
        send, {insert}{right}
        deleteBeats(numberOfBeats)
        send, {left}
    }
}

undo(times) {
    loop, %times%
    {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times) {
    loop, %times%
    {
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

#if WinActive("Guitar Pro 5")
    escape::
        send, {escape}
        resetState()
        return

    #if WinActive("Guitar Pro 5") and mode != "INSERT"
        ; Number keys
        1::setState({repeat: 1})
        2::setState({repeat: 2})
        3::setState({repeat: 3})
        4::setState({repeat: 4})
        5::setState({repeat: 5})
        6::setState({repeat: 6})
        7::setState({repeat: 7})
        8::setState({repeat: 8})
        9::setState({repeat: 9})

        ; Cursor keys
        h::
            if awaitsMotion in d,c
            {
                deleteBeats(-repeat)
            }
            else
            {
                moveCursor("left", repeat)
            }
            transitState()
            return
        j::
            moveCursor("down", repeat)
            transitState()
            return
        k::
            moveCursor("up", repeat)
            transitState()
            return
        l::
            if awaitsMotion in d,c
            {
                deleteBeats(repeat)
            }
            else
            {
                moveCursor("right", repeat)
            }
            transitState()
            return

        ; Bar navigation
        e::
            if awaitsMotion in d,c
            {
                deleteBeatsToEnd(repeat)
            }
            else
            {
                goToEnd(repeat)
            }
            transitState()
            return
        b::
            if awaitsMotion in d,c
            {
                deleteBeatsToBeginning(repeat)
            }
            else
            {
                goToBeginning(repeat)
            }
            transitState()
            return
        w::
            if awaitsMotion in d,c
            {
                ; selectBeatsToBeginningOfNextBar(repeat)
                deleteBeatsToEnd(repeat)
            }
            else
            {
                goToBeginningOfNextBar(repeat)
            }
            transitState()
            return

        ; Deletion keys
        x::
            if (mode = "VISUAL")
            {
                deleteBeats(1)
            }
            else
            {
                deleteNotes(repeat)
            }
            resetState()
            return
        +x::
            keyWait, shift
            if (mode = "VISUAL")
            {
                deleteBars(1)
            }
            else
            {
                deleteNotes(-repeat)
            }
            resetState()
            return
        d::
            if (awaitsMotion = "d")
            {
                deleteBars(repeat)
                transitState()
            }
            else if (mode = "VISUAL")
            {
                deleteBeats(1)
                resetState()
            }
            else
            {
                setState({awaitsMotion: "d"})
            }
            return
        +d::
            keyWait, shift
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
            keyWait, ctrl
            redo(repeat)
            resetState()
            return

        r::
            resetState({mode: "INSERT"})
            return
        i::
            insertBeat()
            resetState({mode: "INSERT"})
            return
        +i::
            keyWait, shift
            insertBeatToBeginning()
            resetState({mode: "INSERT"})
            return
        a::
            appendBeat()
            resetState({mode: "INSERT"})
            return
        +a::
            keyWait, shift
            appendBeatToEnd()
            resetState({mode: "INSERT"})
            return
        c::
            if (awaitsMotion = "c")
            {
                changeBars(repeat)
                resetState({mode: "INSERT"})
            }
            else if (mode = "VISUAL")
            {
                deleteBeats(1)
                resetState({mode: "INSERT"})
            }
            else
            {
                awaitsMotion := "c"
            }
            return
        +c::
            keyWait, shift
            if (mode = "VISUAL")
            {
                deleteBars(1)
                resetState({mode: "INSERT"})
            }
            else
            {
                deleteBeatsToEnd(repeat)
                resetState({mode: "INSERT"})
            }
            return
        s::
            substituteBeats(repeat)
            resetState({mode: "INSERT"})
            return
        +s::
            keyWait, shift
            clearBars(repeat)
            resetState({mode: "INSERT"})
            return

        v::
            selectBeats(repeat)
            resetState({mode: "VISUAL"})
            return
        ; +v::
        ;     keyWait, shift
        ;     selectBars(repeat)
        ;     resetState({mode: "V-LINE"})
        ;     return
