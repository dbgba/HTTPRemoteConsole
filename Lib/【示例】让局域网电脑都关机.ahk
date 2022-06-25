; 一个批量让局域网所有挂载HTTP远程控制台的电脑都关机的脚本【也可以复制到网页端远程执行】

IP前三个段 := "192.168.0"
端口 := "8866"
执行功能 := "/GuanBiPC" ; 以延时关机为例
排除局域网本机IP := A_IPAddress1 ; A_IPAddress1为自动获取本机局域网IP，也可以填指定IP，比如："192.168.0.188"

Loop 255 {
    if (排除局域网本机IP!=IP前三个段 "." A_Index) {
        req := ComObjCreate("Msxml2.XMLHTTP")
        req.open("GET", "http://" IP前三个段 "." A_Index ":" 端口 执行功能, true)
        req.onreadystatechange := Func("Ready")
        req.send()
    }
}

Ready() {
    global req
    if (req.readyState != 4)
        return
    if (req.status == 200)
        return
}