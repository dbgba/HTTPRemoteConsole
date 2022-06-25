 /*
═══════════════════════════════════════════════════════════
                                             AutoHotkey -- 网页远程控制台

          这是一款基于AutoHotkey开发的 HTTP 远程控制台，可在手机端或PC端用浏览器
    来操作Windows电脑完成批量自动化操作。
          当前版本即开即用，除"进程状态"需要根据自己电脑情况更改路径匹配以外，其它
    功能均可正常使用。不熟悉AHK脚本命令也可使用Cmd命令操作电脑。熟悉AHK命令
    之后，可用AHK完成办公自动化、网页自动化、游戏自动化等等复杂操作。

                                    此工具仅限于技术交流，切勿用于非法用途

═══════════════════════════════════════════════════════════
*/
#NoEnv
#Persistent
#MaxThreads 255
#SingleInstance Force
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu Tray, Icon, shell32.dll, 18

; 自动切换到管理员运行，这样能判断和控制进程状态
if !(A_IsAdmin || InStr(DllCall("GetCommandLine", "Str"), ".exe"" /r"))
    Run % "*RunAs " (s:=A_IsCompiled ? "" : A_AhkPath " /r ") """" A_ScriptFullPath """" (s ? "" : " /r")

; 用于修正32位AHK读取不到64位系统"C:\Windows\System32"的问题
if !(A_IsUnicode=1 and A_PtrSize=8)
    DllCall("Wow64DisableWow64FsRedirection")

; 参数结构："网页路径" : Func("对应调用的函数名称")
paths := {"/" : Func("主界面")
            , "/DingShi_onoff" : Func("定时任务")
            , "/LiuLanQi_onoff" : Func("浏览器")
            , "/QQ_onoff" : Func("QQ")
            , "/JingYin_onoff" : Func("电脑静音")
            , "/XvNiJi_onoff" : Func("虚拟机")
            , "/YuanChengKongZhi_onoff" : Func("远程控制")
            , "/QuanPingJieTu" : Func("全屏截图")
            , "/QingLiNeiCun" : Func("清理内存")
            , "/ChongQiPC" : Func("重启电脑")
            , "/GuanBiPC" : Func("关闭电脑")
            , "/ChaKanJieTu" : Func("关显示器")
            , "/CmdZiDingYi" : Func("执行Cmd命令")
            , "/QuXiaoChongQi" : Func("取消重启")
            , "/JieShuHTTP" : Func("结束服务")
            , "/AHKScript1" : Func("自定义新进程1")
            , "/AHKScript2" : Func("自定义新进程2")
            , "/AHKScript3" : Func("自定义新进程3")
            , "/QingLiJinCheng" : Func("清理新脚本进程")}

Server := New HttpServer()
Server.LoadMimes(A_ScriptDir "\Lib\mime.types")
Server.SetPaths(paths)
HTTP服务端口 := 8866
Server.Serve(HTTP服务端口)
Run "http://localhost:8866/" ; 启动脚本后打开控制台网页【这句可删除】

 ; 运行时会将局域网ip和端口一并保存到剪贴板中，方便自己打开或发送【外网访问需要公网IP或内网穿透】
Tip((Clipboard := "http://"A_IPAddress1 ":" HTTP服务端口) "`n已存入剪贴板" (A_IPAddress2="0.0.0.0" ? "" : "`n`nhttp://" A_IPAddress2 ":" HTTP服务端口) (A_IPAddress3="0.0.0.0" ? "" : "`n`nhttp://" A_IPAddress3 ":" HTTP服务端口) (A_IPAddress4="0.0.0.0" ? "" : "`n`nhttp://" A_IPAddress4 ":" HTTP服务端口))

Gosub 加载托盘菜单
Return

; ================= 以下是对应进程调用代码【按自己软件路径自行修改匹配】=================
;                  几乎每个函数都是一个单独的示例，搜索关键字或参数修改即可。推荐查看AHK帮助文档修改

; 搜寻"定时先锋v1.23.exe"进程，存在则结束其进程，不存在时则打开该软件【可替换成自己的定时软件名称】
定时任务(ByRef req, ByRef res) {
    Process, Exist, 定时先锋v1.23.exe
    if ErrorLevel {
        Process, Close, 定时先锋v1.23.exe
     } else {
        Run "D:\定时软件\定时先锋v1.23.exe"
    }
    ; 跳转回主界面
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

;【示例】清理360浏览器，根据自己所用的浏览器进程名替换即可
浏览器(ByRef req, ByRef res) {
    ; 循环30次，结束所有"360se.exe"进程
    Loop 30 {
        Process, Close, 360se.exe
     }
    ; 跳转回主界面
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; QQ启动与关闭【以下是1080p屏抓的图，不保证通用。需要自行启动Lib\FindText.ahk，抓图替换到"QQ托盘图标"变量】
QQ(ByRef req, ByRef res) {
    ; QQ进程存在时，用FindText屏幕找图找到QQ托盘图标并点击鼠标右键关闭QQ。进程不存在时，则启动QQ
    Process, Exist, QQ.exe
    if ErrorLevel {
        QQ托盘图标:="|<>*105$5.8cU8k|<>*82$9.zyHmTPUC3U"
        if (ok:=FindText(X, Y, 201-150000, 380-150000, 201+150000, 380+150000, 0, 0, QQ托盘图标)) {
            FindText().Click(X, Y, "R")
            Sleep 2000 ; 根据电脑性能情况可增加延时等待菜单弹出的时间
            FindText().Click(X+30, Y-35, "L")
        }
     } else { ; 以下这条改成你的QQ启动器路径
        Run "D:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe"
    }
    ; 等待至少6秒，让QQ完全退出后再刷新网页
    Loop 60 {
        Sleep 100
        Process, Exist, QQ.exe
            if !ErrorLevel {
                break
            }
    }
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 发送媒体键"静音"，使电脑切换音量状态
电脑静音(ByRef req, ByRef res) {
	; 还可以控制更多状态，播放暂停:Media_Play_Pause、下一曲:Media_Next等等。详见AHK帮助文档的按键列表说明
    Send {Volume_Mute}
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

;虚拟机VMware进程存在时，则激活窗口用组合键退出在用虚拟机并退出软件，不存在时则启动VMware
虚拟机(ByRef req, ByRef res) {
    ; 因为AHK是单线程工作，所以Sleep和Msgbox这种阻塞线程的命令不要出现在主线程里。
    ; 可以用以下新建进程执行的方式来解决处理，也可以改成SetTimer异步执行
    Process, Exist, vmware.exe
    if ErrorLevel {
        AHK代码=
        (` %
            WinActivate, ahk_class VMUIFrame
            Sleep 2000
            Send ^e
            Sleep 5000
            Send {Alt Down}
            Sleep 500
            Send f
            Send x
            Send {Alt Up}
        )
        Exec(AHK代码,4)
      } else ; 以下这条改成你的VMware启动路径，也可改成.vmx虚拟机文件直接启动指定虚拟机
        Run "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 因为ToDesk会自提升到System权限，所以得调用微软工具PsExec结束其进程
; https://docs.microsoft.com/zh-cn/sysinternals/downloads/psexec
远程控制(ByRef req, ByRef res) {
    Process, Exist, ToDesk.exe
    if ErrorLevel {
        Run "%A_AhkPath%" "%A_ScriptDir%\调用工具\关闭ToDesk远程控制\关闭远程控制.ahk"
     } else { ; 以下这条改成你的ToDesk路径
        Run "C:\Program Files (x86)\ToDesk\ToDesk.exe"
    }
    ; 等待至少3秒，让ToDesk完全退出后再刷新网页
    Loop 30 {
        Sleep 100
        Process, Exist, ToDesk.exe
            if !ErrorLevel {
                break
            }
    }
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

全屏截图(ByRef req, ByRef res, ByRef server) {
    ; 调用ImagePut库进行全屏截图，A_ScreenWidth=获取屏幕的宽度，A_ScreenHeight=获取屏幕高度
    ImagePutFile([0,0,A_ScreenWidth,A_ScreenHeight], "全屏截图.png", 100)
    server.ServeFile(res, A_ScriptDir "/全屏截图.png"), res.status := 200
 }

; 调用微软内存工具RAMMap自动清理内存和备用内存的流程脚本
; https://docs.microsoft.com/en-us/sysinternals/downloads/rammap
清理内存(ByRef req, ByRef res) {
    For objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process") {
        Try {
            hProcess := DllCall("OpenProcess", "uint", 0x001F0FFF, "int", 0, "uint", objItem.ProcessID, "ptr")
            DllCall("SetProcessWorkingSetSize", "ptr", hProcess, "uptr", -1, "uptr", -1)
            DllCall("psapi.dll\EmptyWorkingSet", "ptr", hProcess)
            DllCall("CloseHandle", "ptr", hProcess)
        }
    }
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 异步执行一分钟后，重启
重启电脑(ByRef req, ByRef res) {
    Global
    SetTimer 一分钟后重启, -60000
    重启读秒 := 60, 重启电脑显示 := "秒重启"
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
    SetTimer 重启读秒显示刷新, 1000
    Return

    重启读秒显示刷新:
    重启读秒 -= 1
    Return

    一分钟后重启:
    Shutdown, 6
    Return
 }

; 异步执行一分钟后，关机
关闭电脑(ByRef req, ByRef res) {
    Global
    SetTimer 一分钟后关机, -60000
    关机读秒 := 60, 关闭电脑显示 := "秒关机"
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
    SetTimer 关机读秒显示刷新, 1000
    Return

    关机读秒显示刷新:
    关机读秒 -= 1
    Return

    一分钟后关机:
    Shutdown, 5
    Return
 }

关显示器(ByRef req, ByRef res, ByRef server) {
    SendMessage, 0x112, 0xF170, 2, , Program Manager  ; 0x0112 是 WM_SYSCOMMAND, 0xF170 是 SC_MONITORPOWER.
    ; 对上面命令的注释: 使用 -1 代替 2 来打开显示器，使用 1 代替 2 来激活显示器的节能模式.
    ; 更多参数：https://docs.microsoft.com/zh-cn/windows/win32/menurc/wm-syscommand?redirectedfrom=MSDN
    
    ; ComObjCreate("Shell.Application").ToggleDesktop()  ; 显示桌面写法【等效于桌面右下角按钮】
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 调用RunCmd库来执行Cmd命令，具体说明请查看"\Lib\RunCMD.ahk"
执行Cmd命令(ByRef req, ByRef res) {
    ; 为防止线程被阻塞，所以使用新进程执行Cmd命令。以下示例因为包含字符转义和变量添加，比较特殊略复杂
    ; 不建议不熟悉AHK的做为参考。需要新建进程的，可参考虚拟机新建进程那个模板来使用。
    给新进程使用的Cmd指令要存为变量 := 获取网页传递代码并还原(req)
    AHK代码=
    (
        SetWorkingDir `%A_ScriptDir`%
        #Include `%A_ScriptDir`%\Lib\RunCMD.ahk
        ExecSend(RunCmd("%给新进程使用的Cmd指令要存为变量%"))
    )
    Exec(AHK代码,5)
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 取消异步"一分钟后重启"和"一分钟后关机"的计时
取消重启(ByRef req, ByRef res) {
    Global
    SetTimer 一分钟后关机, off
    SetTimer 一分钟后重启, off
    SetTimer 重启读秒显示刷新, off
    SetTimer 关机读秒显示刷新, off
    关闭电脑显示 := "关闭电脑", 重启电脑显示 := "重启电脑", 重启读秒 := "", 关机读秒 := ""
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 点击 "结束服务" 按钮开始90秒倒计时结束自身，想取消在计时到之前再点击一次按钮即可取消
结束服务(ByRef req, ByRef res) {
    Global
    if (onoff := !onoff) {
        SetTimer 延时结束自身, -99000
        SetTimer 结束服务显示刷新, 1000
        结束服务读秒 := 99, 结束服务显示 := "秒结束"
      } else {
        SetTimer 延时结束自身, off
        SetTimer 结束服务显示刷新, off
        结束服务读秒 := "", 结束服务显示 := "结束服务"
     }
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
    Return

    结束服务显示刷新:
    结束服务读秒 -= 1
    Return

    延时结束自身:
    ExitApp
 }

自定义新进程1(ByRef req, ByRef res) {
    ; 获取网页传递的代码，并还原URL编码
    自定义新进程代码1 := 获取网页传递代码并还原(req)
    Exec(自定义新进程代码1,1)
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

自定义新进程2(ByRef req, ByRef res) {
    自定义新进程代码2 := 获取网页传递代码并还原(req)
    Exec(自定义新进程代码2,2)
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 以下做了个特殊的示例，在编辑框里输入"控制面板"后，用"进程3运行"。可以远程打开控制面板并返回提示到编辑框中
; 熟悉AHK后，可以自定义个人指令完成一套自动化流程并返回值到网页显示【相当于网页端的MsgBox，可供调试和确认】
自定义新进程3(ByRef req, ByRef res) {
    自定义新进程代码3 := 获取网页传递代码并还原(req)
    if (自定义新进程代码3="控制面板") {
        ; 新建进程运行，打开控制面板后，向主进程返回进度并在网页中显示出来【简单的演示，可自由发挥】
        自定义新进程代码3=
        (` %
            Run control.exe
            WinWait, ahk_class CabinetWClass
            ExecSend("控制面板已启动") ; 新进程往网页线程发送"编辑框返回值显示"的反馈信息
        )
        Exec(自定义新进程代码3,3)
      } else
        Exec(自定义新进程代码3,3)
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 此标签是用来接收新进程发送的数据，CopyOfData是接收数据的变量名
ExecReturn:
编辑框返回值显示 := CopyOfData
Return

; 清理释放网页端自定义的那三个新进程。新进程控制更多使用方法请查看"\Lib\多线程互相通信和系统显示.ahk"
清理新脚本进程(ByRef req, ByRef res) {
    Exec("",1), Exec("",2), Exec("",3)
    res.SetBodyText("<head><meta http-equiv=""refresh"" content=""0.1;url=/""></head>"), res.status := 200
 }

; 获取网页传递的代码，并还原URL编码的函数
获取网页传递代码并还原(req) {
    Http请求体数组代码还原 := "", Http请求体数组代码还原 := Object()
    For each, Pair in StrSplit(req.body,"&")
        Part := StrSplit(Pair, "="), Http请求体数组代码还原.Push([Part[1], Part[2]])
    还原完成的代码 := EncodeDecodeURI(Http请求体数组代码还原[1,2], false)
    return 还原完成的代码
 }

; 网页控制台的主页面显示
主界面(ByRef req, ByRef res) {
    Global
    ; 先加载各种电脑实时状态到变量里，再反映到网页控制台中显示
    CPULoad() ; CPU使用率显示预加载

    DriveGet, 总容量, Capacity, C:/
    DriveSpaceFree, 可用空间数, C:/

    可用空间显示 := Format("{:.1f}", 可用空间数/1024)
    总容量显示 := Format("{:.1f}", 总容量/1024)

    GMSEx := GlobalMemoryStatusEx()
    内存大小显示 := Format("{:.2f}", GMSEx[2]/1073741824)
    内存占用率显示 := GMSEx[1]

    RegRead, 系统名称获取, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
    系统名称显示 := StrReplace(StrReplace(StrReplace(系统名称获取,"Windows","Win"),"Microsoft ",""),"Enterprise","企业版")

    Process, Exist, 定时先锋v1.23.exe
        定时任务显示 := ErrorLevel=0 ? "未启动" : "已启动"
    Process, Exist, 360se.exe
        浏览器显示 := ErrorLevel=0 ? "未启动" : "已启动"
    Process, Exist, QQ.exe
        QQ显示 := ErrorLevel=0 ? "未启动" : "已启动"
    Process, Exist, vmware.exe
        虚拟机显示 := ErrorLevel=0 ? "未启动" : "已启动"
    Process, Exist, ToDesk.exe
        远程控制显示 := ErrorLevel=0 ? "未启动" : "已启动"
    SoundGet, 当前音量状态, , mute
        音量状态显示 := 当前音量状态="off" ? "未静音" : "已静音"

    重启电脑显示 := 重启电脑显示="" ? "重启电脑" : 重启电脑显示
    关闭电脑显示 := 关闭电脑显示="" ? "关闭电脑" : 关闭电脑显示
    结束服务显示 := 结束服务显示="" ? "结束服务" : 结束服务显示
    编辑框返回值显示 := 编辑框返回值显示="" ? "可输入自定义Cmd命令↑`n【双击编辑框可复制灰字到剪贴板】                `n也可输入自定义AHK命令↓" : 编辑框返回值显示

    ; 新进程运行中，点击 "1 运行中" 按钮可以关闭对应进程
    DetectHiddenWindows, On
    WinGet, 新进程1在线显示, PID, <<ExecNew1>> ahk_class AutoHotkeyGUI
    WinGet, 新进程2在线显示, PID, <<ExecNew2>> ahk_class AutoHotkeyGUI
    WinGet, 新进程3在线显示, PID, <<ExecNew3>> ahk_class AutoHotkeyGUI
    新进程1在线显示 := 新进程1在线显示="" ? "进程1运行" : "1 运行中"
    新进程2在线显示 := 新进程2在线显示="" ? "进程2运行" : "2 运行中"
    新进程3在线显示 := 新进程3在线显示="" ? "进程3运行" : "3 运行中"

    CPU使用率显示 := CPULoad()

    主界面网页源码 =
    (LTrim
        <html><head><meta charset="UTF-8"><head><meta name="viewport" content="width=device-width">
        <title>NAS控制台</title>
        <link href='http://fonts.googleapis.com/css?family=Ubuntu' rel='stylesheet' type='text/css'><style type="text/css">
        html {font-family: Ubuntu;}
        body {margin:25px;margin-top:5px;}
        h4 {font-size: 20px;color:green;}
        h5 {font-size: 16px;color:teal;}
        </style></head></html>
        <body><form action="" name="AHKScript" method="post">
        <textarea name="TextArea1" id="TextArea1" placeholder="%编辑框返回值显示%" style="position:absolute;left:27px;top:311px;width:358px;height:86px;z-index:10;" ondblclick="send(5)" rows="4" cols="37" spellcheck="false"></textarea>    
        <button  style="position:absolute;font-family:微软雅黑;left:10px;top:428px;width:84px;height:24px;z-index:11;" onclick="send(1)"/>%新进程1在线显示%</button>
        <button style="position:absolute;font-family:微软雅黑;left:112px;top:428px;width:84px;height:24px;z-index:15;" onclick="send(2)"/>%新进程2在线显示%</button>
        <button style="position:absolute;font-family:微软雅黑;left:215px;top:428px;width:84px;height:24px;z-index:9;" onclick="send(3)"/>%新进程3在线显示%</button>
        <button style="position:absolute;font-family:微软雅黑;left:114px;top:265px;width:78px;height:24px;z-index:19;" onclick="send(4)"/>Cmd命令</button>
        <script>
        function send(type) {
            var url = '';
            if (type === 1)
                url = '/AHKScript1';
              else if (type === 2)
                url = '/AHKScript2';
              else if (type === 3)
                url = '/AHKScript3';
              else if (type === 4)
                url = '/CmdZiDingYi';
              else {
                const input = document.querySelector('#CopyTextArea1');
                input.select();
                if (document.execCommand('copy')) {
                    document.execCommand('copy');
                    console.log('复制成功');
                }
            }
            document.AHKScript.action = url;
            document.AHKScript.submit();
        }
        </script>

        <input type="submit" id="Button15" value="清理进程" style="position:absolute;left:321px;top:428px;width:78px;height:24px;z-index:39;">

        <div id="wb_Text1" style="position:absolute;left:12px;top:45px;width:112px;height:14px;z-index:0;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>定时任务：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%定时任务显示%</span></div>
        <form><input type="submit" id="Button1" value="开关" style="position:absolute;left:124px;top:46px;width:65px;height:21px;z-index:1;">
        </form>
        <div id="wb_Text2" style="position:absolute;left:220px;top:45px;width:112px;height:14px;z-index:2;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>浏览器：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%浏览器显示%</span></div>
        <form><input type="submit" id="Button2" value="开关" style="position:absolute;left:334px;top:46px;width:65px;height:21px;z-index:3;">
        </form>
        <div id="wb_Text3" style="position:absolute;left:12px;top:86px;width:112px;height:14px;z-index:4;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>QQ：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%QQ显示%</span></div>
        <form><input type="submit" id="Button3" value="开关" style="position:absolute;left:124px;top:87px;width:65px;height:21px;z-index:5;">
        </form>
        <div id="wb_Text4" style="position:absolute;left:220px;top:86px;width:112px;height:14px;z-index:13;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>音量状态：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%音量状态显示%</span></div>
        <form><input type="submit" id="Button4" value="开关" style="position:absolute;left:334px;top:87px;width:65px;height:21px;z-index:14;">
        </form>
        <div id="wb_Text5" style="position:absolute;left:12px;top:128px;width:112px;height:14px;z-index:17;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>虚拟机：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%虚拟机显示%</span></div>
        <form><input type="submit" id="Button5" value="开关" style="position:absolute;left:124px;top:129px;width:65px;height:21px;z-index:18;">
        </form>
        <div id="wb_Text6" style="position:absolute;left:220px;top:128px;width:112px;height:14px;z-index:22;">
            <span style="color:#919191;font-family:微软雅黑;font-size:13px;"><strong>远控软件：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:13px;">%远程控制显示%</span></div>
        <form><input type="submit" id="Button6" value="开关" style="position:absolute;left:334px;top:129px;width:65px;height:21px;z-index:23;">
        </form>

            <input type="submit" id="Button7" value="全屏截图" style="position:absolute;left:12px;top:211px;width:78px;height:24px;z-index:6;">
            <input type="submit" id="Button8" value="清理内存" style="position:absolute;left:114px;top:211px;width:78px;height:24px;z-index:7;">
            <input type="submit" id="Button9" value="%重启读秒%%重启电脑显示%" style="position:absolute;left:217px;top:211px;width:78px;height:24px;z-index:8;">
            <input type="submit" id="Button10" value="%关机读秒%%关闭电脑显示%" style="position:absolute;left:321px;top:211px;width:78px;height:24px;z-index:16;">
            <input type="submit" id="Button11" value="关显示器" style="position:absolute;left:12px;top:265px;width:78px;height:24px;z-index:12;">
            <input type="submit" id="Button13" value="取消重启" style="position:absolute;left:217px;top:265px;width:78px;height:24px;z-index:20;">
            <input type="submit" id="Button14" value="%结束服务读秒%%结束服务显示%" style="position:absolute;left:321px;top:265px;width:78px;height:24px;z-index:21;">

        <div id="wb_Text10" style="position:absolute;left:169px;top:10px;width:73px;height:18px;text-align:center;z-index:26;">
            <span style="color:#000000;font-family:微软雅黑;font-size:17px;"><strong>进程状态</strong></span>
        </div>
        <hr id="Line2" style="position:absolute;left:19px;top:14px;width:136px;z-index:27;">
        <hr id="Line3" style="position:absolute;left:256px;top:14px;width:135px;z-index:28;">
        <div id="wb_Text11" style="position:absolute;left:168px;top:171px;width:73px;height:18px;text-align:center;z-index:29;">
            <span style="color:#000000;font-family:微软雅黑;font-size:17px;"><strong>全局控制</strong></span>
        </div>
        <hr id="Line1" style="position:absolute;left:18px;top:175px;width:136px;z-index:30;">
        <hr id="Line4" style="position:absolute;left:255px;top:175px;width:135px;z-index:31;">
        <div id="wb_Text12" style="position:absolute;left:168px;top:475px;width:73px;height:18px;text-align:center;z-index:32;">
            <span style="color:#000000;font-family:微软雅黑;font-size:17px;"><strong>主机状态</strong></span>
        </div>
        <hr id="Line5" style="position:absolute;left:18px;top:479px;width:136px;z-index:33;">
        <hr id="Line6" style="position:absolute;left:255px;top:479px;width:135px;z-index:34;">
        <div id="wb_Text7" style="position:absolute;left:11px;top:513px;width:180px;height:17px;z-index:24;">

            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>系统名称：</strong></span><span style="color:#000000;font-family:Calibri;font-size:15px;">%系统名称显示%</span>
        </div>
        <div id="wb_Text8" style="position:absolute;left:201px;top:513px;width:180px;height:17px;z-index:25;">
            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>CPU使用率：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:15px;">%CPU使用率显示% `%</span>
        </div>
        <div id="wb_Text13" style="position:absolute;left:12px;top:542px;width:177px;height:17px;z-index:35;">
            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>内存大小：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:15px;">%内存大小显示% GB</span>
        </div>
        <div id="wb_Text14" style="position:absolute;left:200px;top:542px;width:180px;height:17px;z-index:36;">
            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>内存占用率：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:15px;">%内存占用率显示% `%</span>
        </div>
        <div id="wb_Text15" style="position:absolute;left:12px;top:571px;width:180px;height:17px;z-index:37;">
            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>---- C盘存储状态 ----</strong></span>
        </div>
        <div id="wb_Text9" style="position:absolute;left:200px;top:571px;width:218px;height:17px;z-index:38;">
            <span style="color:#919191;font-family:微软雅黑;font-size:15px;"><strong>可用空间：</strong></span><span style="color:#000000;font-family:微软雅黑;font-size:15px;">%可用空间显示% GB／%总容量显示% GB</span>
        </div>
       <textarea id="CopyTextArea1" style="position:absolute;left:-11px;top:-11px;width:1px;height:1px;">%编辑框返回值显示%</textarea>
    <script>
    //以下是点击按钮对应跳转的代码
    window.onload = function () {
        var div = document.querySelector("div");
        document.querySelector("#Button1").onclick = function () {
            if (window.confirm('确定要开关定时任务吗？'))
                window.location.href='/DingShi_OnOff'; ;return false;
          }
        document.querySelector("#Button2").onclick = function () {
            if (window.confirm('确定要关闭浏览器吗？'))
                window.location.href='/LiuLanQi_OnOff'; ;return false;
          }
        document.querySelector("#Button3").onclick = function () {
            if (window.confirm('确定要开关QQ吗？'))
                window.location.href='/QQ_OnOff'; ;return false;
          }
        document.querySelector("#Button4").onclick = function () {
            if (window.confirm('确定要改变电脑音量状态吗？'))
                window.location.href='/JingYin_onoff'; ;return false;
          }
        document.querySelector("#Button5").onclick = function () {
            if (window.confirm('确定要开关虚拟机吗？'))
                window.location.href='/XvNiJi_OnOff'; ;return false;
          }
        document.querySelector("#Button6").onclick = function () {
            if (window.confirm('确定要开关其它远控软件吗？'))
                window.location.href='/YuanChengKongZhi_OnOff'; ;return false;
          }
        document.querySelector("#Button7").onclick = function () {
                window.location.href='/QuanPingJieTu'; ;return false;
          }
        document.querySelector("#Button8").onclick = function () {
            if (window.confirm('确定要清理内存吗？'))
                window.location.href='/QingLiNeiCun'; ;return false;
          }
        document.querySelector("#Button9").onclick = function () {
            if (window.confirm('确定要延时重启电脑吗？'))
                window.location.href='/ChongQiPC'; ;return false;
          }
        document.querySelector("#Button10").onclick = function () {
            if (window.confirm('确定要延时关闭电脑吗？'))
                window.location.href='/GuanBiPC'; ;return false;
          }
        document.querySelector("#Button11").onclick = function () {
                window.location.href='/ChaKanJieTu'; ;return false;
          }
        document.querySelector("#Button13").onclick = function () {
            //取消延时关机、重启，直接取消不用确认
                window.location.href='/QuXiaoChongQi'; ;return false;
          }
        document.querySelector("#Button14").onclick = function () {
                window.location.href='/JieShuHTTP'; ;return false;
          }
          document.querySelector("#Button15").onclick = function () {
            if (window.confirm('要清理在用的新建脚本进程吗？'))
                window.location.href='/QingLiJinCheng'; ;return false;
          }
    }
            </script>
        </body>
    </html>
    )
    res.SetBodyText(主界面网页源码), res.status := 200
}

加载托盘菜单:
Menu, Tray, NoStandard
Menu, Tray, DeleteAll
Menu, Tray, UseErrorLevel
Menu, Tray, Add, 重启HTTP(&R), 重启脚本
if A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
    Menu, Tray, Icon, 重启HTTP(&R), shell32.dll, 147, 16
 else
    Menu, Tray, Icon, 重启HTTP(&R), shell32.dll, 239, 16
Menu, Tray, Add,
Menu, Tray, Add, 编辑脚本(&E), 编辑脚本
Menu, Tray, Icon, 编辑脚本(&E), C:\Windows\System32\Notepad.exe, 1, 16
Menu, Tray, Add,
Menu, Tray, Add, 语法帮助(&H), AHK在线帮助文档
Menu, Tray, Icon, 语法帮助(&H), shell32.dll, 24, 16
Menu, Tray, Add,
Menu, Tray, Add, 关于脚本(&A), HTTP关于界面
Menu, Tray, Icon, 关于脚本(&A), shell32.dll, 222, 16
Menu, Tray, Add,
Menu, Tray, Add, 关闭HTTP(&X), 关闭脚本
Menu, Tray, Icon, 关闭HTTP(&X), shell32.dll, 132, 16
Menu, Tray, Color, ffffff
Menu, Tray, Default, 关闭HTTP(&X)
OnError("ProcessErrorMessage")  ; 语法报错中文提示
Return

AHK在线帮助文档:
Run https://www.autoahk.com/help/autohotkey/zh-cn/docs/AutoHotkey.htm
Return

编辑脚本:
Edit
Return

重启脚本:
Reload
Return

关闭脚本:
ExitApp
Return

HTTP关于界面:
Gui, HTTP_About:New, -MaximizeBox -MinimizeBox
Gui, HTTP_About:Margin, , 16
Gui, HTTP_About:Add, Picture, w48 h-1 Icon18, shell32.dll
Gui, HTTP_About:Font, S12 Bold
Gui, HTTP_About:Add, Text, x+10 yp+1 vTAppName Section,         HTTP 远程控制台
Gui, HTTP_About:Font
Gui, HTTP_About:Add, Text, xs+4 y+10, 仅限于技术交流，切勿用于非法用途
Gui, HTTP_About:Add, Text, xs+8 y+10, 感谢：AutoHotkey|中文社区
Gui, HTTP_About:Add, Button, x116 y123 w70 Default gHTTP_AboutGuiClose, 确定
Gui, HTTP_About:Add, Link, x78 y81, <a href="tencent://groupwpa/?subcmd=all&param=7B22457874506172616D223A7B226170704964223A223231227D2C2267726F757055696E223A3731373934373634372C2276697369746F72223A317D">QQ群：717947647</a>
Gui, HTTP_About:Add, Text, x78 y101,  Copyright (C) 2022 dbgba
GuiControlGet, rcCtrl, HTTP_About:Pos, TAppName
Gui, HTTP_About:Add, Link,x12 y114 w60 h34, <a href="https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.33.02_setup.exe">点击下载`nAHK安装包</a>
Gui, HTTP_About:Show, Autosize
Return

HTTP_AboutGuiClose:
Gui, HTTP_About:Destroy
Return

; 程序由"HTTP远程控制台.exe"、"HTTP远程控制台.ahk"以及Lib文件夹的库组成。其它的工具文件不属于必要文件
; 需要加载调用的脚本库文件，请勿改动
#Include <AHKhttp> ; https://github.com/Skiouros/AHKhttp/blob/master/AHKhttp.ahk
#Include <AHKsock> ; https://github.com/jleb/AHKsock/blob/master/AHKsock.ahk
#Include <ImagePut> ; https://github.com/iseahound/ImagePut
#Include <RunCMD> ; https://www.autohotkey.com/boards/viewtopic.php?t=74647
#Include <FindText> ; https://blog.csdn.net/xshlong1981/article/details/103324372
#Include <多进程互相通信和系统显示> ; 新进程控制更多使用方法请查看此脚本