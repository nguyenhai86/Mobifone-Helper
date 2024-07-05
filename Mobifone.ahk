#requires AutoHotkey v2.0
#SingleInstance force
global fileBlacklist := "blacklist.csv"
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

;* Cộng 10 ngày theo Clipboard
^+1:: {
    days := 10
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    dateString := Trim(A_Clipboard)
    A_Clipboard := oldClipboard
    date := DateParse(dateString)
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }
    MsgBox(FormatDate(DateAdd_Custom(date, days)))
    return
}
;* Cộng 30 ngày theo Clipboard
^+3:: {
    days := 30
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    dateString := Trim(A_Clipboard)
    A_Clipboard := oldClipboard
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }
    A_Clipboard := oldClipboard
    MsgBox(FormatDate(DateAdd_Custom(date, days)))
    return
}
;* Cộng 60 ngày theo Clipboard
^+6:: {
    days := 60
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    dateString := Trim(A_Clipboard)
    A_Clipboard := oldClipboard
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }
    A_Clipboard := oldClipboard
    MsgBox(FormatDate(DateAdd_Custom(date, days)))
    return
}
;* Thông tin gia hạn linh hoạt
^+q:: {
    ;Lấy giá hạn linh hoạt lần đầu tiên
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    newClipboard := Trim(newClipboard)
    ;tien xu ly gia tri
    stringMoney := newClipboard
    if InStr(newClipboard, ".") {
        arr := StrSplit(newClipboard, ".")
        stringMoney := Format("{1}{2}", arr[1], arr[2])
    }
    if InStr(newClipboard, ",") {
        arr := StrSplit(newClipboard, ",")
        stringMoney := Format("{1}{2}", arr[1], arr[2])
    }

    result := "Không hợp lệ"
    IB := InputBox("Nhập giá gói cước", "Gia han linh hoat", "w150 h100")
    editValue := Trim(IB.Value)
    if IB.Result != "Cancel" {
        if editValue = "pt120" || editValue = "PT120" || editValue = "pT120" || editValue = "Pt120" {
            price := 120000
            priceOnDay := 4000
            chiaLayNguyen := Floor(stringMoney / priceOnDay)
            soTienChinh := chiaLayNguyen * priceOnDay
            stringPT120 := Format("Gói PT120 - Tổng giá gói: {1}đ`n`nGia hạn lần đầu: {2}đ cho {3} ngày`n`nGia hạn lần sau: {4}đ cho {5} ngày", 120000, stringMoney, chiaLayNguyen, 120000 - stringMoney, 30 - chiaLayNguyen)
            result := stringPT120
        }
        else {
            priceOnDay := editValue / 30
            firstDay := stringMoney / priceOnDay
            secondDay := 30 - firstDay
            secondMoney := editValue - stringMoney
            result := Format("Tổng giá gói: {1}đ`n`nGia hạn lần đầu: {2}đ cho {3:0} ngày`n`nGia hạn lần sau: {4}đ cho {5:0} ngày", editValue, stringMoney, firstDay, secondMoney, secondDay)
        }
        MsgBox result
    }

    A_Clipboard := oldClipboard
    return
}
;* Date Calculator
^+e:: {
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    dateString := Trim(A_Clipboard)
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

    A_Clipboard := oldClipboard
    MyGui.OnEvent("Escape", MyGui_Escape)
    MyGui_Escape(thisGui) {
        WinClose titleGUI
    }
    MyGui.Show()
}
^+g:: {
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    filePath := Format("{1}\{2}", A_ScriptDir, "Package")
    Run filePath
    Sleep 1000
    A_Clipboard := oldClipboard
}
^Escape:: {
    if WinActive("ahk_class Package") || WinActive("ahk_class" "WindowsForms10.Window.8.app.0.1ca0192_r10_ad1")
        WinClose
}
;* Đếm số cuộc gọi
global countCall := 0
^PgDn:: {
    global countCall
    countCall := 0
    MsgBox Format("Số lượng CG được reset về {1}", countCall)
}
+PgDn:: {
    global countCall
    MsgBox Format("So luong cuoc goi: {1}", countCall)
}
PgDn:: {
    global countCall
    countCall := countCall + 1
    Sleep 200
    Send "{Down}"
}

;* Tra cuu cac profile dang ky goi DT20
^+y:: {
    profiles := ["QT2", "TT2", "YT2", "RZT2", "SVT2", "TNT2", "WT2", "KT2", "TBT2", "Q263", "QTN1", "QTN2", "HAT2", "MCP", "SBK", "BKS", "ZMT", "DHMT", "ZHN", "W2G"]
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 200
    profileClipboard := Trim(A_Clipboard)
    A_Clipboard := oldClipboard
    status := 0
    for index, profile in profiles {
        if profile = profileClipboard {
            MsgBox Format("Profile hien tai la {1} co the dang ky goi DT20", profile)
            status := 1
            break
        }
    }
    if status = 0 {
        MsgBox Format("Profile hien tai la {1} khong dang ky duoc DT20", profileClipboard)
    }
}

;* Tra cuu so dien thoai tong dai
^+s:: {
    ; Define the phone prefixes and corresponding customer service numbers
    Viettel := ["86", "96", "97", "98", "32", "33", "34", "35", "36", "37", "38", "39"]
    Mobifone := ["89", "90", "93", "70", "76", "77", "78", "79"]
    Vinaphone := ["88", "91", "94", "83", "84", "85", "81", "82"]
    GtelMobile := ["99", "59"]
    VietNamMobile := ["92", "52", "56", "58"]
    Itelecom := ["87"]

    tongDai := { Viettel: "18008098 - Cuoc goi mien phi", Mobifone: "18001090 - Cuoc goi mien phi", Vinaphone: "18001091 - Cuoc goi mien phi", GtelMobile: "0993 888 198 - Cuoc goi thong thuong", VietNamMobile: "789 - Mien phi / 0922789789 - Cuoc goi thong thuong", Itelecom: "0877 087 087 - Cuoc goi thong thuong" }

    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    phoneNumber := Trim(newClipboard)
    A_Clipboard := oldClipboard

    status := 0
    prefix := "0"
    If SubStr(phoneNumber, 1, 1) = "0"
        prefix := SubStr(phoneNumber, 2, 3)
    else
        prefix := SubStr(phoneNumber, 1, 2)
    result := ""
    ; Viettel
    if status = 0 {
        for index, value in Viettel {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "Viettel", tongDai.Viettel)
                status := 1
                break
            }
        }
    }

    ; Mobifone
    if status = 0 {
        for index, value in Mobifone {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "Mobifone", tongDai.Mobifone)
                status := 1
                break
            }
        }
    }

    ; Vinaphone
    if status = 0 {
        for index, value in Vinaphone {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "Vinaphone", tongDai.Vinaphone)
                status := 1
                break
            }
        }
    }
    ; GtelMobile
    if status = 0 {
        for index, value in GtelMobile {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "GtelMobile", tongDai.GtelMobile)
                status := 1
                break
            }
        }
    }

    ; VietNamMobile
    if status = 0 {
        for index, value in VietNamMobile {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "VietNamMobile", tongDai.VietNamMobile)
                status := 1
                break
            }
        }
    }

    ; Itelecom
    if status = 0 {
        for index, value in Itelecom {
            if (prefix = value) {
                result := Format("So dien thoai {1} - {2} `n`nTong dai: {3}", phoneNumber, "Itelecom", tongDai.Itelecom)
                status := 1
                break
            }
        }
    }
    if status = 0 {
        result := Format("Khong tim thay nha mang cho so dien thoai: {1}", phoneNumber)
    }
    MsgBox result
}

MButton:: {
    Send "{``}"
}

;* Tu dong lay SDT
`:: {
    countCall := countCall + 1
    ; Tìm cửa sổ có tiêu đề "Call Information"
    CallInfoTitle := "Call Information"
    winInfoCall := WinExist(CallInfoTitle)
    if winInfoCall
    {
        ; Đưa cửa sổ lên trước
        WinActivate(winInfoCall)
        Sleep 200
        ; Gửi phím Enter
        Send "{Enter}"
        Sleep 200
        phoneNumber := A_Clipboard

        VMSTitle := "Customer Care of VMS"
        winVMS := WinExist(VMSTitle)
        if winVMS
        {
            ; Đưa cửa sổ lên trước
            WinActivate(winVMS)
            Sleep 400

            Send "!d"
            Sleep 200
            Send "https://tracuu.mobifone.vn/1090/mobicard.jsp"
            Sleep 500
            Send "{Enter}"
            Sleep 1500

            Send phoneNumber
            Sleep 300
            Send "{Enter}"

            try {
                message := checkPhoneNumber(phoneNumber, fileBlacklist)
                if message {
                    MsgBox message
                }
            } catch Error as e {
            }
        }
    }
}
^+d:: {
    tiLeDaiLy := 0.159
    tiLeThucNhan := 0.127
    IB := InputBox("Nhập giá gói cước", "Tinh hoa hong", "w150 h100")
    editValue := Trim(IB.Value)

    If editValue {
        MsgBox Format("Hoa hong dai ly: {1}`n`nHoa hong thuc nhan: {2}", Round(editValue * tiLeDaiLy), Round(editValue * tiLeThucNhan))
    }
}
;* Tong dai ung tien
^+u:: {
    codes := Map(
        "9015", Map("Time", "chờ 24h", "Tài khoản", "TKC", "Kiểm tra nợ", "KT", "DK ứng tự động", "UDT/SUBS", "Hủy ứng tự động", "TCUTD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "HU"),
        "9913", Map("Time", "", "Tài khoản", "TK_AP1: - Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "DK ứng tự động", "TD", "Hủy ứng tự động", "HUY TD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UACHU"),
        "9928", Map("Time", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "TT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "MBHU"),
        "988", Map("Time", "", "Tài khoản", "KM3: Thoại/SMS nội mạng, liên mạng / DT20", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "MBFHU"),
        "9070", Map("Time", "24h", "Tài khoản", "Data", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "TT", "Mã hoàn ứng", "DT247HU"),
        "1256", Map("Time", "7 ngày", "Tài khoản", "Data", "Kiểm tra nợ", "KT", "DK ứng tự động", "UDT", "Hủy ứng tự động", "HUY", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "EHU"),
        "1255", Map("Time", "", "Tài khoản", "TK_AP2: Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UAGHU"),
        "5110", Map("Time", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "SPHU")
    )
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    value := Trim(newClipboard)
    A_Clipboard := oldClipboard
    MsgBox GetInfoByCodeOrCompletionCode(codes, value)
}

^+l:: {
    dataLS := {}
    dataLS.DNFC := "Đấu số MobiCard mới (do chuyển từ MobiGold sang)"
    dataLS.DNGQ := "Đấu số MobiQ mới (do chuyển từ MobiGold sang)"
    dataLS.GLZO := "MobiGold qua MobiZone"
    dataLS.FQTE := "Chuyển MobiGold sang Q_TEEN"
    dataLS.DPFC := "Chuyển MobiGold sang FastConnect trả trước"
    dataLS.DNQT := "Chuyển MobiGold sang Mobi Qteen"
    dataLS.DNG3 := "Chuyển MobiGold sang Mobi365"
    dataLS.DNFU := "Chuyển MobiGold sang Mobi4U"
    dataLS.DNFSV := "Chuyển MobiGold sang MobiQ_SV"
    dataLS.DN2S := "Đấu nối Sim 2 số"
    dataLS.DNGD := "Đấu nối hay khôi phục theo giấy duyệt"
    dataLS.DOIS := "Đối soát"
    dataLS.HUY := "Đấu F1 sửa sai TDN"
    dataLS.KP := "Khôi phục số đã hủy"
    dataLS.VMS := "Đấu mới"
    dataLS.STH := "Sim Thu TT"
    dataLS.DNST := "Đấu nối sim thử"
    dataLS.CHS := "Đấu F1 sửa sai cửa hàng (test)"
    dataLS.DBO := "Thay đổi giữa các hình thức trả trước (do KH tự chuyển - bấm Note để xem chi tiết)"
    dataLS.KHYC := "Thay đổi giữa các hình thức trả trước (do KH tự chuyển - bấm Note để xem chi tiết)"
    dataLS.QSV := "Chuyển từ trả trước khác sang Q-SV"
    dataLS.QTE := "Chuyển từ trả trước khác sang Q-Teen"
    dataLS.INAC := "Chặn 1 chiều do hết hạn sử dụng (Mobi4U là do hết tiền)"
    dataLS.CSKS := "Chặn 1 chiều do nghi ngờ sim kích hoạt sẵn"
    dataLS.DEAC := "Chặn 2 chiều do hết hạn nghe"
    dataLS.ACTI := "Mở 2 chiều do nạp tiền"
    dataLS.RES := "Chặn 1 chiều do hết tiền (nhưng còn ngày sử dụng)"
    dataLS.CA3 := "Cắt hủy/ cắt hẳn trả trước do KH hủy số không sử dụng"
    dataLS.CA7 := "Hủy sim 2 số, thanh lý 1 số"
    dataLS.ACTI := "Kích hoạt số trả trước mới"
    dataLS.GKK := "MobiGold hòa mạng mới (do Mobi365 chuyển sang)"
    dataLS.CFKK := "MobiGold hòa mạng mới (do MobiCard chuyển sang)"
    dataLS.MCVU := "MobiGold số công vụ hòa mạng mới (số mới)"
    dataLS.MS := "MobiGold hòa mạng mới (số mới)"
    dataLS.QFON := "MobiGold hòa mạng mới (do MobiQ chuyển sang)"
    dataLS.QTEF := "MobiGold hòa mạng mới (do Q-Teen chuyển sang)"
    dataLS.SVFKK := "MobiGold hòa mạng mới (do Q-Student chuyển sang)"
    dataLS.UFKK := "MobiGold hòa mạng mới (do Mobi4U chuyển sang)"
    dataLS.ZFKK := "MobiGold hòa mạng mới (do MobiZone chuyển sang)"
    dataLS.CCX := "Sim tạm khóa 2 chiều do không có TT"
    dataLS.DKKH := "Chặn/ hủy số Mobi4U không kích hoạt (khóa số sau 30 ngày)"
    dataLS.HNAC := "Sim khóa do hết hạn sử dụng"
    dataLS.HQUY := "Hủy số chưa hòa mạng (khóa sau 30 ngày)"
    dataLS.HSIM := "Sim tạm khóa 2 chiều do hủy số"
    dataLS.MFQT := "Chuyển từ trả trước khác sang Q-Teen"
    dataLS.TK6T := "Khóa số 2 chiều sau 6 tháng (31 ngày)"
    dataLS.VINA := "Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang Vinaphone"
    dataLS.ZFKK := "MobiZone chuyển sang MobiGold: Còn tiền"
    dataLS.CCXN := "Chặn do nghi ngờ sim kích hoạt sẵn"
    dataLS.CĐSS := "Chặn do nghi ngờ sim kích hoạt sẵn"
    dataLS.KDID := "Chặn do nghi ngờ sim kích hoạt sẵn"

    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    key := Trim(newClipboard)
    A_Clipboard := oldClipboard
    MsgBox loopkup(dataLS, key)
}

;* Sendkey
F1:: {
    ProcessAutomation(1)
}
F2:: {
    ProcessAutomation(2)
}
F3:: {
    ProcessAutomation(3)
}

F5:: {
    Send "^r"
    Sleep 100
    Send "{Enter}"
}

ConvertSecondToTime(second) {
    hours := Floor(second / 3600)
    minutes := Floor((second - (hours * 3600)) / 60)
    return Format("{1} giờ {2} phút", hours, minutes)
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

checkPhoneNumber(phoneNumber, filename) {
    filePath := Format("{1}\{2}", A_ScriptDir, filename)
    ; Read the file contents
    fileContents := FileRead(filePath)
    ; Split the file contents into lines
    lines := StrSplit(fileContents, "`n")

    ; Iterate over each line
    for line in lines
    {
        ; Split the line into columns
        columns := StrSplit(line, ",")
        ; Check if the phone number matches the first column
        if (columns[1] = phoneNumber)
        {
            ; Display the note from the second column
            return columns[2]
        }
    }

}


DisplayInfo(key, info) {
    infoStr := "Code: " key "`n"
    for k, v in info {
        infoStr .= k ": " v "`n"
    }
    return infoStr
}
GetInfoByCodeOrCompletionCode(codes, value) {
    if (codes.Has(value))
        return DisplayInfo(value, codes[value])


    for key, info in codes {
        if (info.Has("Mã hoàn ứng") && (info["Mã hoàn ứng"] = value))
            return DisplayInfo(key, info)

    }
}

loopkup(dataLS, key) {
    if dataLS.HasOwnProp(key) = 1 {
        return dataLS.GetOwnPropDesc(key).Value
    }
    else {
        return "Key not found"
    }
}

ProcessAutomation(action) {
    ; Ô dropdown hành động - chọn dang ky
    Send "{Tab}"
    Sleep 1000
    if (action = 1)
        Send "71"
    else if (action = 2) {
        Send "7"
        Sleep 500
        Send "{Down}"
    }
    else if (action = 3) {
        Send "Mong"
    }
    Sleep 500
    Send "{Enter}"
    Sleep 300
    Send "{Tab}"
    Sleep 500
    ; Ô chọn cảm xúc KH
    Send "Hài lòng"
    Sleep 500
    Send "{Enter}"
    Sleep 500
    Send "{Tab}"
    Sleep 500
    ; Ô mô tả nguyên nhân phía KH
    Send "KHYC"
    Sleep 500
    Send "{Tab}"
    Sleep 500
    ; Ô mô tả cảm xúc phía KH
    Send "OK"
    Sleep 500
    Send "{Tab}"
    ; Ô mô tả cảm xúc phía KH
    Sleep 500
    If action = 1 || action = 2
        Send "Yeu cau ve dich vu Mobile Internet cua Quy khach da duoc xu ly. Chi tiet lien he 9090, MobiFone han hanh duoc phuc vu."
    else If action = 3
        Send "Yeu cau ve dich vu  cua Quy khach da duoc xu ly. Chi tiet lien he 9090, MobiFone han hanh duoc phuc vu."
    Sleep 2000
    Send "{Tab}"
    Sleep 500
    ; Chọn ô nhập
    Send "{Enter}"
}