;===========================================
;  【多进程代替多线程并互相通信函数】 Exec()、ExecSend()
;
;   使用说明：
;   1、启动进程：Exec(代码, 进程标记)
;   2、停止进程：Exec("", 进程标记)
;   3、进程标记相同，后启动的进程会替换先启动的进程
;   4、向新进程发送信息：ExecSend(代码, 进程标记)，向主进程发送则不带标记：ExecSend(代码)
;   5、ExecReturn:标签名是接收到信息后默认跳转调用的标签，%CopyOfData%是默认储存收到字符串的变量名
;   6、主脚本退出时，主脚本启动的所有进程都会被清理
;===========================================
 /*			; 以下注释内容为多进程互相通信示例
Gosub, F1
Gosub, F2

Loop {
  Sleep, 10
  ToolTip, 主进程可持续运算-%A_Index%
}
Return

;-- 这是多行的写法，括号中可以原样粘贴要运行的代码
F1::
s=
(` %
Menu, Tray, Tip, 托盘新建进程名F1
Gui, -MinimizeBox -MaximizeBox +AlwaysOnTop -DPIScale
Gui, Add, Edit, w300 R2 v通信显示 g同步发送
Gui Show, x850 y400 w330, 互相通信演示F1，请输入文字
Return

同步发送:
GuiControlGet, 获取编辑框内容,, 通信显示
ExecSend(获取编辑框内容,2)
Return

ExecReturn:
GuiControl,, 通信显示, %CopyOfData%
Return

GuiEscape:
GuiClose:
    ExitApp
)
;-- 使用开关变量来一键切换启动和停止
(ok:=!ok) ? Exec(s,1) : Exec("",1)
Return

F2::
s=
(` %
Gui, -MinimizeBox -MaximizeBox +AlwaysOnTop -DPIScale
Gui, Add, Edit, w300 R2 v通信显示 g同步发送
Gui Show, x850 y500 w330, 互相通信演示F2，请输入文字
Return

同步发送:
GuiControlGet, 获取编辑框内容,, 通信显示
ExecSend(获取编辑框内容,1)
Return

ExecReturn:
GuiControl,, 通信显示, %CopyOfData%
Return

GuiEscape:
GuiClose:
    ExitApp
)
Exec(s,2)
Return

;-- 清理进程
F3::Exec("",1), Exec("",2), Exec("",4)

;-- 这是一行新建进程的写法
F4::Exec("Loop{`nSleep,10`nMouseGetPos,x,y`nToolTip,F4-%A_Index%,x+15,y-30`n}",4)

其它用法:
; 对新进程可添加#NoTrayIcon 关闭托盘图标显示，也可以在NewProcess.ahk修改让新建进程默认隐藏托盘图标
ExecSend("直接传送字符串",1)
MsgBox, 0, 新进程自定义对话框标题, 新进程对话框内容
Return
 */
;=============== 多进程通信函数库 ===============
Exec(s, flag="Default") {			; Exec()  By FeiYue
	static Repetition:=101
	DetectHiddenWindows, On
	WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
	PostMessage, 0x111, 65307,,, %A_ScriptDir%\* ahk_pid %NewPID%
	Process, Close, %NewPID%
	if (A_TickCount-Repetition>100) { ; 加了100毫秒的误操作重复运行判断
		OnMessage(0x4a, "ExecReceive_WM_COPYDATA")
		add=`nflag=<<ExecNew%flag%>>`n
		(%
		#NoTrayIcon
		Gui, Gui_Flag_Gui: Show, Hide, %flag%
		DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
		OnMessage(DllCall("RegisterWindowMessage", "Str", "ShellHook"), "ShellEvent")
		OnMessage(0x4a, "ExecReceive_WM_COPYDATA")
		ShellEvent(wParam, lParam) {
			DetectHiddenWindows, On
			if !WinExist("HostProcessName")
				ExitApp
		}
		ExecSend(ByRef StringToSend, flag="Default") {
			VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
			SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
			NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
			NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
			DetectHiddenWindows, On
				if (flag="Default")
					SendMessage, 0x4a, 0, &CopyDataStruct,, HostProcessName ahk_class AutoHotkey
				else {
					WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
					SendMessage, 0x4a, 0, &CopyDataStruct,, %A_ScriptDir%\* ahk_pid %NewPID%
				} Return ErrorLevel
			}
		ExecReceive_WM_COPYDATA(wParam, lParam) {
			StringAddress := NumGet(lParam + 2*A_PtrSize)
			Global CopyOfData := StrGet(StringAddress)
			ExecLabel=ExecReturn
			Gosub %ExecLabel%
			Return true
		 }
		)
		s:=add "`n" s "`nExitApp"
		s:=RegExReplace(s, "HostProcessName", "ahk_pid "DllCall("GetCurrentProcessId"))
		WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
		PostMessage, 0x111, 65307,,, %A_ScriptDir%\* ahk_pid %NewPID%
		exec := ComObjCreate("WScript.Shell").Exec(A_AhkPath " /ErrorStdOut /f *")
		exec.StdIn.Write(s)
		exec.StdIn.Close()
	}
	Repetition:=A_TickCount
 }

ExecSend(ByRef StringToSend, flag="Default") {
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
	DetectHiddenWindows, On
	WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
	SendMessage, 0x4a, 0, &CopyDataStruct,, %A_ScriptDir%\* ahk_pid %NewPID%
	Return ErrorLevel
 }

ExecReceive_WM_COPYDATA(wParam, lParam) {
    StringAddress := NumGet(lParam + 2*A_PtrSize)
    Global CopyOfData := StrGet(StringAddress)
	ExecLabel=ExecReturn
	Gosub %ExecLabel%
    Return true
 }
;==================== URL编解码的函数 ========================
EncodeDecodeURI(str, encode := true, component := true) {			; By teadrinker
   static Doc, JS								; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=84825
   StringReplace, str, str, +, %A_Space%, All ;去连接符
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}

;==================== CPU使用率查看的函数 ========================
CPULoad() { ; By SKAN, CD:22-Apr-2014 / MD:05-May-2014. Thanks to ejor, Codeproject: http://goo.gl/epYnkO
Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
} 

; ==================== 内存占用率查看的函数 ========================
GlobalMemoryStatusEx() ; GlobalMemoryStatusEx() by jNizM
{
    static MSEX, init := VarSetCapacity(MSEX, 64, 0) && NumPut(64, MSEX, "UInt")
    if (DllCall("GlobalMemoryStatusEx", "Ptr", &MSEX)) {
        return { 1 : NumGet(MSEX,  4, "UInt")
               , 2 : NumGet(MSEX,  8, "UInt64"), 3 : NumGet(MSEX, 16, "UInt64")
               , 4 : NumGet(MSEX, 24, "UInt64"), 5 : NumGet(MSEX, 32, "UInt64") }
    }
}

; ==================== ToolTip临时显示 ========================
Tip(s:="", Priority:="") {
	SetTimer %A_ThisFunc%, % s="" ? "Off" : "-" (Priority="" ? 1800 : Priority)
	ToolTip, %s%, , , 17
}

; ==================== 语法报错中文提示 ========================
ProcessErrorMessage(exception) {
	SplitPath, % exception.File, FileName
	MsgBox 0x10, 你的"%FileName%"脚本语法写错了，请检查并修正！, % "发生错误的语句在第 " exception.Line " 行`n`n报错消息：" exception.Message "`n`n报错命令或函数的名称：" exception.What "`n`n报错额外信息：" exception.Extra
	ExitApp
 }