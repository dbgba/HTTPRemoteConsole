# 简介
* 这是一款基于AutoHotkey开发的小巧轻量化 HTTP 远程控制台，可在手机端或PC端用浏览器来操作Windows电脑完成批量自动化操作。

* 不熟悉AHK脚本命令也可使用Cmd命令操作电脑。熟悉AHK命令之后，可用AHK完成办公自动化、网页自动化、游戏自动化等等复杂操作。

# 使用介绍
**运行 HTTPRemoteConsole.exe**后正常会转到网页控制台的界面，同时会将你的局域网地址和端口**同步到剪贴板**中，方便发送到手机端和在**手机端使用**。也可以通过公网IP或者内网穿透，方便的在外控制电脑。

打开后即开即用，除”**进程状态**“需要**根据自己电脑情况**更改路径**匹配**以外，其它功能均可正常使用。


**HTTPRemoteConsole.exe**为**AutoHotkey**解释器，**HTTPRemoteConsole.ahk**为脚本**源码**。源码可用**记事本打开**并修改**自定义**匹配你的电脑路径或显示信息，保证.ahk与.exe同名后运行**HTTPRemoteConsole.exe**即可开启服务。

![](https://gcore.jsdelivr.net/gh/dbgba/HTTPRemoteConsole@master/Preview.jpg)


**AutoHotkey**本身就是一个注重**自动化操作**的脚本语言，我已经把常用的自动化操作功能**集成在脚本**里，并写了大量注释。对于有定制**个性化需求**的朋友，可以编辑脚本来**调整代码**达到自己需要的效果。

[更多扩展玩法可点击查看](https://www.ahk66.com/)

# 编辑脚本
AutoHotkek可以对系统状态和窗口以及按键状态等等来进行判断、读取、修改、关闭等**组合操作**。

建议通过**托盘图标右键**的**编辑脚本**来查看更多使用方法，大量示例都写在注释里

托盘右键菜单提供了**AutoHotkey在线帮助文档**和用记事本编辑脚本的快捷方式
