#Requires AutoHotkey v2.0
#SingleInstance force

Open() {
    CentPath := "C:\Users\Administrator\AppData\Local\CentBrowser\Application\chrome.exe"
    SleepLongTime := 2000
    SleepShortTime := 500
    ; Windows THÔNG TIN
    Run CentPath
    Sleep 5000
    SendText "Linh210399"
    Send "{Enter}"
    Sleep SleepLongTime

    WinWait "New Tab - Cent Browser"
    WinMaximize

    Run "http://10.39.220.163:8030/wallBoard-realTime"
    Sleep SleepShortTime
    Send "^1"
    Sleep SleepShortTime
    Send "^w"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://chat.zalo.me/"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://www.messenger.com"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://mail247.vn/"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://1090.mobifone.vn/index/danh_ba_gd.jsp/U2FsdGVkX183Ex35WXcY%2BHehmT%2B7qDx2EZr%2BiXAxDEw%3D/U2FsdGVkX1%2BCL8t4lHEF%2BwOJt6%2F%2BuOGdTf1SP%2BqPViU%3D/U2FsdGVkX1%2FZ11%2BeN5VyAd%2BlzL%2BzxxtJ1F6gwV4SWtI%3D"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://1090.mobifone.vn/public/category.jsp?p_type=1&p_child=2&p_menu=1544&p_view_type=5"
    Sleep SleepShortTime

    Run "https://www.mobifone.vn/dich-vu-di-dong/quoc-te/thue-bao-mobifone-ra-nuoc-ngoai?"
    Sleep SleepShortTime

    Run "http://funring.vn/module/search.jsp?q=chi+rieng+minh+ta"
    Sleep SleepShortTime

    ; WINDOWS DTV
    Run CentPath
    Sleep SleepLongTime

    WinWait "New Tab - Cent Browser"
    WinMaximize

    Run "https://omnichannel.mobifone.vn/pages/Portal.html"
    Sleep SleepShortTime
    Send "^1"
    Sleep SleepShortTime
    Send "^w"
    Sleep SleepShortTime
    Send "!n"

    Run "https://omni.mobifone.vn/logout"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://qlkh.mobifone.vn/fbtt/ReceiveMain"
    Sleep SleepShortTime
    Send "!n"
    Sleep SleepShortTime

    Run "https://tracuu.mobifone.vn/1090/main.jsp"
    Sleep SleepShortTime

    Run "https://tracuu.mobifone.vn/1090/main.jsp"
    Sleep SleepShortTime

    Run "https://10.3.17.147:9009/layout"
    Sleep SleepShortTime

    Run "http://10.50.9.105:8888/VASP/faces/vas/report/ultSearchObject.xhtml"

    Sleep SleepLongTime

    Run "C:\Users\Administrator\AppData\Local\CentBrowser\Application\chrome_proxy.exe  --profile-directory=`"Profile 1`" --app-id=fhihpiojkbmbpdjeoajapmgkhlnakfjf"
    Sleep SleepShortTime

    Run "C:\Program Files\Inbit\Inbit Messenger\IMC.exe"
}
^Escape:: {
    if ProcessExist("chrome.exe") {
        ProcessClose("chrome.exe")
        ProcessClose("IMC.EXE")
        DllCall("user32.dll\LockWorkStation")
    }
    else
        Open()
}