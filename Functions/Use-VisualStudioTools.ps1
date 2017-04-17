<#
  .SYNOPSIS
  Makes the current shell a Visual Studio Command Prompt

  .PARAMETER version
  The version of Visual Studio Command Line Tools to reference. Defaults to 2015.
#>
Function Use-VisualStudioTools
(
  [string] $version = "2017")
{

    function Ensure-VsWhereInstalled() {
        write-host "Ensuring VSWhere.exe installed..."
        $vswhere = where.exe vswhere.exe /Q
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to locate Visual Studio installation for 2017 because vswhere.exe is not installed. If you use Chocolatey, you can install this utility using 'choco install -y vswhere'."
        }
    }

    function Get-VisualStudioLocation([Parameter(Mandatory)] [string] $ToolsVersion) {
        write-host "Getting Visual Studio $Version Location from VSWhere.exe"
        $OutPut = vswhere -version $ToolsVersion
        $installationPath = $output `
            | ?{ $_ -match "installationPath"} `
            | %{ return ($_ -replace "installationPath:", "").Trim() }
        return $installationPath
    }

    switch ($version)
    {
        2017 { $toolsVersion = "15.0"; $UseVsWhere = $true}
        2015 { $toolsVersion = "140" }
        2013 { $toolsVersion = "120" }
        2012 { $toolsVersion = "110" }
        2010 { $toolsVersion = "100" }
        2008 { $toolsVersion = "90"  }
        2005 { $toolsVersion = "80"  }

        default {
            write-host "'$version' is not a recognized version."
            return
        }
    }

    if ($UseVsWhere) {
        Ensure-VsWhereInstalled
        $VsPath = Get-VisualStudioLocation -ToolsVersion $ToolsVersion
        $VsPath = Join-Path $VsPath "Common7/Tools"
        $VsBatchFile = "VsDevCmd.bat"
    } else {
        $variableName = "VS" + $toolsVersion + "COMNTOOLS"
        $VsPath = (get-childitem "env:$variableName").Value
        $VsBatchfile = "vsvars32.bat";
    }

    write-host "Found Visual Studio $Version at $VsPath"
    $VsFullPath = Join-Path -Path $VsPath -ChildPath $VsBatchFile
    write-host "Loading $variableName from $vsfullpath"

    pushd $vspath
    # cmd should like like this:
    # cmd /c """C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat""&set"
    $stdout = cmd /c "$($VsBatchFile)&set"
    $stdout | ?{ $_ -match "=" } | %{
        $v = $_.split("=");
        set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
    }
    popd

    msbuild /version
    write-host ""
    write-host "Visual Studio $version Command Prompt variables set." -ForegroundColor Green

}
