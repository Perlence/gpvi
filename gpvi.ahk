#noEnv
#singleInstance, force
sendMode, input
setWorkingDir, %A_ScriptDir%

; Wait for dialog to show up.
DIALOG_DELAY := 50
; Wait for bar to select.
BAR_SELECTION_DELAY := 10

global mode, repeat, awaitsMotion

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

/**
 * Switch mode based on current state.
 */
transitState() {
    global awaitsMotion, mode
    state := {}
    if (awaitsMotion = "c")
        state["mode"] := "INSERT"
    else if (mode = "VISUAL")
        state["mode"] := "VISUAL"
    else if (mode = "V-LINE")
        state["mode"] := "V-LINE"
    resetState(state)
}

moveCursor(direction, times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {ctrl down}{shift down}
    send, {%direction% %times%}
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {ctrl up}{shift up}
}

goToEnd(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeginning(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeginningOfNextBar(times) {
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-LINE")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-LINE")
        send, {shift up}
}

goToBeatOfBar(number) {
    goToBeginning(1)
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToAbsoluteBeat(number) {
    goToBeginningOfScore()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToBeginningOfScore() {
    send, {ctrl down}{home}{ctrl up}
}

goToEndOfScore() {
    send, {ctrl down}{end}{ctrl up}
    goToBeginning(1)
}

goToBar(number) {
    goToBeginningOfScore()
    goToBeginningOfNextBar(number - 1)
}

goToNextMarker(number) {
    send, {ctrl down}{tab %number%}{ctrl up}
}

goToPreviousMarker(number) {
    send, {shift down}{tab %number%}{shift up}
}

insertMarker() {
    send, {shift down}{insert}{shift up}
}

listMarkers() {
    ; send, {alt}ml
    send, {alt}{right 6}{down 2}{enter}
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
    times := abs(numberOfBars)
    send, {ctrl down}{shift down}
    loop, %times%
    {
        send, {%direction%}
        sleep, BAR_SELECTION_DELAY
    }
    send, {ctrl up}{shift up}
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

deleteBeats(times, cut:=false) {
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    if (abs(times) = 1)
    {
        if (times < 0)
        {
            send, {left}
        }
        send, {shift down}{up}{down}{shift up}%delete%
    }
    else
    {
        selectBeats(times)
        send, %delete%
    }
}

deleteBeatsToEnd(times, cut:=false) {
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToEnd(times)
    send, %delete%
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBeatsToBeginning(times, cut:=false) {
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToBeginning(times)
    send, %delete%
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

changeBeats(numberOfBeats) {
    if (numberOfBeats = 1)
    {
        replaceWithRest()
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

paste() {
    send, {ctrl down}v{ctrl up}
    sleep, DIALOG_DELAY
    send, {enter}
}

replaceWithRest() {
    send, r
}

insertBeat() {
    send, {insert}
}

insertBeatToBeginning() {
    send, {home}{insert}
}

appendBeat() {
    ; Could be better.
    send, {enter}
}

appendBeatToEnd() {
    send, {end}{enter}
}

insertBar() {
    send, {ctrl down}{insert}{ctrl up}
}

appendBar() {
    ; Uses clipboard -- not optimal.
    insertBar()
    send, {right}
    deleteBeatsToEnd(1, true)
    send, {left}
    paste()
}

transposeUp(times) {
    loop, %times%
    {
        ; send, {alt}nuu{enter}
        send, {alt}{right 4}{down 19}{enter}
    }
}

transposeDown(times) {
    loop, %times%
    {
        send, {alt}{right 4}{down 20}{enter}
    }
}

deselect() {
    send, {escape}
}

#if WinActive("Guitar Pro 5")
    escape::
        send, {escape}
        resetState()
        return
    ^c::
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
            if (awaitsMotion = "d")
            {
                deleteBeats(-repeat)
            }
            else if (awaitsMotion = "c")
            {
                changeBeats(-repeat)
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
            if (awaitsMotion = "d")
            {
                deleteBeats(repeat)
            }
            else if (awaitsMotion = "c")
            {
                changeBeats(repeat)
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
        |::
            goToBeatOfBar(repeat)
            resetState()
            return

        ; Score navigation
        g::
            if (awaitsMotion = "g")
            {
                if (repeat = 1)
                {
                    goToBeginningOfScore()
                }
                else
                {
                    goToBar(repeat)
                }
                resetState()
            }
            else
            {
                setState({awaitsMotion: "g"})
            }
            return
        +g::
            if (repeat = 1)
            {
                goToEndOfScore()
            }
            else
            {
                goToBar(repeat)
            }
            return
        [::
            if (awaitsMotion = "]")
            {
                goToNextMarker(repeat)
                resetState()
            }
            else if (awaitsMotion = "[")
            {
                goToPreviousMarker(repeat)
                resetState()
            }
            else
            {
                setState({awaitsMotion: "["})
            }
            return
        ]::
            if (awaitsMotion = "]")
            {
                goToNextMarker(repeat)
                resetState()
            }
            else if (awaitsMotion = "[")
            {
                goToPreviousMarker(repeat)
                resetState()
            }
            else
            {
                setState({awaitsMotion: "]"})
            }
            return
        m::
            insertMarker()
            resetState()
            return
        +m::
            keyWait, shift
            listMarkers()
            resetState()
            return

        ; Deletion
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
            else if (mode = "V-LINE")
            {
                deleteBars(1)
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

        ; Undo/redo keys
        u::
            undo(repeat)
            resetState()
            return
        ^r::
            keyWait, ctrl
            redo(repeat)
            resetState()
            return

        ; Replace, insert, and append
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
        o::
            if (awaitsMotion = "g")
            {
                goToAbsoluteBeat(repeat)
                resetState()
            }
            else
            {
                appendBar()
                resetState({mode: "INSERT"})
            }
            return
        +o::
            keyWait, shift
            insertBar()
            resetState({mode: "INSERT"})
            return
        ^a::
            keyWait, ctrl
            transposeUp(repeat)
            resetState()
            return
        ^x::
            keyWait, ctrl
            transposeDown(repeat)
            resetState()
            return

        ; Substitution and change
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
            else if (mode = "V-LINE")
            {
                deleteBars(1)
                insertBar()
                resetState({mode: "INSERT"})
            }
            else
            {
                setState({awaitsMotion: "c"})
            }
            return
        +c::
            keyWait, shift
            if (mode = "VISUAL")
            {
                deleteBars(1)
                insertBar()
                resetState({mode: "INSERT"})
            }
            else
            {
                deleteBeatsToEnd(repeat)
                resetState({mode: "INSERT"})
            }
            return
        s::
            if (mode = "VISUAL")
            {
                deleteBeats(1)
                resetState({mode: "INSERT"})
            }
            else if (mode = "V-LINE")
            {
                deleteBars(1)
                insertBar()
                resetState({mode: "INSERT"})
            }
            else
            {
                changeBeats(repeat)
            }
            resetState({mode: "INSERT"})
            return
        +s::
            keyWait, shift
            clearBars(repeat)
            resetState({mode: "INSERT"})
            return

        ; Visual mode
        v::
            if (mode = "VISUAL")
            {
                deselect()
                resetState()
            }
            else if (mode = "V-LINE")
            {
                resetState({mode: "VISUAL"})
            }
            else
            {
                selectBeats(repeat)
                resetState({mode: "VISUAL"})
            }
            return
        +v::
            keyWait, shift
            if (mode = "V-LINE")
            {
                deselect()
                resetState()
            }
            else if (mode = "VISUAL")
            {
                resetState({mode: "V-LINE"})
            }
            else
            {
                selectBars(repeat)
                resetState({mode: "V-LINE"})
            }
            return
