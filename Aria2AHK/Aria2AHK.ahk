#Persistent
#SingleInstance force

Setworkingdir, %A_ScriptDir%

; ��ȡ Aria2AHK.ini ������ {{{1
IniRead, Aria2ExeName, Aria2AHK.ini, Setting, Aria2ExeName
IniRead, Aria2Config, Aria2AHK.ini, Setting, Aria2Config
IniRead, FrontendFolder, Aria2AHK.ini, Setting, FrontendFolder
IniRead, FrontendHtml, Aria2AHK.ini, Setting, FrontendHtml
IniRead, Aria2Proxy, Aria2AHK.ini, Setting, Aria2Proxy
IniRead, BTTrakcersList, Aria2AHK.ini, Setting, BTTrakcersList
IniRead, BTTracker, Aria2AHK.ini, Config, bt-tracker

;���������ļ���Ϣ {{{2
ConfigNumber = 0
Loop {
	ConfigNumber := ConfigNumber + 1
	IniRead, ConfigName%ConfigNumber%, Aria2AHK.ini, Config, ConfigName%ConfigNumber%
	IniRead, ConfigPath%ConfigNumber%, Aria2AHK.ini, Config, ConfigPath%ConfigNumber%
} Until ConfigNumber >= 3

; �ж�Ĭ��������Ϣ {{{2
IniRead, SelectConfig, Aria2AHK.ini, Config, SelectConfig
If SelectConfig between 1 and 3
{
	IniRead, CurrentConfig, Aria2AHK.ini, Config, ConfigName%SelectConfig%
	IniRead, CurrentConfigPath, Aria2AHK.ini, Config, ConfigPath%SelectConfig%
} Else {
	MsgBox, ���ô��󣬰� Esc ���˳�����
ExitApp
}

; ���̲˵����� {{{1
Menu, Tray, NoStandard
Menu, Tray, Tip, Aria2AHK
Menu, Tray, Icon, Aria2AHK.ico, 1, 1
Menu, Tray, Add, �� Web ǰ��, Frontend
Menu, Tray, Add  ; �ָ���.
If (ConfigName1 !="")
{
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName1%, Aria2AddTask10
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName1%������, Aria2AddTask11
	Menu, Aria2ProfileMenu, Add, %ConfigName1%, CurrentConfig1
}
If (ConfigName2 !="")
{
    Menu, Aria2AddTaskMenu, Add  ; �ָ���.
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName2%, Aria2AddTask20
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName2%������, Aria2AddTask21
	Menu, Aria2ProfileMenu, Add, %ConfigName2%, CurrentConfig2
}
If (ConfigName3 !="")
{
    Menu, Aria2AddTaskMenu, Add  ; �ָ���.
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName3%, Aria2AddTask30
	Menu, Aria2AddTaskMenu, Add, ������ %ConfigName3%������, Aria2AddTask31
	Menu, Aria2ProfileMenu, Add, %ConfigName3%, CurrentConfig3
}
Menu, Aria2AddTaskMenu, Add  ; �ָ���.
Menu, Aria2AddTaskMenu, Add, ���������%Aria2Proxy%, NReturn
Menu, Tray, Add, �����������, :Aria2AddTaskMenu
Menu, Tray, Add, Ĭ������·��, :Aria2ProfileMenu
Menu, Tray, Add, ���� BT-Trackers, UpdateBTTracker
Menu, Tray, Add, ���� Aria2, ReStartAria2
Menu, Tray, Add  ; �ָ���.
Menu, Tray, Add, �˳�, Exit
Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
Goto, ReStartAria2
Return

Frontend:	 ;����ҳǰ�� {{{1
Run, %A_ScriptDir%\%FrontendFolder%\%FrontendHtml%
Return

;����������� {{{1
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

;�л�Ĭ������·�� {{{1
CurrentConfig1:			 ;�л�������1 {{{2
SwitchConfig(1)
Reload
Return

CurrentConfig2:			 ;�л�������2 {{{2
SwitchConfig(2)
Reload
Return

CurrentConfig3:			 ;�л�������3 {{{2
SwitchConfig(3)
Reload
Return

;���� BT Tracker {{{1
UpdateBTTracker:
UrlDownloadToFile, %BTTrakcersList%, %A_ScriptDir%\TrackersLists.list
FileReadLine, Trackers, %A_ScriptDir%\TrackersLists.list, 1
IniWrite, %Trackers%, Aria2AHK.ini, Config, bt-tracker
FileDelete, %A_ScriptDir%\TrackersLists.list
Reload

ReStartAria2:   ;���� Aria2 {{{1
Gosub, CheckKillAria2
Run, %A_ScriptDir%\%Aria2ExeName% --conf-path=%A_ScriptDir%\%Aria2Config% --dir=%CurrentConfigPath% --bt-tracker=%BTTracker%, ,hide
Return

Exit:		   ;�˳� {{{1
Gosub, CheckKillAria2
ExitApp

CheckKillAria2:			 ; ��ֹ Aria2 ���� {{{2
Process, Exist, %Aria2ExeName%
If (ErrorLevel != 0)
	Process, Close, %Aria2ExeName%,
Return

SwitchConfig(Number)		; �����л����� {{{2
{
	Global
    Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
	IniWrite, %Number%, Aria2AHK.ini, Config, SelectConfig
	IniRead, SelectConfig, Aria2AHK.ini, Config, SelectConfig
	IniRead, CurrentConfig, Aria2AHK.ini, Config, ConfigName%Number%
	IniRead, CurrentConfigPath, Aria2AHK.ini, Config, ConfigPath%Number%
    Menu, Aria2ProfileMenu, ToggleCheck, %CurrentConfig%
	;TrayTip, Aria2AHK, �����л�Ϊ %CurrentConfig%��, ,
    Return
}

Aria2AddTask(AddTaskNumber, Proxy:=0)     ; ��������� {{{1
{
	Global
	IniRead, TaskPath, Aria2AHK.ini, Config, ConfigPath%AddTaskNumber%
	IniRead, Aria2RpcUrl, Aria2AHK.ini, Setting, Aria2RpcUrl
    InputBox, DownloadUrl, �������, �½� HTTP / HTTPS / FTP / SFTP / Magnet ����:
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
