#Persistent
#SingleInstance force

Setworkingdir, %A_ScriptDir%

; 读取 Aria2AHK.ini 的配置 {{{1
IniRead, Aria2ExeName, Aria2AHK.ini, Setting, Aria2ExeName
IniRead, Aria2Config, Aria2AHK.ini, Setting, Aria2Config
IniRead, FrontendFolder, Aria2AHK.ini, Setting, FrontendFolder
IniRead, FrontendHtml, Aria2AHK.ini, Setting, FrontendHtml
IniRead, Aria2Proxy, Aria2AHK.ini, Setting, Aria2Proxy
IniRead, BTTrakcersList, Aria2AHK.ini, Setting, BTTrakcersList
IniRead, BTTracker, Aria2AHK.ini, Config, bt-tracker

;载入配置文件信息 {{{2
ConfigNumber = 0
Loop {
	ConfigNumber := ConfigNumber + 1
	IniRead, ConfigName%ConfigNumber%, Aria2AHK.ini, Config, ConfigName%ConfigNumber%
	IniRead, ConfigPath%ConfigNumber%, Aria2AHK.ini, Config, ConfigPath%ConfigNumber%
} Until ConfigNumber >= 3

; 判断默认配置信息 {{{2
IniRead, SelectConfig, Aria2AHK.ini, Config, SelectConfig
If SelectConfig between 1 and 3
{
	IniRead, CurrentConfig, Aria2AHK.ini, Config, ConfigName%SelectConfig%
	IniRead, CurrentConfigPath, Aria2AHK.ini, Config, ConfigPath%SelectConfig%
} Else {
	MsgBox, 配置错误，按 Esc 键退出程序。
ExitApp
}

; 托盘菜单配置 {{{1
Menu, Tray, NoStandard
Menu, Tray, Tip, Aria2AHK
Menu, Tray, Icon, Aria2AHK.ico, 1, 1
Menu, Tray, Add, 打开 Web 前端, Frontend
Menu, Tray, Add  ; 分隔线.
If (ConfigName1 !="")
{
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName1%, Aria2AddTask10
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName1%（代理）, Aria2AddTask11
	Menu, Aria2ProfileMenu, Add, %ConfigName1%, CurrentConfig1
}
If (ConfigName2 !="")
{
    Menu, Aria2AddTaskMenu, Add  ; 分隔线.
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName2%, Aria2AddTask20
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName2%（代理）, Aria2AddTask21
	Menu, Aria2ProfileMenu, Add, %ConfigName2%, CurrentConfig2
}
If (ConfigName3 !="")
{
    Menu, Aria2AddTaskMenu, Add  ; 分隔线.
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName3%, Aria2AddTask30
	Menu, Aria2AddTaskMenu, Add, 下载至 %ConfigName3%（代理）, Aria2AddTask31
	Menu, Aria2ProfileMenu, Add, %ConfigName3%, CurrentConfig3
}
Menu, Aria2AddTaskMenu, Add  ; 分隔线.
Menu, Aria2AddTaskMenu, Add, 代理参数：%Aria2Proxy%, NReturn
Menu, Tray, Add, 添加下载任务, :Aria2AddTaskMenu
Menu, Tray, Add, 默认下载路径, :Aria2ProfileMenu
Menu, Tray, Add, 更新 BT-Trackers, UpdateBTTracker
Menu, Tray, Add, 重启 Aria2, ReStartAria2
Menu, Tray, Add  ; 分隔线.
Menu, Tray, Add, 退出, Exit
Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
Goto, ReStartAria2
Return

Frontend:	 ;打开网页前端 {{{1
Run, %A_ScriptDir%\%FrontendFolder%\%FrontendHtml%
Return

;添加下载任务 {{{1
Aria2AddTask10:
Aria2AddTask(1, 0)
Return

Aria2AddTask11:
Aria2AddTask(1, 1)
Return

Aria2AddTask20:
Aria2AddTask(2, 0)
Return

Aria2AddTask21:
Aria2AddTask(2, 1)
Return

Aria2AddTask30:
Aria2AddTask(3, 0)
Return

Aria2AddTask31:
Aria2AddTask(3, 1)
Return

NReturn:
Return

;切换默认下载路径 {{{1
CurrentConfig1:			 ;切换至配置1 {{{2
SwitchConfig(1)
Reload
Return

CurrentConfig2:			 ;切换至配置2 {{{2
SwitchConfig(2)
Reload
Return

CurrentConfig3:			 ;切换至配置3 {{{2
SwitchConfig(3)
Reload
Return

;更新 BT Tracker {{{1
UpdateBTTracker:
UrlDownloadToFile, %BTTrakcersList%, %A_ScriptDir%\TrackersLists.list
FileReadLine, Trackers, %A_ScriptDir%\TrackersLists.list, 1
IniWrite, %Trackers%, Aria2AHK.ini, Config, bt-tracker
FileDelete, %A_ScriptDir%\TrackersLists.list
Reload

ReStartAria2:   ;重启 Aria2 {{{1
Gosub, CheckKillAria2
Run, %A_ScriptDir%\%Aria2ExeName% --conf-path=%A_ScriptDir%\%Aria2Config% --dir=%CurrentConfigPath% --bt-tracker=%BTTracker%, ,hide
Return

Exit:		   ;退出 {{{1
Gosub, CheckKillAria2
ExitApp

CheckKillAria2:			 ; 终止 Aria2 进程 {{{2
Process, Exist, %Aria2ExeName%
If (ErrorLevel != 0)
	Process, Close, %Aria2ExeName%,
Return

SwitchConfig(Number)		; 配置切换函数 {{{2
{
	Global
    Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
	IniWrite, %Number%, Aria2AHK.ini, Config, SelectConfig
	IniRead, SelectConfig, Aria2AHK.ini, Config, SelectConfig
	IniRead, CurrentConfig, Aria2AHK.ini, Config, ConfigName%Number%
	IniRead, CurrentConfigPath, Aria2AHK.ini, Config, ConfigPath%Number%
    Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
	;TrayTip, Aria2AHK, 配置切换为 %CurrentConfig%。, ,
    Return
}

Aria2AddTask(AddTaskNumber, Proxy:=0)     ; 添加任务函数 {{{1
{
	Global
	IniRead, TaskPath, Aria2AHK.ini, Config, ConfigPath%AddTaskNumber%
	IniRead, Aria2RpcUrl, Aria2AHK.ini, Setting, Aria2RpcUrl
    InputBox, DownloadUrl, 添加任务, 新建 HTTP / HTTPS / FTP / SFTP / Magnet 任务:
    If ErrorLevel
        Return
    Else
        If (Proxy !=0)
        {
		    Aria2AddTaskData := "{""jsonrpc"":""2.0"",""id"":""1"",""method"":""aria2.addUri"",""params"":[[""" . DownloadUrl . """],{""dir"":""" . TaskPath . """,""all-proxy"":""" . Aria2Proxy . """}]}"
        } Else {
		    Aria2AddTaskData := "{""jsonrpc"":""2.0"",""id"":""1"",""method"":""aria2.addUri"",""params"":[[""" . DownloadUrl . """],{""dir"":""" . TaskPath . """}]}"
        }
	    HttpPost(Aria2RpcUrl, Aria2AddTaskData)
    Return
}

HttpPost(URL, ByRef In_POST__Out_Data) {
	Static WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("POST", URL, True)
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.Send(In_POST__Out_Data)
	WebRequest.WaitForResponse(-1)
}

; Vim-FileSetting {{{1
; Vim-FileSetting vim: set expandtab foldmethod=marker softtabstop=4 shiftwidth=4:
