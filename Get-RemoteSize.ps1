<#
    .Synopsis 
        Get File/Folder size on list of remote computers.		
        
    .Description
        This script helps in gettinging file/folder size on list of remote computers.
        Admin share $ needs to enabled for this script to work properly
 
    .Parameter ComputerName    
        Computer name(s) for which you want to size info on
        
    .Example
        Get-RemoteSize.ps1 -Computers Comp1, Comp2 -Path C:\Temp
		
		Check C:\Temp folder size on Comp1 and Comp2 computers and report the size
       
    .Notes
        NAME:      Set-Service.ps1
        AUTHOR:    Farhan Alam
#>
Param(
[Parameter(ValueFromPipeline=$True)]
[Array] $Computers = $env:computername,
[Parameter(ValueFromPipeline=$True, Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[System.String] $Path
)

function Class-Size($size)
{
IF($size -ge 1GB)
{
"{0:n2}" -f  ($size / 1GB) + " GB"
}
ELSEIF($size -ge 1MB)
{
"{0:n2}" -f  ($size / 1MB) + " MB"
}
ELSE
{
"{0:n2}" -f  ($size / 1KB) + " KB"
}
}

function Class-Diff($size)
{	
	$baseSize = 10747552 #Scripts
	#$baseSize = 88026852 #Themes
	
	$diff = $baseSize - $size
	
	IF($diff -lt 0)
	{
	   $diff = $diff * -1
	}
	
	return ($diff/$baseSize).tostring("P")
} 

function Get-FolderSize 
{
Param(
$Path, [Array]$Computers
)
	$Computers = 'localhost', 'OTPDEV', 'Dummy' #Overriding

	$fso = New-Object -ComObject Scripting.FileSystemObject 
	$Array = @()
	Foreach($Computer in $Computers)
	{
		#$ErrorActionPreference = "SilentlyContinue"
		$ErrorActionPreference = "Stop"

		$NetworkPath = "\\$Computer\$Path" -replace ":", "$"
		#Write-Host $NetworkPath
		#$Length = $fso.GetFile($NetworkPath).Size
		$Length = $fso.GetFolder($NetworkPath).Size
		
		$Result = "" | Select Computer,Folder,Length #,Difference
		$Result.Computer = $Computer
		$Result.Folder = $Path
		$Result.Length = Class-Size $Length
		#$Result.Difference = Class-Diff $Length
		$array += $Result
	}
	return $array
}

Get-FolderSize -Computers $Computers -Path $PathParam(
[Parameter(ValueFromPipeline=$True)]
[Array] $Computers = $env:computername,
[Parameter(ValueFromPipeline=$True, Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[System.String] $Path
)

function Class-Size($size)
{
IF($size -ge 1GB)
{
"{0:n2}" -f  ($size / 1GB) + " GB"
}
ELSEIF($size -ge 1MB)
{
"{0:n2}" -f  ($size / 1MB) + " MB"
}
ELSE
{
"{0:n2}" -f  ($size / 1KB) + " KB"
}
}

function Class-Diff($size)
{	
	$baseSize = 10747552 #Scripts
	#$baseSize = 88026852 #Themes
	
	$diff = $baseSize - $size
	
	IF($diff -lt 0)
	{
	   $diff = $diff * -1
	}
	
	return ($diff/$baseSize).tostring("P")
} 

function Get-FolderSize 
{
Param(
$Path, [Array]$Computers
)
	$Computers = 'localhost', 'OTPDEV', 'Dummy' #Overriding

	$fso = New-Object -ComObject Scripting.FileSystemObject 
	$Array = @()
	Foreach($Computer in $Computers)
	{
		#$ErrorActionPreference = "SilentlyContinue"
		$ErrorActionPreference = "Stop"

		$NetworkPath = "\\$Computer\$Path" -replace ":", "$"
		#Write-Host $NetworkPath
		#$Length = $fso.GetFile($NetworkPath).Size
		$Length = $fso.GetFolder($NetworkPath).Size
		
		$Result = "" | Select Computer,Folder,Length #,Difference
		$Result.Computer = $Computer
		$Result.Folder = $Path
		$Result.Length = Class-Size $Length
		#$Result.Difference = Class-Diff $Length
		$array += $Result
	}
	return $array
}

Get-FolderSize -Computers $Computers -Path $Path
