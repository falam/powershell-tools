<#
    .Synopsis 
        Check free space on list of remote computers.		
        
    .Description
        This script helps in checking free space remotely on list of remote computers.
 
    .Parameter ComputerName    
        Computer name(s) for which you want to check free space.
        
    .Example
        Check-FreeSpace.ps1 -ComputerName Comp1, Comp2
		
		Check free space on Comp1 and Comp2 computers and report the status
       
    .Notes
        NAME:      Check-FreeSpace.ps1
        AUTHOR:    Farhan Alam
#>

[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername

	#,[string]$OutputDir = "C:\"
)

begin {
	$ComputerName = 'localhost', 'OTPDEV', 'Dummy' #Overriding
	$Drives = 'C:', 'E:'
}
process{

function Class-Size($size)
{
	if($size -ge 1GB)
	{
	"{0:n2}" -f  ($size / 1GB) + " GB"
	}
	elseif($size -ge 1MB)
	{
	"{0:n2}" -f  ($size / 1MB) + " MB"
	}
	else	
	{
	"{0:n2}" -f  ($size / 1KB) + " KB"
	}
}
	#$SuccessComputers  = Join-Path $OutputDir "SuccessComputers.txt"
	#$FailedComputers   = Join-path $OutputDir "FailedComputers.txt"
	$OutputArray = @()
	foreach($Computer in $ComputerName) {

		Write-Verbose "Working on $Computer"
		$Status = "Failed"
		$IsOnline=$false
		if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) { #-ea 0 -ErrorAction SilentlyContinue
			$IsOnline = $true
			
			foreach ($Drive in $Drives)
			{
				$OutputObj	= New-Object -TypeName PSobject 
				$OutputObj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer.ToUpper()
				
				try {					
					$Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DeviceID='$Drive'" -ErrorAction Stop								
					$Status="Success"					
				} catch {
					Write-Verbose "Failed to check disk freespace on $Computer. Error: $_"
					$Status="Failed"
				}
				
				$OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value $IsOnline
				$OutputObj | Add-Member -MemberType NoteProperty -Name Status -Value $Status		
				$OutputObj | Add-Member -MemberType NoteProperty -Name DeviceID -Value $Disk.DeviceID
				$OutputObj | Add-Member -MemberType NoteProperty -Name FreeSpace -Value (Class-Size $Disk.FreeSpace)
				#$OutputObj
				$OutputArray += $OutputObj				
			}
		}
		else {
			Write-Verbose "$Computer is not reachable"
			$IsOnline = $false
			$OutputObj	= New-Object -TypeName PSobject 
			$OutputObj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer.ToUpper()
			$OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value $IsOnline
			$OutputObj | Add-Member -MemberType NoteProperty -Name Status -Value $Status	
			$OutputArray += $OutputObj	
		}

	}	
	$OutputArray | Format-Table -Autosize
	#$OutputArray | ? {$_.Status -eq "Failed" -or $_.IsOnline -eq $false} | Out-File -FilePath $FailedComputers
	#$OutputArray | ? {$_.Status -eq "Success"} | Out-File -FilePath $SuccessComputers
}
end {
}
