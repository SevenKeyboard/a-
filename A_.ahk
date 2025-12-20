#Requires AutoHotkey v2.0.0+
#Include "%A_ScriptDir%"
#Include ".\lib\commandLineToArgvW.ahk"
#Include ".\lib\getCommandLine.ahk"
#Include ".\lib\getKnownFolderPath.ahk"
#Include ".\lib\guiControlGetLogFont.ahk"
#Include ".\lib\OSVersion.ahk"
;==============================================================
; A_ — Extended AutoHotkey A_* built-in variables and helpers
;
; GitHub: https://github.com/SevenKeyboard/a-
; Author: SevenKeyboard Ltd. (2025)
; License: The Unlicense
;==============================================================
class VersionManager_A_
{
    static _ := this._init()
    static _init()    {
        global
        A__VERSION := "1.0.0"
        if (!this._verCheck(&GETKNOWNFOLDERPATH_VERSION, "1.0.0"))
            throw error("getKnownFolderPath version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(&GUICONTROLGETLOGFONT_VERSION, "1.0.0"))
            throw error("guiControlGetLogFont version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(&OSVERSION_VERSION, "1.0.0"))
            throw error("OSVersion version 2.x is required (minimum 1.0.0).")
        return true
    }
    static _verCheck(&actual, required)    {
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
    static Bitness => (A_PtrSize==8?64:32)

    /*
    A_.Blank
    A_.SpaceFW
    */
    static Blank => ""
    static SpaceFW => chr(0x3000)

    /*
    A_.FolderID.ProgramFilesX86
    */
    class FolderID
    {
       static ProgramFilesX86 => getKnownFolderPath("{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}")
    }

    /*
    A_.SM_...
    */
    SM_CXHSCROLL => sysGet(21)  ;  width of the arrow bitmap on a horizontal scroll bar, in pixels
    SM_CYHSCROLL => sysGet(3)   ;  height of a horizontal scroll bar, in pixels.
    SM_CXVSCROLL => sysGet(2)   ;  width of a vertical scroll bar, in pixels
    SM_CYVSCROLL => sysGet(20)  ;  height of the arrow bitmap on a vertical scroll bar, in pixels.

    ;  A_.SegoeIconographyFont
    static SegoeIconographyFont    {
        get  {
            static init:=false, vfont
            if (!init)    {
                init:=true
                switch this.OSVersion.Win
                {
                    case 11:        vfont:="Segoe Fluent Icons"
                    case 10:        vfont:="Segoe MDL2 Assets"
                    default:        vfont:=""
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
    static Language    { ;  "0412"
        get  { ;  https://www.autohotkey.com/docs/v1/misc/Languages.htm
            return format("{:04x}",this.SystemDefaultLCID)
        }
    }
    static UILanguage    { ;  "0409"
        get  {
            return format("{:04x}",this.UserDefaultLCID)
        }
    }
    static SystemDefaultLCID    { ;  0x0412
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getsystemdefaultlcid
            return format("{:#06x}",dllCall("Kernel32\GetSystemDefaultLCID", "UInt"))
        }
    }
    static SystemDefaultLocaleName    { ;  "ko-KR"
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getsystemdefaultlocalename
            static LOCALE_NAME_MAX_LENGTH:=85
            lpLocaleName:=buffer(bufferSize:=LOCALE_NAME_MAX_LENGTH*2, 0)
            length:=dllCall("Kernel32\GetSystemDefaultLocaleName", "Ptr",lpLocaleName.Ptr, "Int",cchLocaleName:=LOCALE_NAME_MAX_LENGTH, "Int")
            return strGet(lpLocaleName.Ptr, length, "UTF-16")
        }
    }
    static UserDefaultLCID    { ;  0x0409
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getuserdefaultlcid
            return format("{:#06x}",dllCall("Kernel32\GetUserDefaultLCID", "UInt"))
        }
    }
    static UserDefaultLocaleName    { ;  "en-US"
        get  { ;  https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getuserdefaultlocalename
            static LOCALE_NAME_MAX_LENGTH:=85
            lpLocaleName:=buffer(bufferSize:=LOCALE_NAME_MAX_LENGTH*2, 0)
            length:=dllCall("Kernel32\GetUserDefaultLocaleName", "Ptr",lpLocaleName.Ptr, "Int",cchLocaleName:=LOCALE_NAME_MAX_LENGTH, "Int")
            return strGet(lpLocaleName.Ptr, length, "UTF-16")
        }
    }

    /*
    A_.TickCount
    A_.TickCount32
    A_.TickCount64
    */
    static TickCount    => (A_Is64bitOS?this.TickCount64:this.TickCount32)
    static TickCount32  => dllCall("Kernel32.dll\GetTickCount", "UInt") ;  0x0 to 0xFFFFFFFF
    static TickCount64  => dllCall("Kernel32.dll\GetTickCount64", "Int64") & 0x7FFFFFFFFFFFFFFF ;  0x0 to 0x7FFFFFFFFFFFFFFF

    /*
    A_.ScriptHwnd       A_.ScriptID
    A_.ScriptPID
    A_.ScriptClass
    A_.ScriptExe        A_.ScriptProcessName
    */
    static ScriptHwnd  => format("{:d}",A_ScriptHwnd)
    static ScriptID => this.ScriptHwnd
    static ScriptPID    {
        get  {
            static currentProcessId:=dllCall("Kernel32.dll\GetCurrentProcessId", "UInt")
            return format("{:d}",currentProcessId)
        }
    }
    static ScriptClass    {
        get  {
            static vClass:=""
            if (vClass=="")    {
                prevDHW:=detectHiddenWindows(true)
                vClass:=winGetClass("ahk_id " A_ScriptHwnd)
                detectHiddenWindows(prevDHW)
            }
            return vClass
        }
    }
    static ScriptProcessName    {
        get  {
            static vProcName:=""
            if (vProcName=="")    {
                prevDHW:=detectHiddenWindows(true)
                vProcName:=winGetProcessName("ahk_id " A_ScriptHwnd)
                detectHiddenWindows(prevDHW)
            }
            return vProcName
        }
    }
    static ScriptExe => this.ScriptProcessName

    /*
    A_.ScriptPath.FileName
    A_.ScriptPath.Dir
    A_.ScriptPath.Extension
    A_.ScriptPath.NameNoExt
    A_.ScriptPath.Drive
    */
    class ScriptPath
    {
        static _splitPath(prm)    {
            static init:=false,vFileName,vDir,vExtension,vNameNoExt,vDrive
            if (!init)    {
                init:=true
                splitPath(A_ScriptFullPath, &vFileName, &vDir, &vExtension, &vNameNoExt, &vDrive)
            }
            return (v%prm%)
        }
        static FileName => this._splitPath("FileName")
        static Dir => this._splitPath("Dir")
        static Extension => this._splitPath("Extension")
        static NameNoExt => this._splitPath("NameNoExt")
        static Drive => this._splitPath("Drive")
    }
    
    /*
    A_.CommandLine
    A_.Argv
        A_.Argv[i]
    A_.Argc
    A_.CommandLineExecutablePath
    A_.CommandLineArguments
    */
    static CommandLine    {
        get  {
            static vCommandLine:=getCommandLine()
            return vCommandLine
        }
    }
    static Argv    {
        get  {
            static vArgv:=commandLineToArgvW(A_.CommandLine)
            return vArgv
        }
    }
    static Argc    {
        get  {
            static vArgc:=A_.Argv.Length
            return vArgc
        }
    }
    static CommandLineExecutablePath    {
        get  {
            static vCommandLineExecutablePath:=A_.Argv[1]
            return vCommandLineExecutablePath
        }   
    }
    static CommandLineArguments    {
        get  {
            static vArguments:=regExReplace(regExReplace(getCommandLine(),"s)^(?:`"\Q" A_.CommandLineExecutablePath "\E`"|\Q" A_.CommandLineExecutablePath "\E)(.*)","${1}"),"s)^ (.*)","${1}")
            return vArguments
        }
    }

    /*
    A_.Gui.Font()
    ...
    */
    class Gui
    {
        static Font(guiObj)    { ;  https://www.autohotkey.com/boards/viewtopic.php?t=161#p309740
            return guiControlGetLogFont(guiObj)
        }
        static FontSize(guiObj, logFont:="")    {
            height:=this._font(guiObj,logFont,"Height")
            if (height!=="")
                return round(-height*72/A_.ScreenDPI)
        }
        static FontWeight(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"Weight")
        }
        static FontItalic(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"Italic")
        }
        static FontStrike(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"StrikeOut")
        }
        static FontUnderline(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"Underline")
        }
        static FontQuality(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"Quality")
        }
        static FontName(guiObj, logFont:="")    {
            return this._font(guiObj,logFont,"FaceName")
        }
        static _font(guiObj, logFont, propName)    {
            return (guiObj==0 && isObject(logFont))
                ?logFont.%propName%
                :this.Font(guiObj).%propName%
        }
        static Style(guiObj)    {
            static GWL_STYLE:=-16
            return dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",guiObj.Hwnd, "Int",GWL_STYLE, (A_PtrSize==8?"Ptr":"Int"))
        }
        static ExStyle(guiObj)    {
            static GWL_EXSTYLE:=-20
            return dllCall("User32.dll\GetWindowLong" (A_PtrSize==8?"Ptr":""), "Ptr",guiObj.Hwnd, "Int",GWL_EXSTYLE, (A_PtrSize==8?"Ptr":"Int"))
        }
    }

    /*
    A_.ScreenDPI
    A_.DpiScale
    A_.DpiForWindow()
    A_.DpiScaleForWindow()
    A_.ScreenDpiScaleForWIndow()
    */
    static ScreenDPI => A_ScreenDPI
    static DpiScale => (A_ScreenDPI/96)
    static DpiForWindow(winTitle:="")    {
        return this._getDpiForWindow(winTitle)
    }
    static DpiScaleForWindow(winTitle:="")    { ;  Relative to a scale of 96 (100%), the current window's aspect ratio.
        return (dpi:=this._getDpiForWindow(winTitle)?dpi/96:0)
    }
    static ScreenDpiScaleForWindow(winTitle:="")    { ;  Relative to the main monitor's scale, the aspect ratio of the current window within the secondary monitor.
        return (dpi:=this._getDpiForWindow(winTitle)?dpi/A_ScreenDPI:0)
    }
    static _getDpiForWindow(winTitle)    {
        prevDHW:=detectHiddenWindows(true)
        dpi:=(hWnd:=winExist(winTitle))
            ?dllCall("User32.dll\GetDpiForWindow", "Ptr",hWnd, "UInt")
            :0
        detectHiddenWindows(prevDHW)
        return dpi
    }

    ; A_.KeyboardDelay
    static KeyboardDelay    {
        get  {
            switch (regRead("HKEY_CURRENT_USER\Control Panel\Keyboard", "KeyboardDelay", ""))
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
    static DoubleClickSpeed => regRead("HKEY_CURRENT_USER\Control Panel\Mouse", "DoubleClickSpeed", 500)
}