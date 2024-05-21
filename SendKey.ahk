#Requires AutoHotkey v2.0
#SingleInstance force

F1:: {
    ProcessAutomation(1)
}
F2:: {
    ProcessAutomation(2)
}

ProcessAutomation(action) {
    ; Ô dropdown hành động - chọn dang ky
    Send "{Tab}"
    Sleep 300
    if (action = 1)
        Send "71"
    else if (action = 2)
        Send "72"
    Sleep 300
    Send "{Enter}"
    Sleep 200
    Send "{Tab}"
    Sleep 50
    ; Ô chọn cảm xúc KH
    Send "Hài lòng"
    Sleep 300
    Send "{Enter}"
    Sleep 100
    Send "{Tab}"
    Sleep 50
    ; Ô mô tả nguyên nhân phía KH
    Send "KHYC"
    Sleep 100
    Send "{Tab}"
    Sleep 50
    ; Ô mô tả cảm xúc phía KH
    Send "OK"
    Sleep 100
    Send "{Tab}"
    ; Ô mô tả cảm xúc phía KH
    Sleep 100
    Send "Yeu cau ve dich vu Mobile Internet cua Quy khach da duoc xu ly. Chi tiet lien he 9090, MobiFone han hanh duoc phuc vu."
    Sleep 1500
    Send "{Tab}"
    Sleep 500
    ; Chọn ô nhập
    Send "{Enter}"
}