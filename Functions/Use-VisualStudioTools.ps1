<#
  .SYNOPSIS
  Makes the current shell a Visual Studio Command Prompt

  .PARAMETER version
  The version of Visual Studio Command Line Tools to reference. Defaults to 2015.
#>Function Use-VisualStudioTools
(
  [string] $version = "2015")
{
    switch ($version)
    {
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

	#Set environment variables for Visual Studio Command Prompt
  $variableName = "VS" + $toolsVersion + "COMNTOOLS"
	$vspath = (get-childitem "env:$variableName").Value
	$vsbatchfile = "vsvars32.bat";
	$vsfullpath = [System.IO.Path]::Combine($vspath, $vsbatchfile);
  write-host "Loading $variableName from $vsfullpath"

	pushd $vspath
	cmd /c $vsfullpath + "&set" |
	foreach {
	  if ($_ -match "=") {
		$v = $_.split("=");
		set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
	  }
	}
	popd

  msbuild /version
  write-host ""
	write-host "Visual Studio $version Command Prompt variables set." -ForegroundColor Green
}
