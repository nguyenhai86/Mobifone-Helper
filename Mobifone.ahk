#requires AutoHotkey v2.0
#SingleInstance force

fontGUI := "Segoe UI"
; ------------------------
; json
; ------------------------
#Include jsongo.ahk
LoadMobifoneData() {
    try {
        fileContent := FileRead("mobifone_data.json", "UTF-8")
        data := jsongo.Parse(fileContent)
        return data
    } catch Error as e {
        MsgBox "Error loading mobifone_data.json: " e.Message
        return Map()
    }
}


;-------------------------
; Helpers functions
;-------------------------
GetSelectedText() {
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    selectedText := Trim(A_Clipboard)
    A_Clipboard := oldClipboard
    return selectedText
}
DateAdd_Custom(date, days) {
    return DateAdd(date, days, "days")
}
FormatDate(date) {
    return FormatTime(date, "dd MMM yyyy")
}
DateDiff__Custom(date) {
    return DateDiff(A_Now, date, "days")
}
DateParse(str, americanOrder := 0) {
    ; Definition of several RegExes
    static monthNames := "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-zA-Z]*"
        , dayAndMonth := "(\d{1,2})[^a-zA-Z0-9:.]+(\d{1,2})"
        , dayAndMonthName := "(?:(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Day>\d{1,2})[^a-zA-Z0-9]+|(?<Day>\d{1,2})[^a-zA-Z0-9:.]*(?<Month>" . monthNames . "))"
        , monthNameAndYear := "(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Year>(?:\d{4}|\d{2}))"

    ampm := "am"
    if RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", &i) { ;ISO 8601 timestamps
        year := i.1, month := i.3, day := i.4, hour := i.5, minute := i.7, second := i.8
    }
    else if !RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &t) { ; NOT timestring only eg 1535
        ; Try to extract the time parts
        FoundPos := RegExMatch(str, "i)(\d{1,2})"	;hours
            . "\s*:\s*(\d{1,2})"				;minutes
            . "(?:\s*:\s*(\d{1,2}))?"			;seconds
            . "(?:\s*([ap]m))?", &timepart)		;am/pm
        if (FoundPos) {
            ; Time is already parsed correctly from striing
            hour := timepart.1
            minute := timepart.2
            second := timepart.3
            ampm := timepart.4
            ; Remove time to parse the date part only
            str := StrReplace(str, timepart.0)
        }
        ; Now handle the remaining string without time and try to extract date ...
        if RegExMatch(str, "Ji)" . dayAndMonthName . "[^a-zA-Z0-9]*(?<Year>(?:\d{4}|\d{2}))?", &d) { ; named month eg 22May14; May 14, 2014; 22May, 2014
            year := d.Year, month := d.Month, day := d.Day
        }
        else if RegExMatch(str, "i)" . monthNameAndYear, &d) { ; named month and year without day eg May14; May 2014
            year := d.Year, month := d.Month
        }
        else if RegExMatch(str, "i)" . "^\W*(?<Year>\d{4})(?<Month>\d{2})\W*$", &d) { ;  month and year as digit only eg 201710
            year := d.Year, month := d.Month
        }
        else {
            ; Default values - if some parts are not given
            if ( not IsSet(day) and not IsSet(month) and not IsSet(year)) {
                ; No datepart is given - use today
                year := A_YYYY
                month := A_MM
                day := A_DD
            }
            if RegExMatch(str, "i)(\d{4})[^a-zA-Z0-9:.]+" . dayAndMonth, &d) { ;2004/22/03
                year := d.1, month := d.3, day := d.2
            }
            else if RegExMatch(str, "i)" . dayAndMonth . "(?:[^a-zA-Z0-9:.]+((?:\d{4}|\d{2})))?", &d) { ;22/03/2004 or 22/03/04
                year := d.3, month := d.2, day := d.1
            }
            if (RegExMatch(day, monthNames) or americanOrder and !RegExMatch(month, monthNames) or (month > 12 and day <= 12)) { ;try to infer day/month order
                tmp := month, month := day, day := tmp
            }
        }
    }
    else if RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &timepart) { ; timestring only eg 1535
        hour := timepart.hour
        minute := timepart.minute
        ; Default values - if some parts are not given
        if ( not IsSet(day) and not IsSet(month) and not IsSet(year)) {
            ; No datepart is given - use today
            year := A_YYYY
            month := A_MM
            day := A_DD
        }
    }

    if (IsSet(day) or IsSet(month) or IsSet(year)) and not (IsSet(day) and IsSet(month) and IsSet(year)) { ; partial date
        if (IsSet(year) and not IsSet(month)) or not (IsSet(day) or IsSet(month)) or (IsSet(hour) and not IsSet(day)) { ; partial date must have month and day with time or day or year without time
            return
        }
    }

    ; Default values - if some parts are not given
    if (IsSet(year) and IsSet(month) and not IsSet(day)) {
        ; year and month given without day - use first day
        day := 1
    }

    ; Format the single parts
    oYear := (StrLen(year) == 2 ? "20" . year : (year))
    oYear := Format("{:02.0f}", oYear)

    if (isInteger(month)) {
        currMonthInt := month
    } else {
        currMonthInt := InStr(monthNames, SubStr(month, 1, 3)) // 4
    }
    ; Original: oMonth := ((month := month + 0 ? month : InStr(monthNames, SubStr(month, 1, 3)) // 4 ) > 0 ? month + 0.0 : A_MM)
    ; oMonth := ((month := month + 0 ? month : currMonthInt ) > 0 ? month + 0.0 : A_MM)
    ; oMonth := Format("{:02.0f}", oMonth)
    oMonth := Format("{:02.0f}", currMonthInt)

    oDay := day
    oDay := Format("{:02.0f}", oDay)

    if (IsSet(hour)) {
        if (hour != "") {
            oHour := hour + (hour == 12 ? ampm = "am" ? -12.0 : 0.0 : ampm = "pm" ? 12.0 : 0.0)
            oHour := Format("{:02.0f}", oHour)

            if (IsSet(minute)) {
                oMinute := minute + 0.0
                oMinute := Format("{:02.0f}", oMinute)

                if (IsSet(second)) {
                    if (second != "") {
                        oSecond := second + 0.0
                        oSecond := Format("{:02.0f}", oSecond)
                    }
                }
            }
        }
    }

    retVal := oYear . oMonth . oDay
    if (IsSet(oHour)) {
        retVal := retVal . oHour . oMinute
        if (IsSet(oSecond)) {
            retVal := retVal . oSecond
        }
    }
    return retVal
}
loopkup(value, key) {
    if value.HasOwnProp(key) = 1 {
        return value.GetOwnPropDesc(key).Value
    }
    else {
        return "Key not found"
    }
}

;-------------------------
; Hotkeys
;-------------------------
;*  Always on top
^+t:: { ; Alt + t
    Title_When_On_Top := "! "       ; change title "! " as required
    t := WinGetTitle("A")
    ExStyle := WinGetExStyle(t)
    If (ExStyle & 0x8) {            ; 0x8 is WS_EX_TOPMOST
        WinSetAlwaysOnTop 0, t      ; Turn OFF and remove Title_When_On_Top
        WinSetTitle (RegExReplace(t, Title_When_On_Top)), t
    }
    Else {
        WinSetAlwaysOnTop 1, t      ; Turn ON and add Title_When_On_Top
        WinSetTitle Title_When_On_Top t, t
    }
}

;* Date Calculator
^+q:: {
    dateString := GetSelectedText()
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }

    ; Create GUI with modern style
    titleGUI := "Date Calculator"
    MyGui := Gui("+AlwaysOnTop -Caption", titleGUI)
    MyGui.BackColor := "FFFFFF" ; White background

    ; Title section
    MyGui.SetFont("s14 bold", fontGUI)
    MyGui.Add("Text", "x20 y20 w300 Center", "DATE CALCULATOR")

    ; Add full-width separator line
    MyGui.Add("Text", "x20 y50 w300 c808080", "────────────────────────────────────────")

    ; Current date with column headers
    MyGui.SetFont("s10 bold", fontGUI)
    MyGui.Add("Text", "x20 y70 w80", "CURRENT")
    MyGui.SetFont("s10", fontGUI)
    MyGui.Add("Text", "x120 y70 w200", FormatDate(date))

    ; Content rows
    y := 110
    intervals := [[4, "+4 Days"], [10, "+10 Days"], [14, "+14 Days"],
        [30, "+30 Days"], [45, "+45 Days"], [60, "+60 Days"]]

    for interval in intervals {
        days := interval[1]
        label := interval[2]
        futureDate := DateAdd_Custom(date, days)

        ; Add separator line
        if (A_Index > 1) {
            MyGui.Add("Text", "x20 y" y - 18 " w300 c808080", "────────────────────────────────────────")
        }

        ; Label column
        MyGui.Add("Text", "x20 y" y " w80", days " Days")

        ; Date column with color based on past/future
        color := DateDiff__Custom(futureDate) > 0 ? "c007AFF" : "c808080" ; Apple blue
        MyGui.Add("Text", "x120 y" y " w200 " color, FormatDate(futureDate))

        y += 35
    }

    ; Add minimalist close button
    closeBtn := MyGui.Add("Text", "x315 y5 w20 h20 Center", "×")
    closeBtn.SetFont("s14")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Add window drag ability
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }

    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.Show("w340 h340")
}

^+e:: {
    dateString := GetSelectedText()
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }

    ; Create GUI with modern style
    titleGUI := "Payment Cycles"
    MyGui := Gui("+AlwaysOnTop -Caption", titleGUI)
    MyGui.BackColor := "FFFFFF" ; Light background

    ; Title section
    MyGui.SetFont("s14 bold", fontGUI)
    MyGui.Add("Text", "x20 y20 w300 Center", "PAYMENT CYCLES")

    ; Add full-width separator line
    MyGui.Add("Text", "x20 y50 w300 c808080", "────────────────────────────────────────")

    ; Column headers
    MyGui.SetFont("s10 bold", fontGUI)
    MyGui.Add("Text", "x20 y70 w80", "CYCLE")
    MyGui.Add("Text", "x120 y70 w100", "30 DAYS")
    MyGui.Add("Text", "x220 y70 w100", "31 DAYS")

    ; Content rows
    MyGui.SetFont("s10", fontGUI)
    y := 110

    loop 17 {
        ; Calculate dates
        lastDate30 := DateAdd_Custom(date, 30 * (A_Index - 1))
        lastDate31 := DateAdd_Custom(date, 31 * (A_Index - 1))

        ; Add full-width separator
        if (A_Index > 1) {
            MyGui.Add("Text", "x20 y" y - 18 " w300 c808080", "────────────────────────────────────────")
        }

        ; Cycle number
        MyGui.Add("Text", "x20 y" y " w80", A_Index)

        ; 30 day date
        color := DateDiff__Custom(lastDate30) > 0 ? "c007AFF" : "c808080" ; Apple blue
        MyGui.Add("Text", "x120 y" y " w100 " color, FormatDate(lastDate30))

        ; 31 day date
        color := DateDiff__Custom(lastDate31) > 0 ? "c007AFF" : "c808080"
        MyGui.Add("Text", "x220 y" y " w100 " color, FormatDate(lastDate31))

        y += 35
    }

    ; Add expired row with Apple red
    MyGui.Add("Text", "x20 y" y " w80 cFF3B30", "Expired")

    ; Add minimalist close button
    closeBtn := MyGui.Add("Text", "x315 y5 w20 h20 Center", "×")
    closeBtn.SetFont("s14")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Add window drag ability
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }

    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.Show("w340 h700")
}

;* Tra cứu các profile đăng ký gói DT20
^+y:: {
    ; Define eligible profiles
    profiles := Map()
    for _, v in ["QT2", "TT2", "YT2", "RZT2", "SVT2", "TNT2", "WT2", "KT2", "TBT2", "Q263", "QTN1", "QTN2", "HAT2", "MCP", "SBK", "BKS", "ZMT", "DHMT", "ZHN", "W2G"]
        profiles[v] := true

    profile := Trim(GetSelectedText())
    canRegister := profiles.Has(profile)

    ; Create main GUI
    titleGUI := "Profile Checker"
    MyGui := Gui("+AlwaysOnTop -Caption", titleGUI)
    MyGui.BackColor := "FFFFFF"

    ; Add title
    MyGui.SetFont("s14 bold", fontGUI)
    MyGui.Add("Text", "x20 y20 w300 Center", "KIỂM TRA GÓI DT20")

    ; Add separator
    MyGui.Add("Text", "x20 y50 w300 c808080", "────────────────────────────────────────")

    ; Current profile section
    MyGui.SetFont("s10 bold", fontGUI)
    MyGui.Add("Text", "x20 y80", "PROFILE:")
    MyGui.Add("Text", "x120 y80 c007AFF", profile) ; Apple blue

    ; Status section
    MyGui.SetFont("s10 bold", fontGUI)
    MyGui.Add("Text", "x20 y120", "TRẠNG THÁI:")

    statusColor := canRegister ? "c34C759" : "cFF3B30" ; Apple green/red
    statusText := canRegister ? "✓ Được phép đăng ký" : "✗ Không được phép"
    MyGui.Add("Text", "x120 y120 " statusColor, statusText)

    ; Add warning if not eligible
    if !canRegister {
        MyGui.Add("Text", "x20 y160 w300 cFF9500", "Lưu ý: Profile này không thể đăng ký gói DT20")
    }

    ; Add close button
    closeBtn := MyGui.Add("Text", "x315 y5 w20 h20 Center", "×")
    closeBtn.SetFont("s14")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Add drag functionality
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }

    ; Show GUI
    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.Show("w340 " (canRegister ? "h160" : "h200"))

    ; Auto-close after 3 seconds
    SetTimer () => MyGui.Destroy(), -3000
}
;* Tra cuu so dien thoai tong dai
^+s:: {
    ; Define carrier prefixes and customer service numbers
    prefixes := Map(
        "Viettel", ["86", "96", "97", "98", "32", "33", "34", "35", "36", "37", "38", "39"],
        "Mobifone", ["89", "90", "93", "70", "76", "77", "78", "79"],
        "Vinaphone", ["88", "91", "94", "83", "84", "85", "81", "82"],
        "GtelMobile", ["99", "59"],
        "Vietnamobile", ["92", "52", "56", "58"],
        "Itelecom", ["87"]
    )
    hotline := Map(
        "Viettel", "18008098 - Cuộc gọi miễn phí",
        "Mobifone", "18001090 - Cuộc gọi miễn phí",
        "Vinaphone", "18001091 - Cuộc gọi miễn phí",
        "GtelMobile", "0993 196 196 - Cuộc gọi thông thường",
        "Vietnamobile", "789 - Miễn phí / 0922789789 - Cuộc gọi thông thường",
        "Itelecom", "0877 087 087 - Cuộc gọi thông thường"
    )

    phone := GetSelectedText()
    phone := RegExReplace(phone, "^0", "")
    prefix := SubStr(phone, 1, 2)
    carrier := ""

    for name, arr in prefixes {
        for _, pfx in arr {
            if (prefix = pfx) {
                carrier := name
                break 2
            }
        }
    }

    ; Create minimal GUI
    titleGUI := "Carrier Info"
    MyGui := Gui("+AlwaysOnTop -Caption", titleGUI)
    MyGui.BackColor := "FFFFFF" ; White background

    ; Title section
    MyGui.SetFont("s14 bold", fontGUI)
    MyGui.Add("Text", "x20 y20 w340 Center", "THÔNG TIN NHÀ MẠNG")

    ; Add separator line
    MyGui.Add("Text", "x20 y50 w340 c808080", "────────────────────────────────────────")

    ; Phone number section
    MyGui.SetFont("s10 bold", fontGUI)
    MyGui.Add("Text", "x20 y80", "SỐ ĐIỆN THOẠI:")
    MyGui.Add("Text", "x140 y80 c007AFF", phone) ; Apple blue

    ; Carrier section
    MyGui.Add("Text", "x20 y120", "NHÀ MẠNG:")
    if carrier {
        MyGui.Add("Text", "x140 y120 c34C759", carrier) ; Apple green

        ; Hotline section
        MyGui.Add("Text", "x20 y160", "TỔNG ĐÀI:")
        MyGui.Add("Text", "x140 y160 w220", hotline[carrier])
    } else {
        MyGui.Add("Text", "x140 y120 cFF3B30", "Không tìm thấy") ; Apple red
    }

    ; Add close button
    closeBtn := MyGui.Add("Text", "x355 y5 w20 h20 Center", "×")
    closeBtn.SetFont("s14")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Add window drag ability
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }

    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.Show("w380 " (carrier ? "h200" : "h160"))

    ; Auto-close after 3 seconds
    SetTimer () => MyGui.Destroy(), -3000
}
;* Tra cuu hoa hong dai ly va thuc nhan
^+d:: {
    commissionRateAgent := 0.159
    commissionRateNet := 0.127
    inputBox := InputBox("Nhập giá gói cước", "Tính hoa hồng", "w150 h100")
    packagePrice := Trim(inputBox.Value)

    if packagePrice {
        agentCommission := Round(packagePrice * commissionRateAgent)
        netCommission := Round(packagePrice * commissionRateNet)
        MsgBox Format("Hoa hồng đại lý: {1}`n`nHoa hồng thực nhận: {2}", agentCommission, netCommission)
    }
}
;* Tổng đài ứng tiền
ShowLoanInfoByCodeOrCompletionCode(loanCodes, inputValue) {
    if (loanCodes.HasOwnProp(inputValue))
        return FormatLoanInfo(inputValue, loanCodes[inputValue])

    ; Search by completion code
    for code, info in loanCodes {
        if (info.Get("Mã hoàn ứng") = inputValue)
            return FormatLoanInfo(code, info)
    }
    return Map("error", "Không tìm thấy thông tin cho: " inputValue)
}

FormatLoanInfo(code, info) {
    resultMap := Map()
    resultMap["code"] := code
    for field, value in info {
        resultMap[field] := value
    }
    return resultMap
}

^+u:: {
    data := LoadMobifoneData()
    loanCodes := data.Get("loanCodes")
    inputValue := GetSelectedText()
    result := ShowLoanInfoByCodeOrCompletionCode(loanCodes, inputValue)

    ; Create GUI with Apple-style
    titleGUI := "Loan Service Info"
    MyGui := Gui("+AlwaysOnTop -Caption", titleGUI)
    MyGui.BackColor := "FFFFFF"

    ; Title section with larger font
    MyGui.SetFont("s16 bold", fontGUI)
    MyGui.Add("Text", "x20 y20 w600 Center", "THÔNG TIN ỨNG TIỀN")

    ; Main separator
    MyGui.Add("Text", "x20 y60 w600 c808080", "────────────────────────────────────────────────────────────────────────────")

    y := 90
    if result.Has("error") {
        ; Error message in red
        MyGui.SetFont("s11", fontGUI)
        MyGui.Add("Text", "x20 y" y " w600 cFF3B30", result["error"]) ; Apple red
        height := 140
    } else {
        ; Service code header in blue
        MyGui.SetFont("s11 bold", fontGUI)
        MyGui.Add("Text", "x20 y" y " w600 c007AFF", "Mã dịch vụ: " result["code"]) ; Apple blue
        y += 30

        ; Column headers with separator
        MyGui.Add("Text", "x20 y" y " w600", " ")
        y += 20

        ; Content rows
        MyGui.SetFont("s10", fontGUI)
        for field, value in result {
            if (field != "code") {
                ; Add field name (left column)
                MyGui.SetFont("s10 bold", fontGUI)
                MyGui.Add("Text", "x30 y" y + 3 " w180", field ":")

                ; Add value (right column)
                MyGui.SetFont("s10", fontGUI)
                MyGui.Add("Text", "x220 y" y + 3 " w400", value)

                ; Add subtle separator
                MyGui.Add("Text", "x20 y" y + 20 " w600 c808080", "────────────────────────────────────────────────────────────────────────────")

                y += 35
            }
        }
        height := y + 20
    }

    ; Modern close button
    closeBtn := MyGui.Add("Text", "x615 y15 w20 h20 Center c808080", "×")
    closeBtn.SetFont("s16")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Window drag handler
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }

    ; Show GUI with minimum width/height
    height := Max(height, 160)
    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.Show("w600 h" height)
}

;* Tra cứu gói được CVTN (Chuyển vùng trong nước) và GHLH (Gia hạn linh hoạt)
^+g:: {
    data := LoadMobifoneData()
    eligibleCVTN := data.Get("eligibleCVTN")
    flexibleRenewalFee := data.Get("flexibleRenewalFee")

    packageName := GetSelectedText()
    if !RegExMatch(packageName, "^[a-zA-Z0-9]+$") {
        MsgBox Format("Gói cước '{1}' không hợp lệ", packageName)
        return
    }

    ; Check CVTN eligibility
    isCVTN := false
    for pkg in eligibleCVTN {
        if (pkg = packageName) {
            isCVTN := true
            break
        }
    }

    ; Check GHLH fee
    try {
        hasGHLH := flexibleRenewalFee.Get(packageName)
    }
    catch {
        hasGHLH := false
    }

    ; Show results
    guiTitle := "Kiểm tra CVTN và GHLH"
    MyGui := Gui(, guiTitle)
    MyGui.SetFont("s10")

    ; Add package name with larger font
    MyGui.SetFont("s12 bold")
    MyGui.Add("Text", "x10 y20", packageName)
    MyGui.Add("Text", "x10 y50", "────────────────────────────")

    ; Package info section
    MyGui.SetFont("s10 bold")

    ; CVTN status
    MyGui.Add("Text", "x10 y80", "Chuyển vùng trong nước:")
    MyGui.Add("Text", "x220 y80 " (isCVTN ? "cGreen" : "cRed"),
        isCVTN ? "✓ Được phép" : "✗ Không được phép")

    ; GHLH status
    MyGui.Add("Text", "x10 y120", "Gia hạn linh hoạt:")
    MyGui.Add("Text", "x220 y120 " (hasGHLH ? "cGreen" : "cRed"),
        hasGHLH ? Format("✓ {1}", hasGHLH) : "✗ Không hỗ trợ")
    MyGui.Add("Text", "x10 y135", " ")
    MyGui.OnEvent("Escape", MyGui_Escape)
    MyGui_Escape(thisGui) {
        WinClose guiTitle
    }
    MyGui.Show("")
}


;* Tra cứu lịch sử dịch vụ
^+l:: {
    serviceHistory := Map()
    serviceHistory.3GKK := "MobiGold hòa mạng mới (do Mobi365 chuyển sang) / Mobi365 chuyển sang MobiGold: có chuyển tiền"
    serviceHistory.CFKK := "MobiGold hòa mạng mới (do MobiCard chuyển sang) / Cắt MobiCard để chuyển sang MobiGold"
    serviceHistory.MCVU := "MobiGold số công vụ hòa mạng mới (số mới)"
    serviceHistory.MS := "MobiGold hòa mạng mới (số mới)"
    serviceHistory.QFON := "MobiGold hòa mạng mới (do MobiQ chuyển sang)"
    serviceHistory.QTEF := "MobiGold hòa mạng mới (do Q-Teen chuyển sang) / Q-Teen chuyển sang MobiGold"
    serviceHistory.SVFKK := "MobiGold hòa mạng mới (do Q-Student chuyển sang) / Q-Student chuyển sang MobiGold"
    serviceHistory.UFKK := "MobiGold hòa mạng mới (do Mobi4U chuyển sang) / Mobi4U chuyển sang MobiGold"
    serviceHistory.ZFKK := "MobiGold hòa mạng mới (do MobiZone chuyển sang) / MobiZone chuyển sang MobiGold: Còn tiền"
    serviceHistory.CHS := "Thay đổi thông tin do thông tin trước đó CH/ ĐLC cập nhật bị sai / Chặn 2 chiều do cửa hàng sau"
    serviceHistory.DTEN := "- Đổi tên cá nhân := cập nhật thêm tên cá nhân sau tên doanh nghiệp- Đổi tên doanh nghiệp := do doanh nghiệp đổi tên"
    serviceHistory.KHYC := "Thay đổi dịch vụ do KHYC / Thay sim / Thay đổi giữa các hình thức trả trước KH tự chuyển / Chặn 2 chiều do khách hàng yêu cầu"
    serviceHistory.NTNC := "Nhắn tin thông báo cước"
    serviceHistory.NTTB := "Nhắn tin nhắc cước hay nhắn nội dung khác"
    serviceHistory.WARN := "Nhắn tin nhắc cước hay nhắn tin báo đỏ"
    serviceHistory.PAID := "Mở 1 chiều do KH thanh toán cước"
    serviceHistory.XMD := "Mở 1 chiều do đã xác minh được địa chỉ thuê bao"
    serviceHistory.128K := "Đổi sim qua sim dung lượng 128K"
    serviceHistory.CA64 := "Đổi sim qua sim dung lượng 64K"
    serviceHistory.DSMP := "Đổi sim miễn phí"
    serviceHistory.CCQ := "Thuê bao được đấu mới do CCQ và chủ cũ đã thanh toán hết cước / Chặn 2 chiều do chuyển chủ quyền / Cắt hủy/ cắt hẳn MobiGold để chuyển chủ quyền và chủ cũ đã thanh toán hết cước"
    serviceHistory.CQC := "Thuê bao được đấu mới do chuyển chủ quyền và KH mới đồng ý thanh toán cước của chủ cũ"
    serviceHistory.ANNI := "Chặn 1 chiều / 2 chiều do yêu cầu từ Bộ Công An"
    serviceHistory.CA1 := "Chặn 2 chiều do mất máy / Chặn 1 chiều do mất máy"
    serviceHistory.CA4 := "Chặn 2 chiều do mất sim / Chặn 1 chiều do mất sim"
    serviceHistory.DEBT := "Chặn 1 chiều / Chặn 2 chiều do nợ cước"
    serviceHistory.KHD := "Chặn 1 chiều do không dùng/Chặn 2 chiều do KH yêu cầu tạm khóa"
    serviceHistory.KHDC := "Chặn 1 chiều / Chặn 2 chiều do địa chỉ không có thực, giả mạo hồ sơ"
    serviceHistory.KNAI := "Chặn 1 / 2 chiều do khách hàng khiếu nại"
    serviceHistory.KVMS := "Tạm khóa 2 chiều - VMS"
    serviceHistory.KXD := "Chặn 1 / 2 chiều do không xác minh được thông tin thuê bao"
    serviceHistory.QROI := "Chặn 1 / 2 chiều do thuê bao quấy rối"
    serviceHistory.THLY := "Chặn 2 chiều do khách hàng yêu cầu thanh lý hợp đồng"
    serviceHistory.XMB := "Chặn 1 / 2 chiều do khách hàng cung cấp sai địa chỉ"
    serviceHistory.BADO := "Chặn 1 chiều do TB sử dụng vượt quá mức cước ứng trước, báo đỏ"
    serviceHistory.HSO := "Chặn 1 chiều do không có hồ sơ"
    serviceHistory.OTH := "Chặn 1 chiều do các lý do khác"
    serviceHistory.CSKS := "Chặn 1 chiều do nghi ngờ sim kích hoạt sẵn"
    serviceHistory.3FON := "Mobi365 chuyển sang MobiGold: không còn tiền"
    serviceHistory.CA05 := "Cắt hủy/ cắt hẳn MobiGold trong vòng 5 ngày tính từ ngày hòa mạng (đã bỏ nghiệp vụ này)"
    serviceHistory.CA2 := "Cắt hủy/ cắt hẳn MobiGold do sóng yếu"
    serviceHistory.CA3 := "Cắt hủy/ cắt hẳn MobiGold do KH hủy số không sử dụng; Cắt hủy/ cắt hẳn trả trước do KH hủy số không sử dụng"
    serviceHistory.CCNV := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao nghiệp vụ"
    serviceHistory.CCVU := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao công vụ"
    serviceHistory.CMCV := "Chuyển máy công vụ"
    serviceHistory.CNV := "Cắt hủy/ cắt hẳn MobiGold nghiệp vụ"
    serviceHistory.CTHU := "Cắt hủy/ cắt hẳn MobiGold thuộc sim thử"
    serviceHistory.DEAC := "Chặn 2 chiều do hết hạn nghe / Thuê bao trả trước bị cắt hủy/ delete do bị khóa 2 chiều quá hạn (hiện nay là 31 ngày)"
    serviceHistory.DPFC := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang Fast Connect trả trước"
    serviceHistory.FONS := "Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang SFONE"
    serviceHistory.FONV := "Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang Viettel"
    serviceHistory.GOZO := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiZone"
    serviceHistory.HOSO := "Cắt hủy/ cắt hẳn MobiGold do không có hồ sơ"
    serviceHistory.KKH := "MobiGold chuyển sang MobiCard, không kích hoạt"
    serviceHistory.M365 := "Mobi365 chuyển sang MobiGold"
    serviceHistory.MEZ := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiEZ"
    serviceHistory.MF4U := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi4U"
    serviceHistory.MFQT := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Teen"
    serviceHistory.MFSV := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Student"
    serviceHistory.MGM3 := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi365"
    serviceHistory.MGMQ := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiQ"
    serviceHistory.MOBI := "Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiCard"
    serviceHistory.NO2T := "Cắt hủy/ cắt hẳn MobiGold do nợ cước quá"
    serviceHistory.QFKK := "Cắt MobiQ để chuyển sang MobiGold"
    serviceHistory.SAIS := "Cắt hủy/ cắt hẳn MobiGold do CH/ ĐLC đấu nối số sai qui định"
    serviceHistory.TK6T := "Cắt hủy/ cắt hẳn MobiGold do thuê bao khóa 2 chiều quá 6 tháng (hiện nay là quá 31 ngày)"
    serviceHistory.VINA := "Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang ViNaPhone"
    serviceHistory.DNTD := "Đấu số trả trước mới (số mới - đấu nối tự động)"
    serviceHistory.DNFC := "Đấu số MobiCard mới (do chuyển từ MobiGold sang)"
    serviceHistory.DNGQ := "Đấu số MobiQ mới (do chuyển từ MobiGold sang)"
    serviceHistory.GLZO := "MobiGold qua MobiZone"
    serviceHistory.FQTE := "Chuyển MobiGold sang Q_TEEN"
    serviceHistory.DNQT := "Chuyển MobiGold sang Mobi Qteen"
    serviceHistory.DNG3 := "Chuyển MobiGold sang Mobi365"
    serviceHistory.DNFU := "Chuyển MobiGold sang Mobi4U"
    serviceHistory.DNFSV := "Chuyển MobiGold sang MobiQ_SV"
    serviceHistory.DN2S := "Đấu nối Sim 2 số"
    serviceHistory.DNGD := "Đấu nối hay khôi phục theo giấy duyệt"
    serviceHistory.DOIS := "Đối soát"
    serviceHistory.HUY := "Đấu F1 sửa sai TDN"
    serviceHistory.KP := "Khôi phục số đã hủy"
    serviceHistory.VMS := "Đấu mới"
    serviceHistory.STH := "Sim Thu TT"
    serviceHistory.DNST := "Đấu nối sim thử"
    serviceHistory.DBO := "Thay đổi giữa các hình thức trả trước (do KH tự chuyển - bấm Note để xem chi tiết)"
    serviceHistory.QSV := "Chuyển từ trả trước khác sang Q-SV"
    serviceHistory.QTE := "Chuyển từ trả trước khác sang Q-Teen"
    serviceHistory.INAC := "Chặn 1 chiều do hết hạn sử dụng (Mobi4U là do hết tiền)"
    serviceHistory.ACTI := "Mở 2 chiều do nạp tiền / Kích hoạt số trả trước mới"
    serviceHistory.RES := "Chặn 1 chiều do hết tiền (nhưng còn ngày sử dụng)"
    serviceHistory.CA7 := "Hủy sim 2 số, thanh lý 1 số"
    serviceHistory.CKCVB := "Chặn không chính chủ vùng biên, DTV xác minh ghi nhận code 19.19. Không xác minh được thì mời đến CHC"
    serviceHistory.SVBG := "Spamcall-SVBG: ĐTV mời KH ra cửa hàng xác thực thông tin và làm cam kết để mở lại"

    serviceKey := GetSelectedText()
    MsgBox loopkup(serviceHistory, serviceKey)
}

;* Chuyen doi giay sang gio, phut
^+j:: {
    seconds := GetSelectedText()
    if !IsInteger(seconds) {
        MsgBox "Vui lòng chọn một số giây hợp lệ."
        return
    }

    hours := Floor(seconds / 3600)
    minutes := Floor(Mod(seconds, 3600) / 60)
    secs := Mod(seconds, 60)

    ; Create minimal GUI
    guiTitle := "Time Converter"
    MyGui := Gui("+AlwaysOnTop -Caption", guiTitle)
    MyGui.BackColor := "FFFFFF" ; White background

    ; Add shadow effect
    MyGui.SetFont("s12", "Segoe UI")

    ; Time display with large numbers
    MyGui.SetFont("s24 bold", "SF Pro Display")
    timeText := Format("{1:02d}:{2:02d}:{3:02d}", hours, minutes, secs)
    MyGui.Add("Text", "x20 y20 w240 Center", timeText)

    ; Labels underneath
    MyGui.SetFont("s10", "SF Pro Text")
    MyGui.Add("Text", "x20 y70 w80 Center", "Hours")
    MyGui.Add("Text", "x100 y70 w80 Center", "Minutes")
    MyGui.Add("Text", "x180 y70 w80 Center", "Seconds")

    ; Add close button in top-right
    MyGui.SetFont("s10", "Segoe UI")
    closeBtn := MyGui.Add("Text", "x255 y5 w20 h20 Center", "×")
    closeBtn.SetFont("s16 bold")
    closeBtn.OnEvent("Click", (*) => MyGui.Destroy())

    ; Rounded corners and padding
    MyGui.Show("w280 h100")

    ; Allow dragging window
    OnMessage(0x201, GuiDrag)
    GuiDrag(wParam, lParam, msg, hwnd) {
        static init := 0
        if (init = 0) {
            OnMessage(0x202, GuiDrag)
            init := 1
        }
        if (wParam = 1) {
            PostMessage(0xA1, 2)
        }
    }
    MyGui.OnEvent("Escape", (*) => WinClose(guiTitle))
    MyGui.Show()
    ; Auto-close after 3 seconds
    SetTimer () => MyGui.Destroy(), -3000
}

;* Chuyen doi KB sang MB, GB
^+k:: {
    kb := GetSelectedText()
    if !IsInteger(kb) {
        MsgBox "Vui lòng chọn một số KB hợp lệ."
        return
    }

    mb := Round(kb / 1024, 2)
    gb := Round(kb / 1024 / 1024, 2)

    ; Create GUI with a title
    guiTitle := "Size Converter"
    MyGui := Gui("+AlwaysOnTop", guiTitle)

    ; Add gradient background effect
    MyGui.BackColor := "F0F8FF" ; Light blue background

    ; KB Display (larger and bold)
    MyGui.SetFont("s14 bold", "Segoe UI")
    MyGui.Add("Text", "x10 y10 w200 cNavy", Format("Input: {1} KB", kb))

    ; Separator line
    MyGui.Add("Text", "x10 y35 w180 c0066CC", "──────────────────")

    ; Conversion results with colors
    MyGui.SetFont("s12", "Segoe UI")
    MyGui.Add("Text", "x10 y50 w200 c4169E1", Format("≈ {1} MB", mb))
    MyGui.Add("Text", "x10 y80 w200 c1E90FF", Format("≈ {1} GB", gb))

    ; Copy results to clipboard based on size
    if (mb >= 500) {
        A_Clipboard := Format("{1} MB, {2} GB", mb, gb)
    } else {
        A_Clipboard := Format("{1} MB", mb)
    }

    ; Show GUI
    MyGui.OnEvent("Escape", (*) => WinClose(guiTitle))
    MyGui.Show()

    ; Auto-close after 3 seconds
    SetTimer () => MyGui.Destroy(), -3000
}

; * Send key F1, F2, F3, F4 to the active window
F1:: Send "^1"
F2:: Send "^2"
F3:: Send "^3"
F4:: Send "^4"

; * Send key F5 to refresh the active window
F5:: {
    Send "^r"
    Sleep 150
    Send "{Enter}"
}