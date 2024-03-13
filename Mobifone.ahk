#requires AutoHotkey v2.0
#SingleInstance force
;*  Always on top
^+t:: {                          ; Alt + t
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
^+1::{
    days := 10
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    dateString := Trim(A_Clipboard)
    date := DateParse(dateString)
    date := 0
    try {
        date := DateParse(dateString)
    } catch Error as e {
        date := A_Now
    }
    MsgBox(FormatDate(DateAdd_Custom(date,days)))
    return
}
;* Cộng 30 ngày theo Clipboard
^+3::{
    days := 30
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
    A_Clipboard := oldClipboard
    MsgBox(FormatDate(DateAdd_Custom(date,days)))
    return
}
;* Cộng 60 ngày theo Clipboard
^+6::{
    days := 60
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
    A_Clipboard := oldClipboard
    MsgBox(FormatDate(DateAdd_Custom(date,days)))
    return
}
;* Thông tin gia hạn linh hoạt
^+q::{
    ;Lấy giá hạn linh hoạt lần đầu tiên
    oldClipboard := A_Clipboard
    Send "^c"
    Sleep 500
    newClipboard := A_Clipboard
    newClipboard := Trim(newClipboard)
    ;tien xu ly gia tri
    stringMoney := newClipboard
    if InStr(newClipboard,"."){
        arr := StrSplit(newClipboard, ".")
        stringMoney := Format("{1}{2}",arr[1],arr[2])
    }
    if InStr(newClipboard,","){
        arr := StrSplit(newClipboard, ",")
        stringMoney := Format("{1}{2}",arr[1],arr[2])
    }

    result := "Không hợp lệ"
    IB := InputBox("Nhập giá gói cước", "Gia han linh hoat", "w150 h100")
    editValue := Trim(IB.Value)
    if IB.Result != "Cancel"{
        if editValue = "pt120" ||  editValue = "PT120" || editValue = "pT120" || editValue = "Pt120" {
            price := 120000
            priceOnDay := 4000
            chiaLayNguyen := Floor(stringMoney/priceOnDay)
            soTienChinh := chiaLayNguyen * priceOnDay
            stringPT120 := Format("Gói PT120 - Tổng giá gói: {1}đ`n`nGia hạn lần đầu: {2}đ cho {3} ngày`n`nGia hạn lần sau: {4}đ cho {5} ngày",120000, stringMoney, chiaLayNguyen, 120000 - stringMoney, 30 - chiaLayNguyen)
            result := stringPT120
        }
        else{
            priceOnDay := editValue / 30
            firstDay := stringMoney / priceOnDay
            secondDay := 30 - firstDay
            secondMoney := editValue - stringMoney
            result := Format("Tổng giá gói: {1}đ`n`nGia hạn lần đầu: {2}đ cho {3:0} ngày`n`nGia hạn lần sau: {4}đ cho {5:0} ngày",editValue, stringMoney, firstDay, secondMoney, secondDay)
        }
        MsgBox result
    }

    A_Clipboard := oldClipboard
    return
}
; 2023-09-03
^+e::{
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
    loop 18{
        if i = 0{
            MyGui.Add("Text","x10 y20 cRed", "Chu kỳ")
            MyGui.Add("Text", "x70 y20 cRed", "30 Ngày")
            MyGui.Add("Text","x160 y20 cRed", "31 Ngày")
            MyGui.Add("Text","xm", stringLine)
        }
        else{
            If i = 17
                MyGui.Add("Text","xm","Hết hạn")
            else
            MyGui.Add("Text","x10",i)

            lastDate30 := DateAdd_Custom(date,30*(i-1))
            lastDate31 := DateAdd_Custom(date,31*(i-1))
            if DateDiff__Custom(lastDate30) > 0
                MyGui.Add("Text","x70 yp cBlue	",FormatDate(lastDate30))
            else
                MyGui.Add("Text","x70 yp",FormatDate(lastDate30))

            if DateDiff__Custom(lastDate31) > 0
                MyGui.Add("Text","x160 yp cBlue",FormatDate(lastDate31))
            else
                MyGui.Add("Text","x160 yp",FormatDate(lastDate31))
            MyGui.Add("Text","xm", stringLine)
        }
        i := i + 1
    }
    
    A_Clipboard := oldClipboard
    MyGui.OnEvent("Escape", MyGui_Escape)
    MyGui_Escape(thisGui){
        WinClose titleGUI
    }
    MyGui.Show()
}

;* Đếm số cuộc gọi
global countCall := 0
CapsLock::{
    global countCall
    countCall := countCall + 1
    Send "^v"
    Sleep 300
    Send "{Enter}"
    return
}
^CapsLock::{
    MsgBox(Format("Số lượng CG: {1}", countCall))
}
^PgDn::{
    global countCall
    countCall := 0
    MsgBox Format("Số lượng CG được reset về {1}", countCall)
}
PgDn::{
    global countCall
    countCall := countCall + 1
    Sleep 200
    Send "{Down}"
}
;* Calculator Ready Time
global startTime := A_Now
global status := false ;true: ready / false: not
global secondNotTime := 0
;global beginNot := startTime
global beginNot := 20240313230000   
PgUp::{
    global status
    global secondNotTime
    global beginNot
    if status = false { ; neu dang not
        secondNotTime := secondNotTime +  DateDiff(A_Now, beginNot, "seconds")
        status := true
    }
    else { ; neu dang ready
        status := false
        beginNot := A_Now
    }
}
^PgUp::{
    global status
    stringStartTime := FormatTime(startTime, "HH:mm:ss")
    result := Format("Start Time: {1}`nTrạng thái: {2}`nTổng thời gian not: {3}", stringStartTime, status?"Ready":"Not", ConvertSecondToTime(secondNotTime))
    MsgBox result
}

ConvertSecondToTime(second){
    hours := Floor(second / 3600)
    minutes := Floor(( second - ( hours * 3600 ) ) / 60)
    return Format("{1} giờ {2} phút", hours, minutes)
}
;* Phím tắt gửi tin
^+w::{
    SendInput "Yeu cau ve dich vu Mobile Internet cua Quy khach da duoc xu ly. Chi tiet lien he 9090, MobiFone han hanh duoc phuc vu." 
    return
}

DateAdd_Custom(date, days) {
     return DateAdd(date, days, "days")
}
FormatDate(date){
    return FormatTime(date, "dd MMM yyyy")
}
DateDiff__Custom(date){
    return DateDiff(A_Now,date,"days")
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