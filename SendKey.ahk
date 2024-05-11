#Requires AutoHotkey v2.0

F1:: {
    Send A_Tab
    Sleep 100
    Send "KHYC"

    Send A_Tab
    Sleep 100
    Send "OK"

    Send A_Tab
    Sleep 100
    Send "Yeu cau ve dich vu Mobile Internet cua Quy khach da duoc xu ly. Chi tiet lien he 9090, MobiFone han hanh duoc phuc vu."

    Sleep 1000
    Send A_Tab
    Sleep 2000
    Send "{Enter}"

    Run "https://qlkh.mobifone.vn/fbtt/ReceiveMain"
}