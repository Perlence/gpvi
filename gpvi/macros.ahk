moveCursor(direction, times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {ctrl down}{shift down}
    send, {%direction% %times%}
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {ctrl up}{shift up}
}

goToEnd(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {right}{end}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginning(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {left}{home}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeginningOfNextBar(times:=1)
{
    global mode
    if (mode = "VISUAL")
        send, {shift down}
    else if (mode = "V-BAR")
        send, {shift down}
    loop, %times%
    {
        send, {end}{right}
    }
    if (mode = "VISUAL")
        send, {shift up}
    else if (mode = "V-BAR")
        send, {shift up}
}

goToBeatOfBar(number:=1)
{
    goToBeginning()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToAbsoluteBeat(number:=1)
{
    goToBeginningOfScore()
    if (number > 1)
    {
        moveCursor("right", (number - 1))
    }
}

goToBeginningOfScore()
{
    send, {ctrl down}{home}{ctrl up}
}

goToEndOfScore()
{
    send, {ctrl down}{end}{ctrl up}
    goToBeginning()
}

goToBar(number:=1)
{
    goToBeginningOfScore()
    goToBeginningOfNextBar(number - 1)
}

goToNextMarker(number:=1)
{
    send, {ctrl down}{tab %number%}{ctrl up}
}

goToPreviousMarker(number:=1)
{
    send, {shift down}{tab %number%}{shift up}
}

alternateWindow()
{
    global WIN_TITLE
    curId := WinActive(WIN_TITLE)
    winGet, id, list, %WIN_TITLE%
    if id > 1
    {
        winShow, ahk_id %id2%
        winActivate, ahk_id %id2%
    }
}

insertMarker()
{
    send, {shift down}{insert}{shift up}
}

listMarkers()
{
    ; send, {alt}ml
    send, {alt}{right 6}{down 2}{enter}
}

/**
 * Select given number of beats limited to current bar.
 *
 * @param {int} numberOfBeats - number of beats to select. If number is
 *   positive then select beats to the right, else select beats to the
 *   left.
 * @return {int} - number of selected beats.
 */
selectBeats(numberOfBeats:=1)
{
    cursorCur := getCursorPosition()[1]
    if (numberOfBeats < 0)
    {
        if (cursorCur = 1)
            return 0
        times := min(cursorCur - 1, abs(numberOfBeats)) - 1
        send, {left}{shift down}{up}{down}{left %times%}{shift up}
        return times + 1
    }
    else
    {
        times := abs(numberOfBeats) - 1
        send, {shift down}{up}{down}
        selected := 1
        loop, %times%
        {
            send, {right}
            cursorPrev := cursorCur
            cursorCur := getCursorPosition()[1]
            if (cursorCur != cursorPrev + 1)
            {
                send, {left}
                break
            }
            selected += 1
        }
        send, {shift up}
        return selected
    }
}

selectBars(numberOfBars:=1)
{
    global BAR_SELECTION_DELAY
    direction := (numberOfBars > 0) ? "right" : "left"
    times := abs(numberOfBars)
    send, {ctrl down}{shift down}
    loop, %times%
    {
        send, {%direction%}
        sleep, %BAR_SELECTION_DELAY%
    }
    send, {ctrl up}{shift up}
}

selectBeatsToEnd(times:=1)
{
    send, {shift down}{up}{down}
    goToEnd(times)
    send, {shift up}
}

selectBeatsToBeginning(times:=1)
{
    send, {left}{shift down}{up}{down}
    goToBeginning(times)
    send, {home}{shift up}
}

selectBeatsToBeginningOfNextBar(times:=1)
{
    send, {shift down}{up}{down}
    goToBeginningOfNextBar(times)
    send, {shift up}
}

selectToMouse()
{
    send {shift down}{lbutton}{shift up}
}

deleteNotes(numberOfNotes:=1)
{
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

/**
 * Delete beats in current bar.
 */
deleteBeats(times:=1, cut:=false)
{
    global mode
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    if (abs(times) = 1)
    {
        if (times < 0)
        {
            cursor := getCursorPosition()[1]
            if (cursor = 1)
                return
            send, {left}
        }
        if (mode = "NORMAL")
        {
            send, {shift down}{up}{down}{shift up}
        }
        send, %delete%
    }
    else
    {
        if (selectBeats(times))
            send, %delete%
    }
}

deleteBeatsToEnd(times:=1, cut:=false)
{
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToEnd(times)
    send, %delete%
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBeatsToBeginning(times:=1, cut:=false)
{
    delete := not cut ? "{delete}" : "{ctrl down}x{ctrl up}"
    selectBeatsToBeginning(times)
    send, %delete%
    if (times > 1)
    {
        times -= 1
        send, {left %times%}
    }
}

deleteBars(numberOfBars:=1)
{
    global DIALOG_DELAY
    if (numberOfBars > 1)
    {
        selectBars(numberOfBars)
    }
    send, {ctrl down}x{ctrl up}
    winWaitActive, Cut, , % DIALOG_DELAY / 1000
    if (not errorLevel)
        send, {enter}
}

clearBars(numberOfBars:=1)
{
    selectBars(numberOfBars)
    send, {delete}
    times := numberOfBars - 1
    send, {left %times%}
}

/**
 * Replace beats to the right with a rest.
 */
changeBeats(numberOfBeats:=1)
{
    if (numberOfBeats = 1)
    {
        replaceWithRest()
    }
    else
    {
        selected := selectBeats(numberOfBeats)
        if (not selected)
            return
        deselect()
        appendBeat()
        deleteBeats(-min(numberOfBeats, selected))
    }
}

yank(times:=1)
{
    global DIALOG_DELAY
    send, {ctrl down}c{ctrl up}
    winWaitActive, Copy, , % DIALOG_DELAY / 1000
    if errorLevel
    {
        deselect()
    }
    else
    {
        if (times > 1)
        {
            times -= 1
            send, {tab}{up %times%}{enter}
        }
        send, {enter}
    }
}

/**
 * Yank beats in current bar.
 */
yankBeats(times:=1)
{
    if (selectBeats(times))
        yank()
}

yankBeatsToBeginning(times:=1)
{
    selectBeatsToBeginning(times)
    yank()
}

yankBeatsToBeginningOfNextBar(times:=1)
{
    selectBeatsToBeginningOfNextBar(times)
    yank()
}

yankBeatsToEnd(times:=1)
{
    selectBeatsToEnd(times)
    yank()
}

yankBars(times:=1)
{
    yank(times)
}

put(putMode:="overwrite", times:=1)
{
    global DIALOG_DELAY
    send, {ctrl down}v{ctrl up}
    winWaitActive, Paste, , % DIALOG_DELAY / 1000
    if (errorLevel)
    {
        loop, % times - 1
        {
            ; FIXME: Will mess up next bar if current bar misses one beat and
            ; beats in clipboard make it complete
            send, {enter}{ctrl down}v{ctrl up}
        }
    }
    else
    {
        send, {tab 2}

        if (putMode = "insert")
            send, {down}
        else if (putMode = "append")
            send, {down 2}

        if (times > 1)
        {
            times -= 1
            send, {tab}{up %times%}
        }
        send, {enter}
    }
}

putLeft(putMode:="overwrite", times:=1)
{
    put(putMode, times)
    moveCursor("right")
}

putToMouse()
{
    send, {lbutton}
    putLeft("insert")
}

undo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}z{ctrl up}
    }
}

redo(times:=1)
{
    loop, %times%
    {
        send, {ctrl down}Z{ctrl up}
    }
}

replaceWithRest()
{
    send, r
}

insertBeat()
{
    send, {insert}
}

insertBeatToBeginning()
{
    send, {home}{insert}
}

appendBeat()
{
    if (isBarEnd(false))
        send, {left}cr
    else
        send, {insert}r
}

appendBeatToEnd()
{
    send, {end}
    appendBeat()
}

insertBar()
{
    send, {ctrl down}{insert}{ctrl up}
}

appendBar()
{
    ; FIXME: Creates 2 empty bars if called on the last bar
    goToBeginningOfNextBar()
    insertBar()
}

transposeUp(times:=1)
{
    loop, %times%
    {
        ; send, {alt}nuu{enter}
        send, {alt}{right 4}{down 19}{enter}
    }
}

transposeDown(times:=1)
{
    loop, %times%
    {
        send, {alt}{right 4}{down 20}{enter}
    }
}

deselect()
{
    send, {escape}
}
