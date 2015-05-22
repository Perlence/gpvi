_openProcess(processId, desiredAccess:=0x10, inheritHandle:=false)
{
    return dllCall("OpenProcess", UInt, desiredAccess, Char, inheritHandle, UInt, processId)
}

_closeHandle(hProcess)
{
    dllCall("CloseHandle", UInt, hProcess)
}

_readProcessMemory(hProcess, baseAddress, type)
{
    global TYPE_SIZES
    size := TYPE_SIZES[type]
    varSetCapacity(buffer, size, 0)
    result := dllCall("ReadProcessMemory", UInt, hProcess, UPtr, baseAddress, type, &buffer, UInt, size, UPtr, 0)
    data := numGet(buffer, , type)
    return data
}

getHProcess()
{
    global hProcess
    if (hProcess)
        return hProcess
    winGet, pid, pid, %WIN_TITLE%
    hProcess := _openProcess(pid)
    return hProcess
}

readOffset(baseAddress, offset, type)
{
    hProcess := getHProcess()
    startAddr := _readProcessMemory(hProcess, baseAddress, "UInt")
    return _readProcessMemory(hProcess, (startAddr + offset), type)
}

/**
 * Use memory magic to check if user selected beats of bars.
 */
getSelectionMode()
{
    global CURSOR_BASE_ADDR, IS_SELECTED_OFFSET
    selected := readOffset(CURSOR_BASE_ADDR, IS_SELECTED_OFFSET, "UShort")
    if (selected = 0x01)
        return "beats"
    else if (selected = 0x0101)
        return "bars"
    else
        return ""
}

/**
 * Use memory magic to determine cursor position in current bar.
 */
getCursorPosition()
{
    global CURSOR_BASE_ADDR, CURSOR_X_OFFSET, CURSOR_Y_OFFSET
    cursorX := readOffset(CURSOR_BASE_ADDR, CURSOR_X_OFFSET, "UInt")
    cursorY := readOffset(CURSOR_BASE_ADDR, CURSOR_Y_OFFSET, "UInt")
    return [cursorX, cursorY]
}

/**
 * Check if cursor is on the first beat of the current bar
 */
isBarStart()
{
    cursorX1 := getCursorPosition()[1]
    return (cursorX1 = 1)
}

/**
 * Check if cursor is on the last beat of the current bar
 *
 * @param {bool} returnBack - the function moves cursor to the left to
 *   check if cursor position became 1, then it moves cursor back. Set
 *   this argument to `false` to not go left.
 */
isBarEnd(returnBack:=true)
{
    ; FIXME: Creates empty bar in the end if testing on the last beat of the last bar
    cursorX1 := getCursorPosition()[1]
    moveCursor("right")
    cursorX2 := getCursorPosition()[1]
    result := (cursorX2 = 1 or cursorX1 = cursorX2)
    if (returnBack and cursorX1 != cursorX2)
        moveCursor("left")
    return result
}
