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
;* Cộng 45 ngày theo Clipboard
^+4:: {
    days := 45
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
    editValue := StrLower(Trim(IB.Value))
    if IB.Result != "Cancel" {
        if editValue = "pt120"
        {
            price := 120000
            priceOnDay := 4000
            chiaLayNguyen := Floor(stringMoney / priceOnDay)
            soTienChinh := chiaLayNguyen * priceOnDay
            stringPT120 := Format("Gói PT120 - Tổng giá gói: {1}đ`n`nGia hạn lần đầu: {2}đ cho {3} ngày`n`nGia hạn lần sau: {4}đ cho {5} ngày`n`nGHLH Min: 10000đ", 120000, stringMoney, chiaLayNguyen, 120000 - stringMoney, 30 - chiaLayNguyen)
            result := stringPT120
        }
        else if editValue = "kc90"
            result := "GHLH KC90: 12.000đ"
        else if editValue = "tk135"
            result := "GHLH TK135: 4.500đ"
        else if editValue = "c120"
            result := "GHLH C120: 20.000đ"
        else if editValue = "c90"
            result := "GHLH C90: 12.000đ"
        else if editValue = "kc120"
            result := "GHLH KC120: 16.000đ"
        else if editValue = "kc150"
            result := "GHLH KC150: 25.000đ"
        else if editValue = "pt70"
            result := "GHLH PT70: 2.500đ"
        else if editValue = "pt90"
            result := "GHLH PT90: 3000đ"
        else if editValue = "c120n"
            result := "GHLH C120N: 16.000đ"
        else if editValue = "c120k"
            result := "GHLH C120K: 28.000đ"
        else if editValue = "c120t"
            result := "GHLH C120T: 28.000đ"
        else if editValue = "tk159"
            result := "GHLH TK159: 21.200đ"
        else if editValue = "mxh80"
            result := "GHLH MXH80: 6.000đ"
        else if editValue = "mxh90"
            result := "GHLH MXH90: 6.000đ"
        else if editValue = "mxh100"
            result := "GHLH MXH100: 7.000đ"
        else if editValue = "mxh120"
            result := "GHLH MXH120: 20.000đ"
        else if editValue = "mxh150"
            result := "GHLH MXH150: 30.000đ"
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
    packageName := "Package"
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 100

    if WinExist(packageName)
        WinClose packageName
    Sleep 100
    ; run Package
    filePath := Format("{1}\{2}", A_ScriptDir, packageName)
    Run filePath
    if WinWaitActive(packageName, , 3) {
        A_Clipboard := oldClipboard
    }
}
^Escape:: {
    if WinActive("ahk_class Package") || WinActive("ahk_class" "WindowsForms10.Window.8.app.0.1ca0192_r10_ad1")
        WinClose
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

    tongDai := { Viettel: "18008098 - Cuoc goi mien phi", Mobifone: "18001090 - Cuoc goi mien phi", Vinaphone: "18001091 - Cuoc goi mien phi", GtelMobile: "0993 196 196 - Cuoc goi thong thuong", VietNamMobile: "789 - Mien phi / 0922789789 - Cuoc goi thong thuong", Itelecom: "0877 087 087 - Cuoc goi thong thuong" }

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
    dataLS.3GKK := 'MobiGold hòa mạng mới (do Mobi365 chuyển sang) / Mobi365 chuyển sang MobiGold: có chuyển tiền' ;
    dataLS.CFKK := 'MobiGold hòa mạng mới (do MobiCard chuyển sang) / Cắt MobiCard để chuyển sang MobiGold' ;
    dataLS.MCVU := 'MobiGold số công vụ hòa mạng mới (số mới)' ;
    dataLS.MS := 'MobiGold hòa mạng mới (số mới)' ;
    dataLS.QFON := 'MobiGold hòa mạng mới (do MobiQ chuyển sang)' ;
    dataLS.QTEF := 'MobiGold hòa mạng mới (do Q-Teen chuyển sang) / Q-Teen chuyển sang MobiGold' ;
    dataLS.SVFKK := 'MobiGold hòa mạng mới (do Q-Student chuyển sang) / Q-Student chuyển sang MobiGold' ;
    dataLS.UFKK := 'MobiGold hòa mạng mới (do Mobi4U chuyển sang) / Mobi4U chuyển sang MobiGold' ;
    dataLS.ZFKK := 'MobiGold hòa mạng mới (do MobiZone chuyển sang) / MobiZone chuyển sang MobiGold: Còn tiền' ;
    dataLS.CHS := 'Thay đổi thông tin do thông tin trước đó CH/ ĐLC cập nhật bị sai / Chặn 2 chiều do cửa hàng sau' ;
    dataLS.DTEN := '- Đổi tên cá nhân := cập nhật thêm tên cá nhân sau tên doanh nghiệp- Đổi tên doanh nghiệp := do doanh nghiệp đổi tên' ;
    dataLS.KHYC := 'Thay đổi dịch vụ do KHYC / Thay sim / Thay đổi giữa các hình thức trả trước KH tự chuyển / Chặn 2 chiều do khách hàng yêu cầu' ;
    dataLS.NTNC := 'Nhắn tin thông báo cước' ;
    dataLS.NTTB := 'Nhắn tin nhắc cước hay nhắn nội dung khác' ;
    dataLS.WARN := 'Nhắn tin nhắc cước hay nhắn tin báo đỏ' ;
    dataLS.PAID := 'Mở 2 chiều do thanh toán nợ cước' ;
    dataLS.PAID := 'Mở 1 chiều do KH thanh toán cước' ;
    dataLS.XMD := 'Mở 1 chiều do đã xác minh được địa chỉ thuê bao' ;
    dataLS.128K := 'Đổi sim qua sim dung lượng 128K' ;
    dataLS.CA64 := 'Đổi sim qua sim dung lượng 64K' ;
    dataLS.DSMP := 'Đổi sim miễn phí' ;
    dataLS.CCQ := 'Thuê bao được đấu mới do CCQ và chủ cũ đã thanh toán hết cước / Chặn 2 chiều do chuyển chủ quyền / Cắt hủy/ cắt hẳn MobiGold để chuyển chủ quyền và chủ cũ đã thanh toán hết cước' ;
    dataLS.CQC := 'Thuê bao được đấu mới do chuyển chủ quyền và KH mới đồng ý thanh toán cước của chủ cũ' ;
    dataLS.ANNI := 'Chặn 1 chiều / 2 chiều do yêu cầu từ Bộ Công An' ;
    dataLS.CA1 := 'Chặn 2 chiều do mất máy / Chặn 1 chiều do mất máy' ;
    dataLS.CA4 := 'Chặn 2 chiều do mất sim / Chặn 1 chiều do mất sim' ;
    dataLS.DEBT := 'Chặn 1 chiều / Chặn 2 chiều do nợ cước' ;
    dataLS.KHD := 'Chặn 1 chiều do không dùng/Chặn 2 chiều do KH yêu cầu tạm khóa' ;
    dataLS.KHDC := 'Chặn 1 chiều / Chặn 2 chiều do địa chỉ không có thực, giả mạo hồ sơ' ;
    dataLS.KNAI := 'Chặn 1 / 2 chiều do khách hàng khiếu nại' ;
    dataLS.KVMS := 'Tạm khóa 2 chiều - VMS' ;
    dataLS.KXD := 'Chặn 1 / 2 chiều do không xác minh được thông tin thuê bao' ;
    dataLS.QROI := 'Chặn 1 / 2 chiều do thuê bao quấy rối' ;
    dataLS.THLY := 'Chặn 2 chiều do khách hàng yêu cầu thanh lý hợp đồng' ;
    dataLS.XMB := 'Chặn 1 / 2 chiều do khách hàng cung cấp sai địa chỉ' ;
    dataLS.BADO := 'Chặn 1 chiều do TB sử dụng vượt quá mức cước ứng trước, báo đỏ' ;
    dataLS.HSO := 'Chặn 1 chiều do không có hồ sơ' ;
    dataLS.OTH := 'Chặn 1 chiều do các lý do khác' ;
    dataLS.CSKS := 'Chặn 1 chiều do nghi ngờ sim kích hoạt sẵn' ;
    dataLS.3FON := 'Mobi365 chuyển sang MobiGold: không còn tiền' ;
    dataLS.CA05 := 'Cắt hủy/ cắt hẳn MobiGold trong vòng 5 ngày tính từ ngày hòa mạng (đã bỏ nghiệp vụ này)' ;
    dataLS.CA2 := 'Cắt hủy/ cắt hẳn MobiGold do sóng yếu' ;
    dataLS.CA3 := 'Cắt hủy/ cắt hẳn MobiGold do KH hủy số không sử dụng; Cắt hủy/ cắt hẳn trả trước do KH hủy số không sử dụng' ;
    dataLS.CCNV := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao nghiệp vụ' ;
    dataLS.CCVU := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao công vụ' ;
    dataLS.CMCV := 'Chuyển máy công vụ' ;
    dataLS.CNV := 'Cắt hủy/ cắt hẳn MobiGold nghiệp vụ' ;
    dataLS.CTHU := 'Cắt hủy/ cắt hẳn MobiGold thuộc sim thử' ;
    dataLS.DEAC := 'Chặn 2 chiều do hết hạn nghe / Thuê bao trả trước bị cắt hủy/ delete do bị khóa 2 chiều quá hạn (hiện nay là 31 ngày)' ;
    dataLS.DPFC := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Fast Connect trả trước' ;
    dataLS.FONS := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang SFONE' ;
    dataLS.FONV := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang Viettel' ;
    dataLS.GOZO := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiZone' ;
    dataLS.HOSO := 'Cắt hủy/ cắt hẳn MobiGold do không có hồ sơ' ;
    dataLS.KKH := 'MobiGold chuyển sang MobiCard, không kích hoạt' ;
    dataLS.M365 := 'Mobi365 chuyển sang MobiGold' ;
    dataLS.MEZ := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiEZ' ;
    dataLS.MF4U := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi4U' ;
    dataLS.MFQT := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Teen' ;
    dataLS.MFSV := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Student' ;
    dataLS.MGM3 := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi365' ;
    dataLS.MGMQ := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiQ' ;
    dataLS.MOBI := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiCard' ;
    dataLS.NO2T := 'Cắt hủy/ cắt hẳn MobiGold do nợ cước quá' ;
    dataLS.QFKK := 'Cắt MobiQ để chuyển sang MobiGold' ;
    dataLS.SAIS := 'Cắt hủy/ cắt hẳn MobiGold do CH/ ĐLC đấu nối số sai qui định' ;
    dataLS.TK6T := 'Cắt hủy/ cắt hẳn MobiGold do thuê bao khóa 2 chiều quá 6 tháng (hiện nay là quá 31 ngày)' ;
    dataLS.VINA := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang ViNaPhone' ;
    dataLS.DNTD := 'Đấu số trả trước mới (số mới - đấu nối tự động)' ;
    dataLS.DNFC := 'Đấu số MobiCard mới (do chuyển từ MobiGold sang)' ;
    dataLS.DNGQ := 'Đấu số MobiQ mới (do chuyển từ MobiGold sang)' ;
    dataLS.GLZO := 'MobiGold qua MobiZone' ;
    dataLS.FQTE := 'Chuyển MobiGold sang Q_TEEN' ;
    dataLS.DNQT := 'Chuyển MobiGold sang Mobi Qteen' ;
    dataLS.DNG3 := 'Chuyển MobiGold sang Mobi365' ;
    dataLS.DNFU := 'Chuyển MobiGold sang Mobi4U' ;
    dataLS.DNFSV := 'Chuyển MobiGold sang MobiQ_SV' ;
    dataLS.DN2S := 'Đấu nối Sim 2 số' ;
    dataLS.DNGD := 'Đấu nối hay khôi phục theo giấy duyệt' ;
    dataLS.DOIS := 'Đối soát' ;
    dataLS.HUY := 'Đấu F1 sửa sai TDN' ;
    dataLS.KP := 'Khôi phục số đã hủy' ;
    dataLS.VMS := 'Đấu mới' ;
    dataLS.STH := 'Sim Thu TT' ;
    dataLS.DNST := 'Đấu nối sim thử' ;
    dataLS.DBO := 'Thay đổi giữa các hình thức trả trước (do KH tự chuyển - bấm Note để xem chi tiết)' ;
    dataLS.QSV := 'Chuyển từ trả trước khác sang Q-SV' ;
    dataLS.QTE := 'Chuyển từ trả trước khác sang Q-Teen' ;
    dataLS.INAC := 'Chặn 1 chiều do hết hạn sử dụng (Mobi4U là do hết tiền)' ;
    dataLS.ACTI := 'Mở 2 chiều do nạp tiền / Kích hoạt số trả trước mới' ;
    dataLS.RES := 'Chặn 1 chiều do hết tiền (nhưng còn ngày sử dụng)' ;
    dataLS.CA7 := 'Hủy sim 2 số, thanh lý 1 số' ;

    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    key := Trim(newClipboard)
    A_Clipboard := oldClipboard
    MsgBox loopkup(dataLS, key)
}
F1:: {
    Send "^1"
}
F2:: {
    Send "^2"
}
F3:: {
    Send "^3"
}
F4:: {
    Send "^4"
}

F5:: {
    Send "^r"
    Sleep 200
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