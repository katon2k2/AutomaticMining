### size: 960x540 ###
#include "Library\ImageSearch.au3"
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <AutoItConstants.au3>
#include <ComboConstants.au3>
#include <WinAPI.au3>
#include <Color.au3>
#include <Array.au3>

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("AUTO by KATON", 300, 173, 192, 124)
GUICtrlCreateLabel("tên cửa sổ", 56, 19, 53, 17)
$txtNameWindow = GUICtrlCreateInput("", 120, 16, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $WS_BORDER), BitOR($WS_EX_CLIENTEDGE, $WS_EX_STATICEDGE))
GUICtrlCreateLabel("id giả lập", 56, 50, 53, 17)
$cbbDevicesId = GUICtrlCreateCombo("", 120, 47, 121, 21, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL,$WS_BORDER), $WS_EX_STATICEDGE)
$lbTips = GUICtrlCreateLabel("bấm phím ' f ' để bật/tắt tự động đập", 58, 85, 180, 17)
$btnStart = GUICtrlCreateButton("start", 60, 115, 83, 41)
$btnPause = GUICtrlCreateButton("pause", 150, 115, 83, 41)
GUICtrlSetColor($lbTips, 0xFF0000)
GUICtrlSetState($btnPause, $GUI_DISABLE)
GUICtrlSetState($lbTips, $GUI_DISABLE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $title = ""
Global $paddingX
Global $paddingY
Global $deviceId = "emulator-5556"
Global $interrupt = 0
Global $hitAction = 0

Func _GetDevicesId($WorkingDir = @ScriptDir & "\Adb\")
	$cmd = Run($WorkingDir & "adb.exe devices", @ScriptDir, @SW_HIDE, $STDERR_MERGED)
    While 1
        Sleep(50)
        If @error Or Not ProcessExists($cmd) Then ExitLoop
    WEnd
    $listDevicesId = StringSplit(StdoutRead($cmd), @CRLF, 1)
	_ArrayDelete($listDevicesId, 0)
	_ArrayDelete($listDevicesId, 0)
	_ArrayDelete($listDevicesId, UBound($listDevicesId)-1)
	_ArrayDelete($listDevicesId, UBound($listDevicesId)-1)
	For $i=0 To UBound($listDevicesId)-1 Step +1
		$listDevicesId[$i] = StringReplace($listDevicesId[$i], "device", "")
		GUICtrlSetData($cbbDevicesId, $listDevicesId[$i])
	Next
EndFunc

Func _isChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func _TapScreen($deviceId, $x, $y, $WorkingDir = @ScriptDir & "\Adb\")
	Run($WorkingDir & "adb.exe -s "&$deviceId&" shell input tap "&$x&" "&$y, @ScriptDir, @SW_HIDE, $STDERR_MERGED)
EndFunc

Func hit()
	$hitAction = ($hitAction==0) ? 1 : 0
EndFunc

#Region Định nghĩa và gán các Button muốn dùng để ngắt vòng lặp
GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND_BUTTON")
Func _WM_COMMAND_BUTTON($hWnd, $Msg, $wParam, $lParam)
	Switch BitAND($wParam, 0x0000FFFF)
		Case $btnPause
			WinSetOnTop($title, "", $WINDOWS_NOONTOP)
			$interrupt = 1
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc
#EndRegion

#Region Tắt GUI khi vẫn còn đang chạy vòng lặp
GUIRegisterMsg($WM_SYSCOMMAND, "_WM_COMMAND_CLOSEBUTTON")
Func _WM_COMMAND_CLOSEBUTTON($hWnd, $Msg, $wParam, $lParam)
	If BitAND($wParam, 0x0000FFFF) = 0xF060 Then
		WinSetOnTop($title, "", $WINDOWS_NOONTOP)
		Exit
	EndIf
	Return 'GUI_RUNDEFMSG'
EndFunc
#EndRegion

Func _Start()
	_Stop()
	GUICtrlSetState($lbTips, $GUI_ENABLE)
	WinActivate($title)
	WinSetOnTop($title, "", $WINDOWS_ONTOP)
	$interrupt = 0
	$paddingX = (GUICtrlRead($txtNameWindow)=='LDPlayer') ? 0 : 0
	$paddingY = (GUICtrlRead($txtNameWindow)=='LDPlayer') ? -32 : 0
	GUICtrlSetState($txtNameWindow, $GUI_DISABLE)
	GUICtrlSetState($cbbDevicesId, $GUI_DISABLE)
	GUICtrlSetState($btnStart, $GUI_DISABLE)
	GUICtrlSetState($btnPause, $GUI_ENABLE)
	While $interrupt == 0
		$pos = WinGetPos($title)
		$nutLam = _ImageSearch_Area("Img\nutLam.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
		If $nutLam[0] Then
			$banNgay = _ImageSearch_Area("Img\banNgay.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
			If $banNgay[0] Then
				If True = $GUI_CHECKED Then
;~ 					ControlClick($title, "", "", 'left', 1, $banNgay[1] - $pos[0] + $paddingX, $banNgay[2] - $pos[1] + $paddingY)
					_TapScreen($deviceId, $banNgay[1] - $pos[0], $banNgay[2] - $pos[1])
				Else
;~ 					ControlClick($title, "", "", 'left', 1, $nutLam[1] - $pos[0] + $paddingX, $nutLam[2] - $pos[1] + $paddingY)
					_TapScreen($deviceId, $nutLam[1] - $pos[0], $nutLam[2] - $pos[1])
				EndIf
			Else
;~ 				ControlClick($title, "", "", 'left', 1, $nutLam[1] - $pos[0] + $paddingX, $nutLam[2] - $pos[1] + $paddingY)
				_TapScreen($deviceId, $nutLam[1] - $pos[0], $nutLam[2] - $pos[1])
			EndIf
			Sleep(1000)
		ElseIf $hitAction == 1 Then
			_TapScreen($deviceId, 766, 327)
			Sleep(500)
		EndIf
	WEnd
	GUICtrlSetState($txtNameWindow, $GUI_ENABLE)
	GUICtrlSetState($cbbDevicesId, $GUI_ENABLE)
	GUICtrlSetState($btnPause, $GUI_DISABLE)
	GUICtrlSetState($btnStart, $GUI_ENABLE)
	GUICtrlSetState($lbTips, $GUI_DISABLE)
EndFunc

Func _Stop()
	WinSetOnTop($title, "", $WINDOWS_NOONTOP)
	$interrupt = 1
EndFunc

HotKeySet("{HOME}", "_Start")
HotKeySet("{END}", "_Stop")
HotKeySet("f", "hit")

_GetDevicesId()

While 1
	$title = GUICtrlRead($txtNameWindow)
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnStart
			_Start()
	EndSwitch
WEnd