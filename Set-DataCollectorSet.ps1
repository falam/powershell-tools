<#
    .Synopsis 
        Action on a PCM DataCollectorSet on list of remote computers.
		Valid Actions - START, STOP
        
    .Description
        This script helps in [Action]-ing a DataCollectorSet remotely on list of remote computers.
 
    .Parameter ComputerName    
        Computer name(s) for which you want to [Action] a service.
        
    .Example
        Set-DataCollectorSet.ps1 -ComputerName Comp1, Comp2 -ServiceName PCM_Daily -Action Start
		
		Check PCM_Daily DataCollectorSet on Comp1 and Comp2 computers and report the status
       
    .Notes
        NAME:      Set-DataCollectorSet.ps1
        AUTHOR:    Farhan Alam
#>

[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,
	
	[parameter(Mandatory=$true)]
	[string]$ServiceName,
	
	[ValidateSet('START','STOP')]
	[string]$Action
	#,[string]$OutputDir = "C:\"
)

begin {
	$ComputerName = 'localhost', 'OTPDEV', 'Dummy' #override
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
		
		$IsOnline=$false
		if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) { #-ea 0 -ErrorAction SilentlyContinue
			$IsOnline = $true
			try {
				$datacollectorset = New-Object -COM Pla.DataCollectorSet				
                $datacollectorset.Query($ServiceName, $Computer)
				
				if ($Action -eq 'START')
				{
					$datacollectorset.Start($false)				
				}
				if ($Action -eq 'STOP')
				{
					$datacollectorset.Stop($false)					
				}
				$ServiceStatus = $datacollectorset.Status				
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
		#$OutputObj
		$OutputArray += $OutputObj
	}	
	$OutputArray | Format-Table -Autosize
	#$OutputArray | ? {$_.Status -eq "Failed" -or $_.IsOnline -eq $false} | Out-File -FilePath $FailedComputers
	#$OutputArray | ? {$_.Status -eq "Success"} | Out-File -FilePath $SuccessComputers
}
end {
}
