using System.Runtime.InteropServices;
using System.Runtime.Versioning;

namespace SyncClipboard.Desktop.ClipboardAva;

[SupportedOSPlatform("macos")]
internal static partial class MacPasteboardHelper
{
    private static readonly nint _selGeneralPasteboard = SelRegisterName("generalPasteboard");
    private static readonly nint _selChangeCount = SelRegisterName("changeCount");
    private static readonly nint _clsNSPasteboard = objc_getClass("NSPasteboard");

    private static int _lastChangeCount = int.MinValue;

    [LibraryImport("/usr/lib/libobjc.A.dylib", StringMarshalling = StringMarshalling.Utf8)]
    private static partial nint objc_getClass(string name);

    [LibraryImport("/usr/lib/libobjc.A.dylib", EntryPoint = "sel_registerName", StringMarshalling = StringMarshalling.Utf8)]
    private static partial nint SelRegisterName(string name);

    [LibraryImport("/usr/lib/libobjc.A.dylib")]
    private static partial nint objc_msgSend(nint receiver, nint selector);

    /// <summary>
    /// Returns true if the pasteboard content has changed since the last call.
    /// On the very first call, returns true (assume changed).
    /// </summary>
    public static bool HasChanged()
    {
        var pasteboard = objc_msgSend(_clsNSPasteboard, _selGeneralPasteboard);
        if (pasteboard == 0)
            return true;

        var currentCount = (int)objc_msgSend(pasteboard, _selChangeCount);

        if (currentCount == _lastChangeCount)
            return false;

        _lastChangeCount = currentCount;
        return true;
    }
}
