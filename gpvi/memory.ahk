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

getCursorPosition()
{
    global CURSOR_BASE_ADDR, CURSOR_X_OFFSET, CURSOR_Y_OFFSET
    cursorX := readOffset(CURSOR_BASE_ADDR, CURSOR_X_OFFSET, "UInt")
    cursorY := readOffset(CURSOR_BASE_ADDR, CURSOR_Y_OFFSET, "UInt")
    return [cursorX, cursorY]
}
