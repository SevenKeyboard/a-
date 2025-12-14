#Requires AutoHotkey v1.1.35+
#Include %A_ScriptDir%
#Include .\lib\commandLineToArgvW.ahk
#Include .\lib\getCommandLine.ahk
#Include .\lib\getKnownFolderPath.ahk
#Include .\lib\guiControlGetLogFont.ahk
#Include .\lib\OSVersion.ahk
;==============================================================
; A_ — Extended AutoHotkey A_* built-in variables and helpers
;
; GitHub: https://github.com/SevenKeyboard/a-
; Author: SevenKeyboard Ltd. (2025)
; License: The Unlicense
;==============================================================
class VersionManager_A_
{
    static _ := VersionManager_A_._init()
    _init()    {
        global
        A__VERSION := "1.0.0"
        if (!this._verCheck(GETKNOWNFOLDERPATH_VERSION, "1.0.0"))
            throw exception("getKnownFolderPath version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(GUICONTROLGETLOGFONT_VERSION, "1.0.0"))
            throw exception("guiControlGetLogFont version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(OSVERSION_VERSION, "2.0.0"))
            throw exception("OSVersion version 2.x is required (minimum 2.0.0).")
        return true
    }
    _verCheck(byRef actual, required)    {
        if !isSet(actual)
            return false
        actualMajor     := strSplit(actual, ".",, 2)[1]
        requiredMajor   := strSplit(required, ".",, 2)[1]
        if (actualMajor !== requiredMajor)
            return false
        return verCompare(actual, ">=" required)
    }
}
class A_
{
    /*
    A_.Bitness
    */
    Bitness    {
        get  {
            return (A_PtrSize==8?64:32)
        }
    }

    /*
    A_.Blank
    A_.SpaceFW
    */
    Blank    {
        get  {
            return ""
        }
    }
    SpaceFW    {
        get  {
            return chr(0x3000)
        }
    }

    /*
    A_.FolderID.ProgramFilesX86
    */
    class FolderID
    {
        ProgramFilesX86    {
            get  {
                return getKnownFolderPath("{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}")
            }
        }
    }

    /*
    A_.SM_...
    */
    SM_CXHSCROLL    { ;  width of the arrow bitmap on a horizontal scroll bar, in pixels
        get  {
            return this._sysGet(21)
        }
    }
    SM_CYHSCROLL    { ;  height of a horizontal scroll bar, in pixels.
        get  {
            return this._sysGet(3)
        }
    }
    SM_CXVSCROLL    { ;  width of a vertical scroll bar, in pixels
        get  {
            return this._sysGet(2)
        }
    }
    SM_CYVSCROLL    { ;  height of the arrow bitmap on a vertical scroll bar, in pixels.
        get  {
            return this._sysGet(20)
        }
    }
    _sysGet(N)    {
        sysGet OutputVar, % N
        return OutputVar
    }
    
    ;  A_.SegoeIconographyFont
    SegoeIconographyFont    {
        get  {
            static init:=false, vfont
            if (!init)    {
                init:=true
                switch (OSVersion.WIN)
                {
                    case "WIN_11":      vfont:="Segoe Fluent Icons"
                    case "WIN_10":      vfont:="Segoe MDL2 Assets"
                    default:            vfont:=""
                }
            }
            return vfont
        }
    }

    /*
    A_.Language
    A_.UILanguage
    A_.SystemDefaultLCID
    A_.SystemDefaultLocaleName
    A_.UserDefaultLCID
    A_.UserDefaultLocaleName
    */
    ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-lcidtolocalename
    ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-localenametolcid
    Language    { ;  "0412"
        get  { ;  https://www.autohotkey.com/docs/v1/misc/Languages.htm
            return format("{:04x}",this.SystemDefaultLCID)
        }
    }
    UILanguage    { ;  "0409"
        get  {
            return format("{:04x}",this.UserDefaultLCID)
        }
    }
    SystemDefaultLCID    { ;  0x0412
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getsystemdefaultlcid
            return format("{:#06x}",dllCall("Kernel32\GetSystemDefaultLCID", "UInt"))
        }
    }
    SystemDefaultLocaleName    { ;  "ko-KR"
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getsystemdefaultlocalename
            static LOCALE_NAME_MAX_LENGTH:=85
            varSetCapacity(lpLocaleName, bufferSize:=LOCALE_NAME_MAX_LENGTH*A_PtrSize, 0)
            length:=dllCall("Kernel32\GetSystemDefaultLocaleName", "Ptr",&lpLocaleName, "Int",cchLocaleName:=LOCALE_NAME_MAX_LENGTH, "Int")
            return strGet(&lpLocaleName, length, "UTF-16")
        }
    }
    UserDefaultLCID    { ;  0x0409
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getuserdefaultlcid
            return format("{:#06x}",dllCall("Kernel32\GetUserDefaultLCID", "UInt"))
        }
    }
    UserDefaultLocaleName    { ;  "en-US"
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getuserdefaultlocalename
            static LOCALE_NAME_MAX_LENGTH:=85
            varSetCapacity(lpLocaleName, bufferSize:=LOCALE_NAME_MAX_LENGTH*A_PtrSize, 0)
            length:=dllCall("Kernel32\GetUserDefaultLocaleName", "Ptr",&lpLocaleName, "Int",cchLocaleName:=LOCALE_NAME_MAX_LENGTH, "Int")
            return strGet(&lpLocaleName, length, "UTF-16")
        }
    }
    
    /*
    A_.TickCount
    A_.TickCount32
    A_.TickCount64
    */
    TickCount    {
        get  {
            return (A_Is64bitOS?this.TickCount64:this.TickCount32)
        }
    }
    TickCount32    { ; A_TickCount
        get  {
            return dllCall("Kernel32.dll\GetTickCount", "UInt") ;  0x0 to 0xFFFFFFFF
        }
    }
    TickCount64    {
        get  {
            return dllCall("Kernel32.dll\GetTickCount64", "Int64") & 0x7FFFFFFFFFFFFFFF ;  0x0 to 0x7FFFFFFFFFFFFFFF
        }
    }

    /*
    A_.ScriptHwnd       A_.ScriptID
    A_.ScriptPID
    A_.ScriptClass
    A_.ScriptExe        A_.ScriptProcessName
    */
    ScriptHwnd    {
        get  {
            return format("{:d}",A_ScriptHwnd)
        }
    }
    ScriptID    {
        get  {
            return this.ScriptHwnd
        }
    }
    ScriptPID    {
        get  {
            static currentProcessId
            if (currentProcessId=="")
                currentProcessId:=dllCall("Kernel32.dll\GetCurrentProcessId", "UInt")
            return format("{:d}",currentProcessId)
        }
    }
    ScriptClass    {
        get  {
            static vClass:=""
            if (vClass=="")    {
                prevDHW:=A_DetectHiddenWindows
                detectHiddenWindows On
                winGetClass vClass, % "ahk_id " A_ScriptHwnd
                detectHiddenWindows % prevDHW
            }
            return vClass
        }
    }
    ScriptProcessName    {
        get  {
            static vProcName:=""
            if (vProcName=="")    {
                prevDHW:=A_DetectHiddenWindows
                detectHiddenWindows On
                WinGet vProcName, ProcessName, % "ahk_id " A_ScriptHwnd 
                detectHiddenWindows % prevDHW
            }
            return vProcName
        }
    }
    ScriptExe    {
        get  {
            return  this.ScriptProcessName
        }
    }

    /*
    A_.ScriptPath.FileName
    A_.ScriptPath.Dir
    A_.ScriptPath.Extension
    A_.ScriptPath.NameNoExt
    A_.ScriptPath.Drive
    */
    class ScriptPath
    {
        _splitPath(prm)    {
            static init:=false,vFileName,vDir,vExtension,vNameNoExt,vDrive
            if (!init)    {
                init:=true
                splitPath, A_ScriptFullPath, vFileName, vDir, vExtension, vNameNoExt, vDrive
            }
            return (v%prm%)
        }
        FileName    {
            get  {
                return this._splitPath("FileName")
            }
        }
        Dir    {
            get  {
                return this._splitPath("Dir")
            }
        }
        Extension    {
            get  {
                return this._splitPath("Extension")
            }
        }
        NameNoExt    {
            get  {
                return this._splitPath("NameNoExt")
            }
        }
        Drive    {
            get  {
                return this._splitPath("Drive")
            }
        }
    }

    /*
    A_.CommandLine
    A_.Argv
        A_.Argv[i]
        A_.Argv.i
    A_.Argc
    A_.CommandLineExecutablePath
    A_.CommandLineArguments
    */
    CommandLine    {
        get  {
            static vCommandLine:=getCommandLine()
            return vCommandLine
        }
    }
    Argv[i := 0]    {
        get  {
            static vArgv:=commandLineToArgvW(A_.CommandLine)
            return i ? vArgv[i] : vArgv
        }
    }
    Argc    {
        get  {
            static vArgc:=A_.Argv.length()
            return vArgc
        }
    }
    CommandLineExecutablePath    {
        get  {
            static vCommandLineExecutablePath:=A_.Argv[1]
            return vCommandLineExecutablePath
        }   
    }
    CommandLineArguments    {
        get  {
            static vArguments:=regExReplace(regExReplace(getCommandLine(),"s)^(?:""\Q" A_.CommandLineExecutablePath "\E""|\Q" A_.CommandLineExecutablePath "\E)(.*)","${1}"),"s)^ (.*)","${1}")
            return vArguments
        }
    }

    /*
    A_.GuiHwnd()
    A_.GuiExist()
    A_.GuiTitle()
    */
    GuiHwnd(guiname:="")    {
        gui % (guiname!==""?guiname:A_DefaultGui) ":+LastFoundExist"
        return winExist()
    }
    GuiExist(guiname:="")    {
        return this.GuiHwnd(guiname)
    }
    GuiTitle(guiname:="")    {
        if !(hWnd:=this.GuiHwnd(guiname))
            return
        prevDHW:=A_DetectHiddenWindows
        detectHiddenWindows On
        winGetTitle title, % "ahk_id " hWnd
        detectHiddenWindows % prevDHW
        return title
    }

    /*
    A_.Gui.Font()
    ...
    */
    class Gui
    {
        Font(guiname:="")    { ;  https://www.autohotkey.com/boards/viewtopic.php?t=161#p309740
            return guiControlGetLogFont(guiname) ;  A_.GuiHwnd(guiname)
        }
        FontSize(hWnd, logFont:="")    {
            height:=this._font(hWnd,logFont,"Height")
            if (height!=="")
                return round(-height*72/A_.ScreenDPI)
        }
        FontWeight(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"Weight")
        }
        FontItalic(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"Italic")
        }
        FontStrike(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"StrikeOut")
        }
        FontUnderline(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"Underline")
        }
        FontQuality(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"Quality")
        }
        FontName(hWnd, logFont:="")    {
            return this._font(hWnd,logFont,"FaceName")
        }
        _font(hWnd, logFont, key)    {
            return (hWnd==0 && isObject(logFont))
                ?logFont[key]
                :this.font(hWnd)[key]
        }
        Style(guiname:="")    {
            static GWL_STYLE:=-16
            if (hWnd:=this.GuiHwnd(guiname))
                return dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",hWnd, "Int",GWL_STYLE, (A_PtrSize==8?"Ptr":"Int"))
        }
        ExStyle(guiname:="")    {
            static GWL_EXSTYLE:=-20
            if (hWnd:=this.GuiHwnd(guiname))
                return dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",hWnd, "Int",GWL_EXSTYLE, (A_PtrSize==8?"Ptr":"Int"))
        }
    }

    /*
    A_.ScreenDPI
    A_.DpiScale
    A_.DpiForWindow()
    A_.DpiScaleForWindow()
    A_.ScreenDpiScaleForWIndow()
    */
    ScreenDPI    {
        get  {
            return A_ScreenDPI
        }
    }
    DpiScale    {
        get  {
            return (A_ScreenDPI/96)
        }
    }
    DpiForWindow(winTitle:="")    {
        return this._getDpiForWindow(winTitle)
    }
    DpiScaleForWindow(winTitle:="")    { ;  Relative to a scale of 96 (100%), the current window's aspect ratio.
        return (dpi:=this._getDpiForWindow(winTitle)?dpi/96:0)
    }
    ScreenDpiScaleForWindow(winTitle:="")    { ;  Relative to the main monitor's scale, the aspect ratio of the current window within the secondary monitor.
        return (dpi:=this._getDpiForWindow(winTitle)?dpi/A_ScreenDPI:0)
    }
    _getDpiForWindow(winTitle)    {
        prevDHW:=A_DetectHiddenWindows
        detectHiddenWindows On
        dpi:=(hWnd:=winExist(winTitle))
            ?dllCall("User32.dll\GetDpiForWindow", "Ptr",hWnd, "UInt")
            :0
        detectHiddenWindows % prevDHW
        return dpi
    }

    ;  A_.KeyboardDelay
    KeyboardDelay    {
        get  {
            regRead KeyboardDelay, HKEY_CURRENT_USER\Control Panel\Keyboard, KeyboardDelay
            if (!ErrorLevel)
                return 500
            switch (KeyboardDelay)
            {
                case 0:     return 250
                case 1:     return 500
                case 2:     return 750
                case 3:     return 1000
                default:    return 500
            }
        }
    }

    ;  A_.DoubleClickSpeed
    DoubleClickSpeed    {
        get  {
            regRead DoubleClickSpeed, HKEY_CURRENT_USER\Control Panel\Mouse, DoubleClickSpeed
            return (!ErrorLevel?DoubleClickSpeed:500)
        }
    }
}