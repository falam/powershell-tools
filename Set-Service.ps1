<#
    .Synopsis 
        Action on a service on list of remote computers.
		Valid Actions - START, STOP, RESTART
        
    .Description
        This script helps in [Action]-ing a service remotely on list of remote computers.
 
    .Parameter ComputerName    
        Computer name(s) for which you want to [Action] a service.
        
    .Example
        Set-Service.ps1 -ComputerName Comp1, Comp2 -ServiceName dnscache -Action START
		
		Check DNSCache service on Comp1 and Comp2 computers and report the status
       
    .Notes
        NAME:      Set-Service.ps1
        AUTHOR:    Farhan Alam
#>

[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,
	
	[parameter(Mandatory=$true)]
	[string]$ServiceName,
	
	[ValidateSet('START','STOP','RESTART')]
	[string]$Action,
	
	[ValidateSet('AUTOMATIC','MANUAL','DISABLED')]
	[string]$StartType
	#,[string]$OutputDir = "C:\"
)

begin {
	$ComputerName = 'localhost', 'DEV', 'Dummy' #Overriding
}
process{

	#$SuccessComputers  = Join-Path $OutputDir "SuccessComputers.txt"
	#$FailedComputers   = Join-path $OutputDir "FailedComputers.txt"
	$OutputArray = @()
	foreach($Computer in $ComputerName) {
		$OutputObj	= New-Object -TypeName PSobject 
		$OutputObj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer.TOUpper()
		Write-Verbose "Working on $Computer"
		$Status = "Failed"
		$ServiceStatus = "Unknown"
		$StartUpState = "Unknown"
		$IsOnline=$false
		if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) { #-ea 0 -ErrorAction SilentlyContinue
			$IsOnline = $true
			try {
				$ServiceObj = Get-Service -Name $ServiceName -ComputerName $Computer -ErrorAction Stop
				
				if ($StartType -eq 'AUTOMATIC' -or $StartType -eq 'MANUAL' -or $StartType -eq 'DISABLED')
				{					
					#Set-Service -InputObj $ServiceObj -StartupType $StartType -erroraction stop
          #PS 2.0 Compatible
					Set-Service -Name $ServiceObj.Name -ComputerName $Computer -StartupType $StartType -erroraction stop					
				}
				
				if ($Action -eq 'START')
				{
					Start-Service -InputObj $ServiceObj -erroraction stop					
				}
				if ($Action -eq 'STOP')
				{
					Stop-Service -InputObj $ServiceObj -erroraction stop					
				}
				if ($Action -eq 'RESTART')
				{
					Restart-Service -InputObj $ServiceObj -erroraction stop					
				}
				$ServiceStatus = $ServiceObj.Status
        #PS 2.0 Compatible
				$StartUpState = (Get-WMIObject -ClassName Win32_Service -ComputerName $Computer -Filter "Name = '$ServiceName'").StartMode #$ServiceObj.StartType
				$Status="Success"
				
			} catch {
				Write-Verbose "Failed to $Action $Service on $Computer. Error: $_"
				$Status="Failed"
			}						
		}
		else {
			Write-Verbose "$Computer is not reachable"
			$IsOnline = $false
			
		}
		$OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value $IsOnline
		$OutputObj | Add-Member -MemberType NoteProperty -Name Status -Value $Status		
		$OutputObj | Add-Member -MemberType NoteProperty -Name ServStatus -Value $ServiceStatus
		$OutputObj | Add-Member -MemberType NoteProperty -Name StartUp -Value $StartUpState
		#$OutputObj
		$OutputArray += $OutputObj
	}	
	$OutputArray | Format-Table -Autosize
	#$OutputArray | ? {$_.Status -eq "Failed" -or $_.IsOnline -eq $false} | Out-File -FilePath $FailedComputers
	#$OutputArray | ? {$_.Status -eq "Success"} | Out-File -FilePath $SuccessComputers
}
end {
}
