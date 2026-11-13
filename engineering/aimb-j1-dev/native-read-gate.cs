using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Security;
using Microsoft.Win32.SafeHandles;

// Windows-only, read-only fixture gate. Paths are opened relative to a pinned
// root handle with OBJ_DONT_REPARSE, then checked again through the open handle.
public static class NativeReadGate
{
    const uint FILE_READ_DATA=0x0001, FILE_LIST_DIRECTORY=0x0001,
        FILE_READ_EA=0x0008, FILE_READ_ATTRIBUTES=0x0080, READ_CONTROL=0x00020000,
        SYNCHRONIZE=0x00100000, FILE_SHARE_READ=0x1, OPEN_EXISTING=3,
        FILE_FLAG_BACKUP_SEMANTICS=0x02000000, FILE_FLAG_OPEN_REPARSE_POINT=0x00200000,
        FILE_ATTRIBUTE_DIRECTORY=0x10, FILE_ATTRIBUTE_REPARSE_POINT=0x400,
        FILE_OPEN=1, FILE_SYNCHRONOUS_IO_NONALERT=0x20, FILE_NON_DIRECTORY_FILE=0x40,
        FILE_DIRECTORY_FILE=0x1, FILE_OPEN_REPARSE_POINT=0x00200000, OBJ_CASE_INSENSITIVE=0x40,
        OBJ_DONT_REPARSE=0x1000, SE_FILE_OBJECT=1, DACL_SECURITY_INFORMATION=4,
        TOKEN_QUERY=0x8, TOKEN_DUPLICATE=0x2, SecurityImpersonation=2,
        TokenImpersonation=2, FileAttributeTagInfo=9, FileStandardInfo=1,
        TokenElevation=20;
    const uint FILE_WRITE_DATA=0x2, FILE_APPEND_DATA=0x4, FILE_WRITE_EA=0x10,
        FILE_WRITE_ATTRIBUTES=0x100, DELETE=0x00010000;
    const uint FILE_DELETE_CHILD=0x40;
    static readonly uint[] WriteRights=new uint[]{FILE_WRITE_DATA,FILE_APPEND_DATA,FILE_WRITE_EA,FILE_WRITE_ATTRIBUTES,DELETE,FILE_DELETE_CHILD};

    [StructLayout(LayoutKind.Sequential)] struct UNICODE_STRING { public ushort Length, MaximumLength; public IntPtr Buffer; }
    [StructLayout(LayoutKind.Sequential)] struct OBJECT_ATTRIBUTES { public int Length; public IntPtr RootDirectory, ObjectName; public uint Attributes; public IntPtr SecurityDescriptor, SecurityQualityOfService; }
    [StructLayout(LayoutKind.Sequential)] struct IO_STATUS_BLOCK { public IntPtr StatusOrPointer; public UIntPtr Information; }
    [StructLayout(LayoutKind.Sequential)] struct ATTR_TAG { public uint FileAttributes, ReparseTag; }
    [StructLayout(LayoutKind.Sequential, Pack=8)] struct STANDARD_INFO { public long AllocationSize, EndOfFile; public uint NumberOfLinks; [MarshalAs(UnmanagedType.U1)] public bool DeletePending; [MarshalAs(UnmanagedType.U1)] public bool Directory; }
    [StructLayout(LayoutKind.Sequential)] struct GENERIC_MAPPING { public uint GenericRead, GenericWrite, GenericExecute, GenericAll; }
    [StructLayout(LayoutKind.Sequential)] struct SID_AND_ATTRIBUTES { public IntPtr Sid; public uint Attributes; }

    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern SafeFileHandle CreateFileW(string name,uint access,uint share,IntPtr sec,uint creation,uint flags,IntPtr template);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetFileInformationByHandleEx(SafeFileHandle h,int cls,out ATTR_TAG info,uint size);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetFileInformationByHandleEx(SafeFileHandle h,int cls,out STANDARD_INFO info,uint size);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern uint GetFinalPathNameByHandleW(SafeFileHandle h,System.Text.StringBuilder path,uint size,uint flags);
    [DllImport("ntdll.dll")] static extern int NtCreateFile(out IntPtr h,uint access,ref OBJECT_ATTRIBUTES oa,out IO_STATUS_BLOCK iosb,IntPtr allocation,uint attrs,uint share,uint disposition,uint options,IntPtr ea,uint eaLen);
    [DllImport("ntdll.dll")] static extern int NtQueryDirectoryFile(SafeFileHandle h,IntPtr ev,IntPtr apc,IntPtr apcContext,out IO_STATUS_BLOCK iosb,byte[] info,uint length,int infoClass,[MarshalAs(UnmanagedType.U1)]bool returnSingle,IntPtr fileName,[MarshalAs(UnmanagedType.U1)]bool restartScan);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool ReadFile(SafeFileHandle h,byte[] buffer,uint count,out uint read,IntPtr overlapped);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr process,uint access,out IntPtr token);
    [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool DuplicateTokenEx(IntPtr existing,uint access,IntPtr attrs,int level,int type,out IntPtr token);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool GetTokenInformation(IntPtr token,int cls,IntPtr info,int len,out int retLen);
    [DllImport("advapi32.dll", SetLastError=true)] static extern uint GetSecurityInfo(SafeFileHandle h,int objectType,uint info,out IntPtr owner,out IntPtr group,out IntPtr dacl,out IntPtr sacl,out IntPtr sd);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool AccessCheck(IntPtr sd,IntPtr token,uint desired,ref GENERIC_MAPPING mapping,IntPtr privileges,ref uint privilegeLen,out uint granted,out bool accessStatus);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool MakeAbsoluteSD(IntPtr selfRelative,IntPtr absolute,ref uint absoluteSize,IntPtr dacl,ref uint daclSize,IntPtr sacl,ref uint saclSize,IntPtr owner,ref uint ownerSize,IntPtr group,ref uint groupSize);
    [DllImport("kernel32.dll")] static extern IntPtr LocalFree(IntPtr p);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);

    static void Need(bool ok,string code) { if(!ok) throw new SecurityException(code); }
    static string FinalPath(SafeFileHandle h) { var b=new System.Text.StringBuilder(32768); uint n=GetFinalPathNameByHandleW(h,b,(uint)b.Capacity,0); Need(n>0 && n<b.Capacity,"FINAL_PATH_FAILED"); return b.ToString().TrimEnd('\\'); }
    static ATTR_TAG Attr(SafeFileHandle h) { ATTR_TAG x; Need(GetFileInformationByHandleEx(h,(int)FileAttributeTagInfo,out x,(uint)Marshal.SizeOf(typeof(ATTR_TAG))),"HANDLE_ATTR_FAILED"); return x; }
    static STANDARD_INFO Standard(SafeFileHandle h) { STANDARD_INFO x; Need(GetFileInformationByHandleEx(h,(int)FileStandardInfo,out x,(uint)Marshal.SizeOf(typeof(STANDARD_INFO))),"HANDLE_STANDARD_FAILED"); return x; }

    public static bool IsElevated() {
        IntPtr t; Need(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,out t),"TOKEN_OPEN_FAILED");
        try { IntPtr p=Marshal.AllocHGlobal(4); try { int n; Need(GetTokenInformation(t,(int)TokenElevation,p,4,out n),"TOKEN_ELEVATION_FAILED"); return Marshal.ReadInt32(p)!=0; } finally { Marshal.FreeHGlobal(p); } }
        finally { CloseHandle(t); }
    }
    static IntPtr ReadOnlyToken() {
        IntPtr t,dup; Need(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY|TOKEN_DUPLICATE,out t),"TOKEN_OPEN_FAILED");
        try { Need(DuplicateTokenEx(t,TOKEN_QUERY,IntPtr.Zero,(int)SecurityImpersonation,(int)TokenImpersonation,out dup),"TOKEN_DUPLICATE_FAILED"); return dup; }
        finally { CloseHandle(t); }
    }
    static void DenyWriteAcl(SafeFileHandle h) {
        IntPtr owner,group,dacl,sacl,sd; uint e=GetSecurityInfo(h,(int)SE_FILE_OBJECT,1|2|DACL_SECURITY_INFORMATION,out owner,out group,out dacl,out sacl,out sd);
        Need(e==0,"ACL_READ_FAILED"); IntPtr token=ReadOnlyToken();
        try {
            var map=new GENERIC_MAPPING { GenericRead=0x00120089, GenericWrite=0x00120116, GenericExecute=0x001200A0, GenericAll=0x001F01FF };
            IntPtr abs=IntPtr.Zero,ad=IntPtr.Zero,asacl=IntPtr.Zero,ao=IntPtr.Zero,ag=IntPtr.Zero,priv=IntPtr.Zero;
            try {
                uint al=0,dl=0,sl=0,ol=0,gl=0; MakeAbsoluteSD(sd,IntPtr.Zero,ref al,IntPtr.Zero,ref dl,IntPtr.Zero,ref sl,IntPtr.Zero,ref ol,IntPtr.Zero,ref gl);
                abs=Marshal.AllocHGlobal((int)al); ad=dl>0?Marshal.AllocHGlobal((int)dl):IntPtr.Zero; asacl=sl>0?Marshal.AllocHGlobal((int)sl):IntPtr.Zero; ao=ol>0?Marshal.AllocHGlobal((int)ol):IntPtr.Zero; ag=gl>0?Marshal.AllocHGlobal((int)gl):IntPtr.Zero;
                Need(MakeAbsoluteSD(sd,abs,ref al,ad,ref dl,asacl,ref sl,ao,ref ol,ag,ref gl),"ACL_ABSOLUTE_SD_FAILED_"+Marshal.GetLastWin32Error());
                priv=Marshal.AllocHGlobal(1024); foreach(uint right in WriteRights){uint plen=1024,granted;bool allowed;if(!AccessCheck(abs,token,right,ref map,priv,ref plen,out granted,out allowed))throw new SecurityException("ACL_ACCESSCHECK_FAILED_"+Marshal.GetLastWin32Error());Need(!allowed,"ACL_WRITE_ALLOWED_0x"+right.ToString("X"));}
            } finally { if(priv!=IntPtr.Zero)Marshal.FreeHGlobal(priv); if(abs!=IntPtr.Zero)Marshal.FreeHGlobal(abs); if(ad!=IntPtr.Zero)Marshal.FreeHGlobal(ad); if(asacl!=IntPtr.Zero)Marshal.FreeHGlobal(asacl); if(ao!=IntPtr.Zero)Marshal.FreeHGlobal(ao); if(ag!=IntPtr.Zero)Marshal.FreeHGlobal(ag); }
        } finally { CloseHandle(token); LocalFree(sd); }
    }
    static SafeFileHandle OpenDirectoryChild(SafeFileHandle parent,string segment) {
        Need(!String.IsNullOrWhiteSpace(segment)&&segment!="."&&segment!=".."&&!segment.Contains(":"),"UNSAFE_PATH");
        IntPtr name=Marshal.StringToHGlobalUni(segment),usMem=Marshal.AllocHGlobal(Marshal.SizeOf(typeof(UNICODE_STRING)));
        try {
            Marshal.StructureToPtr(new UNICODE_STRING { Length=(ushort)(segment.Length*2),MaximumLength=(ushort)(segment.Length*2+2),Buffer=name },usMem,false);
            var oa=new OBJECT_ATTRIBUTES { Length=Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES)),RootDirectory=parent.DangerousGetHandle(),ObjectName=usMem,Attributes=OBJ_CASE_INSENSITIVE|OBJ_DONT_REPARSE };
            IO_STATUS_BLOCK iosb;IntPtr raw;int status=NtCreateFile(out raw,FILE_LIST_DIRECTORY|FILE_READ_ATTRIBUTES|READ_CONTROL|SYNCHRONIZE,ref oa,out iosb,IntPtr.Zero,0,FILE_SHARE_READ,FILE_OPEN,FILE_DIRECTORY_FILE|FILE_SYNCHRONOUS_IO_NONALERT|FILE_OPEN_REPARSE_POINT,IntPtr.Zero,0);
            Need(status>=0,"ROOT_COMPONENT_OPEN_DENIED_0x"+status.ToString("X8"));var h=new SafeFileHandle(raw,true);
            try { var a=Attr(h);var s=Standard(h);Need((a.FileAttributes&FILE_ATTRIBUTE_REPARSE_POINT)==0,"ROOT_COMPONENT_REPARSE_DENIED");Need(s.Directory,"ROOT_COMPONENT_NOT_DIRECTORY");return h; }
            catch {h.Dispose();throw;}
        } finally {Marshal.FreeHGlobal(name);Marshal.FreeHGlobal(usMem);}
    }
    static SafeFileHandle OpenAbsoluteDirectory(string full) {
        string volume=Path.GetPathRoot(full);Need(volume!=null&&volume.Length==3&&volume[1]==':',"LOCAL_DRIVE_ONLY");
        var current=CreateFileW(volume,FILE_LIST_DIRECTORY|FILE_READ_ATTRIBUTES|READ_CONTROL|SYNCHRONIZE,FILE_SHARE_READ,IntPtr.Zero,OPEN_EXISTING,FILE_FLAG_BACKUP_SEMANTICS|FILE_FLAG_OPEN_REPARSE_POINT,IntPtr.Zero);
        Need(!current.IsInvalid,"VOLUME_ROOT_OPEN_FAILED");
        try { var va=Attr(current);var vs=Standard(current);Need((va.FileAttributes&FILE_ATTRIBUTE_REPARSE_POINT)==0&&vs.Directory,"VOLUME_ROOT_UNSAFE");
            string rest=full.Substring(volume.Length).Trim('\\');if(rest.Length>0)foreach(string segment in rest.Split('\\')){var next=OpenDirectoryChild(current,segment);current.Dispose();current=next;}
            var rootAttr=Attr(current);var rootStd=Standard(current);Need((rootAttr.FileAttributes&FILE_ATTRIBUTE_REPARSE_POINT)==0&&rootStd.Directory,"ROOT_REPARSE_DENIED");return current;
        } catch {current.Dispose();throw;}
    }
    static SafeFileHandle OpenRootChecked(string full,string allowedBase) {
        Need(!IsElevated(),"ELEVATED_PROCESS_DENIED");full=Path.GetFullPath(full).TrimEnd('\\');allowedBase=Path.GetFullPath(allowedBase).TrimEnd('\\');
        Need(full.StartsWith(allowedBase+"\\",StringComparison.OrdinalIgnoreCase),"ROOT_OUTSIDE_ALLOWLIST");
        var h=OpenAbsoluteDirectory(full);try{string final=FinalPath(h).Replace("\\\\?\\","").TrimEnd('\\');Need(String.Equals(final,full,StringComparison.OrdinalIgnoreCase),"ROOT_FINAL_PATH_MISMATCH");DenyWriteAcl(h);return h;}catch{h.Dispose();throw;}
    }
    public static SafeFileHandle OpenRoot(string path) {
        string full=Path.GetFullPath(path).TrimEnd('\\');string basePath=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),"AI_Machine_Bridge_DEV_FIXTURE");
        Need(String.Equals(Path.GetDirectoryName(full),basePath,StringComparison.OrdinalIgnoreCase),"FIXTURE_PARENT_NOT_ALLOWLISTED");
        Need(System.Text.RegularExpressions.Regex.IsMatch(Path.GetFileName(full),"^fixture-[0-9a-f]{32}$",System.Text.RegularExpressions.RegexOptions.IgnoreCase),"FIXTURE_NAME_INVALID");
        return OpenRootChecked(full,basePath);
    }
    internal static SafeFileHandle OpenRootForTest(string path,string allowedBase) { return OpenRootChecked(path,allowedBase); }
    public static string[] ListFiles(SafeFileHandle root,int maxEntries) {
        Need(maxEntries>0&&maxEntries<=10101,"LIST_LIMIT_INVALID");var names=new System.Collections.Generic.List<string>();bool restart=true;const int STATUS_NO_MORE_FILES=unchecked((int)0x80000006);
        while(names.Count<maxEntries){byte[] buffer=new byte[65536];IO_STATUS_BLOCK iosb;int status=NtQueryDirectoryFile(root,IntPtr.Zero,IntPtr.Zero,IntPtr.Zero,out iosb,buffer,(uint)buffer.Length,1,false,IntPtr.Zero,restart);restart=false;if(status==STATUS_NO_MORE_FILES)break;Need(status>=0,"DIRECTORY_ENUMERATION_FAILED_0x"+status.ToString("X8"));
            int offset=0;while(offset<buffer.Length){uint next=BitConverter.ToUInt32(buffer,offset);uint attrs=BitConverter.ToUInt32(buffer,offset+56);uint nameLen=BitConverter.ToUInt32(buffer,offset+60);Need(nameLen%2==0&&nameLen<=buffer.Length-offset-64,"DIRECTORY_ENTRY_INVALID");string name=System.Text.Encoding.Unicode.GetString(buffer,offset+64,(int)nameLen);if(name!="."&&name!=".."&&(attrs&FILE_ATTRIBUTE_DIRECTORY)==0)names.Add(name);if(names.Count>=maxEntries||next==0)break;Need(next<=buffer.Length-offset,"DIRECTORY_ENTRY_OFFSET_INVALID");offset+=(int)next;}
        }
        return names.ToArray();
    }
    static string Relative(string rel) {
        Need(!String.IsNullOrWhiteSpace(rel) && rel.Length<=240 && !Path.IsPathRooted(rel) && !rel.Contains(":") && !rel.Contains("\\"),"UNSAFE_PATH");
        string[] parts=rel.Split('/'); foreach(var p in parts) Need(p.Length>0&&p!="."&&p!=".."&&!p.Equals(".git",StringComparison.OrdinalIgnoreCase),"UNSAFE_PATH"); return String.Join("\\",parts);
    }
    static SafeFileHandle OpenRelative(SafeFileHandle root,string relative) {
        string rel=Relative(relative); IntPtr name=Marshal.StringToHGlobalUni(rel), usMem=Marshal.AllocHGlobal(Marshal.SizeOf(typeof(UNICODE_STRING)));
        try {
            var us=new UNICODE_STRING { Length=(ushort)(rel.Length*2), MaximumLength=(ushort)(rel.Length*2+2), Buffer=name }; Marshal.StructureToPtr(us,usMem,false);
            var oa=new OBJECT_ATTRIBUTES { Length=Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES)), RootDirectory=root.DangerousGetHandle(), ObjectName=usMem, Attributes=OBJ_CASE_INSENSITIVE|OBJ_DONT_REPARSE };
            IO_STATUS_BLOCK iosb; IntPtr raw; int status=NtCreateFile(out raw,FILE_READ_DATA|FILE_READ_EA|FILE_READ_ATTRIBUTES|READ_CONTROL|SYNCHRONIZE,ref oa,out iosb,IntPtr.Zero,0,FILE_SHARE_READ,FILE_OPEN,FILE_SYNCHRONOUS_IO_NONALERT|FILE_NON_DIRECTORY_FILE|FILE_OPEN_REPARSE_POINT,IntPtr.Zero,0);
            Need(status>=0,"NATIVE_OPEN_DENIED_0x"+status.ToString("X8")); var h=new SafeFileHandle(raw,true); try { var a=Attr(h); var s=Standard(h);
            Need((a.FileAttributes&FILE_ATTRIBUTE_REPARSE_POINT)==0,"LEAF_REPARSE_DENIED"); Need(!s.Directory,"NOT_REGULAR_FILE"); Need(!s.DeletePending,"DELETE_PENDING"); Need(s.NumberOfLinks==1,"HARDLINK_DENIED");
            string rootPath=FinalPath(root), final=FinalPath(h); Need(final.StartsWith(rootPath+"\\",StringComparison.OrdinalIgnoreCase),"HANDLE_OUTSIDE_ROOT"); DenyWriteAcl(h); return h; } catch { h.Dispose(); throw; }
        } finally { Marshal.FreeHGlobal(name); Marshal.FreeHGlobal(usMem); }
    }
    public static byte[] Read(SafeFileHandle root,string relative,int maxBytes) {
        using(var h=OpenRelative(root,relative)) {
            var s=Standard(h); Need(s.EndOfFile>=0&&s.EndOfFile<=maxBytes,"FILE_SIZE_LIMIT"); byte[] b=new byte[(int)s.EndOfFile]; uint total=0;
            while(total<b.Length){ uint n; Need(ReadFile(h,b,(uint)b.Length-total,out n,IntPtr.Zero),"READ_FAILED"); Need(n>0,"SHORT_READ"); total+=n; }
            var after=Standard(h); Need(after.EndOfFile==b.Length&&after.NumberOfLinks==1,"FILE_CHANGED_DURING_READ"); return b;
        }
    }
    public static int RepeatRead(SafeFileHandle root,string relative,int maxBytes,int iterations) {
        Need(iterations>0&&iterations<=10000,"ITERATION_LIMIT");
        for(int i=0;i<iterations;i++){ byte[] b=Read(root,relative,maxBytes); Need(b.Length>0,"EMPTY_READ"); }
        return iterations;
    }
    public static string RootFinalPath(SafeFileHandle root) { return FinalPath(root); }
}
