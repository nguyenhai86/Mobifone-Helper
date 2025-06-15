#requires AutoHotkey v2.0
#SingleInstance force

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
    titleGUI := "Date Calculator"
    MyGui := Gui(, titleGUI)
    stringLine := "-------------------------------------------------------------------------"
    MyGui.Add("Text", "x10 y20 cRed", "Ngày hiện tại")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y60 cBlue", "+ 04 ngày:")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y100 cBlue", "+ 10 ngày:")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y140 cBlue", "+ 14 ngày:")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y180 cBlue", "+ 30 ngày:")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y220 cBlue", "+ 45 ngày:")
    MyGui.Add("Text", "xm", stringLine)
    MyGui.Add("Text", "x10 y260 cBlue", "+ 60 ngày:")
    MyGui.Add("Text", "x10 y270 cBlue", "")

    MyGui.Add("Text", "x120 y20 cRed", "Ngày tính")
    MyGui.Add("Text", "x120 y60", FormatDate(DateAdd_Custom(date, 4)))
    MyGui.Add("Text", "x120 y100", FormatDate(DateAdd_Custom(date, 10)))
    MyGui.Add("Text", "x120 y140", FormatDate(DateAdd_Custom(date, 14)))
    MyGui.Add("Text", "x120 y180", FormatDate(DateAdd_Custom(date, 30)))
    MyGui.Add("Text", "x120 y220", FormatDate(DateAdd_Custom(date, 45)))
    MyGui.Add("Text", "x120 y260", FormatDate(DateAdd_Custom(date, 60)))

    MyGui.OnEvent("Escape", MyGui_Escape)
    MyGui_Escape(thisGui) {
        WinClose titleGUI
    }
    MyGui.Show()
}
^+e:: {
    dateString := GetSelectedText()
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }
    titleGUI := "Date Calculator"
    MyGui := Gui(, titleGUI)
    i := 0
    stringLine := "-------------------------------------------------------------------------"
    loop 18 {
        if i = 0 {
            MyGui.Add("Text", "x10 y20 cRed", "Chu kỳ")
            MyGui.Add("Text", "x70 y20 cRed", "30 Ngày")
            MyGui.Add("Text", "x160 y20 cRed", "31 Ngày")
            MyGui.Add("Text", "xm", stringLine)
        }
        else {
            If i = 17
                MyGui.Add("Text", "xm", "Hết hạn")
            else
                MyGui.Add("Text", "x10", i)

            lastDate30 := DateAdd_Custom(date, 30 * (i - 1))
            lastDate31 := DateAdd_Custom(date, 31 * (i - 1))
            if DateDiff__Custom(lastDate30) > 0
                MyGui.Add("Text", "x70 yp cBlue	", FormatDate(lastDate30))
            else
                MyGui.Add("Text", "x70 yp", FormatDate(lastDate30))

            if DateDiff__Custom(lastDate31) > 0
                MyGui.Add("Text", "x160 yp cBlue", FormatDate(lastDate31))
            else
                MyGui.Add("Text", "x160 yp", FormatDate(lastDate31))
            MyGui.Add("Text", "xm", stringLine)
        }
        i := i + 1
    }

    MyGui.OnEvent("Escape", MyGui_Escape)
    MyGui_Escape(thisGui) {
        WinClose titleGUI
    }
    MyGui.Show()
}

;* Tra cứu các profile đăng ký gói DT20
^+y:: {
    profiles := Map()
    for _, v in ["QT2", "TT2", "YT2", "RZT2", "SVT2", "TNT2", "WT2", "KT2", "TBT2", "Q263", "QTN1", "QTN2", "HAT2", "MCP", "SBK", "BKS", "ZMT", "DHMT", "ZHN", "W2G"]
        profiles[v] := true
    profile := Trim(GetSelectedText())
    canRegister := profiles.Has(profile)

    title := "Check DT20"
    gui := Gui(, title)
    line := "-------------------------------------------------------------------------"
    gui.Add("Text", "x10 y20 cBlack", Format("Profile hiện tại: {1}", profile))
    gui.Add("Text", "x130 y20 " (canRegister ? "cBlue" : "cRed"), canRegister ? "Có thể đăng ký gói DT20" : "Không thể đăng ký gói DT20")
    gui.Add("Text", "xm", line)
    gui.OnEvent("Escape", (*) => WinClose(title))
    gui.Show()
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
    result := ""

    for name, arr in prefixes {
        for _, pfx in arr {
            if (prefix = pfx) {
                carrier := name
                break 2
            }
        }
    }

    if carrier {
        result := Format("Số điện thoại {1} - {2}`n`nTổng đài: {3}", phone, carrier, hotline[carrier])
    } else {
        result := Format("Không tìm thấy nhà mạng cho số điện thoại: {1}", phone)
    }
    MsgBox result
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
    if (loanCodes.Has(inputValue))
        return FormatLoanInfo(inputValue, loanCodes[inputValue])

    for code, info in loanCodes {
        if (info.Has("Mã hoàn ứng") && (info["Mã hoàn ứng"] = inputValue))
            return FormatLoanInfo(code, info)
    }
    return "Không tìm thấy thông tin cho: " inputValue
}
FormatLoanInfo(code, info) {
    infoText := "Mã dịch vụ: " code "`n"
    for field, value in info {
        infoText .= field ": " value "`n"
    }
    return infoText
}
^+u:: {
    loanCodes := Map(
        "9015", Map("Thời gian", "chờ 24h", "Tài khoản", "TKC", "Kiểm tra nợ", "KT", "ĐK ứng tự động", "UDT/SUBS", "Hủy ứng tự động", "HUY UTD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "HU"),
        "9913", Map("Thời gian", "", "Tài khoản", "TK_AP1: - Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "ĐK ứng tự động", "TD", "Hủy ứng tự động", "HUY TD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UACHU"),
        "9928", Map("Thời gian", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "TT", "ĐK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "MBHU"),
        "9363", Map("Thời gian", "", "Tài khoản", "KM3: Thoại/SMS nội mạng, liên mạng / DT20", "Kiểm tra nợ", "KT", "ĐK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "MBFHU"),
        "9070", Map("Thời gian", "24h", "Tài khoản", "Data", "Kiểm tra nợ", "KT", "ĐK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "TT", "Mã hoàn ứng", "DT247HU"),
        "1256", Map("Thời gian", "7 ngày", "Tài khoản", "TKC", "Kiểm tra nợ", "KT", "ĐK ứng tự động", "UDT", "Hủy ứng tự động", "HUY", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "EHU"),
        "1255", Map("Thời gian", "", "Tài khoản", "TK_AP2: Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "ĐK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UAGHU"),
        "5110", Map("Thời gian", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "KT", "ĐK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "SPHU")
    )
    inputValue := GetSelectedText()
    MsgBox ShowLoanInfoByCodeOrCompletionCode(loanCodes, inputValue)
}

;* Tra cứu gói được CVTN (Chuyển vùng trong nước) và GHLH (Gia hạn linh hoạt)
^+g:: {
    eligibleCVTN := [
        "3MXH90", "6MXH90", "12MXH90", "3MXH100", "6MXH100", "12MXH100", "3MXH120", "6MXH120", "12MXH120", "3MXH150", "6MXH150", "12MXH150", "3MF159", "6MF159", "12MF159", "3KC120", "6KC120", "12KC120", "3KC150", "6KC150", "12KC150", "3NA70", "6NA70", "12NA70", "3NA90", "6NA90", "12NA90", "3NA120", "6NA120", "12NA120", "3S135", "6S135", "12S135", "3S159", "6S159", "12S159", "3MW90", "6MW90", "12MW90", "3MWG110", "6MWG110", "12MWG110", "3MWG125", "6MWG125", "12MWG125", "3MWG135", "6MWG135", "12MWG135", "3MWG155", "6MWG155", "12MWG155", "3MGX90", "6MGX90", "12MGX90", "3MGX110", "6MGX110", "12MGX110", "3MGX125", "6MGX125", "12MGX125", "3MAX90", "6MAX90", "12MAX90", "3V90", "6V90", "12V90", "3GX159", "6GX159", "12GX159", "3GX139", "6GX139", "12GX139", "MXH90", "MXH100", "MXH120", "MXH150", "MF159", "KC120", "KC150", "NA70", "NA90", "NA120", "S135", "S159", "MW90", "MWG110", "MWG125", "MWG135", "MWG155", "MGX90", "MGX110", "MGX125", "MAX90", "V90", "GX159", "GX139", "C120K", "12C120K", "MF219", "MF329", "3MF219", "6MF219", "12MF219", "3MF329", "6MF329", "12MF329", "3E300", "6E300", "12E300", "5GV", "5GC", "5GLQ", "3E500", "6E1000", "12E1000", "VZ100", "12VZ100", "VZ135", "12VZ135", "C90N", "3C90N", "6C90N", "12C90N", "3TK135", "6TK135", "12TK135", "TK135", "KC90", "3KC90", "6KC90", "12KC90", "3TK159", "6TK159", "12TK159", "TK159", "3PT90", "6PT90", "12PT90", "PT90"
    ]

    flexibleRenewalFee := Map()
    flexibleRenewalFee.KC90 := "12.000 đ"
    flexibleRenewalFee.TK135 := "4.500 đ"
    flexibleRenewalFee.C120 := "20.000 đ"
    flexibleRenewalFee.C90 := "12.000 đ"
    flexibleRenewalFee.C90N := "12.000 đ"
    flexibleRenewalFee.KC120 := "16.000 đ"
    flexibleRenewalFee.KC150 := "25.000 đ"
    flexibleRenewalFee.PT120 := "10.000 đ"
    flexibleRenewalFee.PT70 := "2.500 đ"
    flexibleRenewalFee.PT90 := "3.000 đ"
    flexibleRenewalFee.C120N := "16.000 đ"
    flexibleRenewalFee.C120K := "28.000 đ"
    flexibleRenewalFee.C120T := "28.000 đ"
    flexibleRenewalFee.TK159 := "21.200 đ"
    flexibleRenewalFee.TK219 := "29.200 đ"
    flexibleRenewalFee.MXH80 := "6.000 đ"
    flexibleRenewalFee.MXH90 := "6.000 đ"
    flexibleRenewalFee.MXH100 := "7.000 đ"
    flexibleRenewalFee.MXH120 := "20.000 đ"
    flexibleRenewalFee.MXH150 := "30.000 đ"
    flexibleRenewalFee.C50N := "40.000 đ"
    flexibleRenewalFee.FD60 := "2.000 đ"
    flexibleRenewalFee.21G := "4.000 đ"
    flexibleRenewalFee.24G := "6.600 đ"
    flexibleRenewalFee.12C120 := "120.000 đ"
    flexibleRenewalFee.12C90N := "90.000 đ"
    flexibleRenewalFee.12C50N := "50.000 đ"
    flexibleRenewalFee.12KC150 := "150.000 đ"
    flexibleRenewalFee.12KC120 := "120.000 đ"
    flexibleRenewalFee.12KC90 := "90.000 đ"
    flexibleRenewalFee.12PT120 := "120.000 đ"
    flexibleRenewalFee.12PT90 := "90.000 đ"
    flexibleRenewalFee.12PT70 := "70.000 đ"
    flexibleRenewalFee.12MXH150 := "150.000 đ"
    flexibleRenewalFee.12MXH120 := "120.000 đ"
    flexibleRenewalFee.12MXH100 := "100.000 đ"
    flexibleRenewalFee.12MXH90 := "90.000 đ"
    flexibleRenewalFee.12MXH80 := "80.000 đ"
    flexibleRenewalFee.12TK219 := "219.000 đ"
    flexibleRenewalFee.12TK159 := "159.000 đ"
    flexibleRenewalFee.12TK135 := "135.000 đ"
    flexibleRenewalFee.NA70 := "7.000 đ"
    flexibleRenewalFee.NA90 := "6.000 đ"
    flexibleRenewalFee.NA120 := "6.000 đ"
    flexibleRenewalFee.MBF30 := "10.000 đ"
    flexibleRenewalFee.EDU100 := "10.000 đ"
    flexibleRenewalFee.ME100 := "10.000 đ"
    flexibleRenewalFee.AG90 := "5.000 đ"
    flexibleRenewalFee.AG100 := "10.000 đ"
    flexibleRenewalFee.GG135 := "5.000 đ"
    flexibleRenewalFee.GG155 := "35.000 đ"
    flexibleRenewalFee.MCL200 := "5.000 đ"
    flexibleRenewalFee.MCD85 := "5.000 đ"
    flexibleRenewalFee.MCD100 := "10.000 đ"
    flexibleRenewalFee.S135 := "5.000 đ"
    flexibleRenewalFee.S159 := "10.000 đ"
    flexibleRenewalFee.MCD145 := "5.000 đ"
    flexibleRenewalFee.MC150 := "10.000 đ"
    flexibleRenewalFee.MFC165 := "5.000 đ"

    packageName := GetSelectedText()
    if !RegExMatch(packageName, "^[a-zA-Z0-9]+$") {
        MsgBox Format("Gói cước '{1}' không hợp lệ", packageName)
        return
    }

    isCVTN := false
    for _, pkg in eligibleCVTN {
        if (pkg = packageName) {
            isCVTN := true
            break
        }
    }
    renewalFee := loopkup(flexibleRenewalFee, packageName)

    guiTitle := "Kiểm tra CVTN và GHLH"
    guiLine := "-------------------------------------------------------------------------"
    gui := Gui(, guiTitle)
    gui.Add("Text", "x10 y20 cRed", Format("Gói cước hiện tại: '{1}'", packageName))
    gui.Add("Text", "xm", guiLine)
    gui.Add("Text", "x10 y60 cBlue", "CVTN:")
    gui.Add("Text", "xm", guiLine)
    gui.Add("Text", "x10 y100 cBlue", "GHLH:")
    gui.Add("Text", "x10 y120 cBlue", "")

    gui.Add("Text", "x100 y60 cBlack", isCVTN ? "TRUE" : "FALSE")
    gui.Add("Text", "x100 y100 cBlack", renewalFee != "Key not found" ? renewalFee : "Không hỗ trợ")

    gui.OnEvent("Escape", (*) => WinClose(guiTitle))
    gui.Show()
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
    MsgBox Format("{1} Giờ {2} Phút {3} Giây", hours, minutes, secs)
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
    result := Format("{1} MB, {2} GB", mb, gb)
    A_Clipboard := result
    MsgBox Format("Kích thước {1} KB tương đương với {2}", kb, result)
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