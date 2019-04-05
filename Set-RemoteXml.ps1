<#
    .Synopsis 
        Set xml values on list of remote computers.		
        
    .Description
        This script helps in setting xml values remotely on list of remote computers.
 
    .Parameter ComputerName    
        Computer name(s) for which you want to check free space.
        
    .Example
        Set-RemoteXml.ps1 -ComputerName Comp1, Comp2 -Action SET -Path E:\Temp\Web.config -XPath "/configuration/system.serviceModel/behaviors/serviceBehaviors/behavior/serviceThrottling[@$AttributeName]"
		
		Set xml on Comp1 and Comp2 computers and report the status
       
    .Notes
        NAME:      Set-RemoteXml.ps1
        AUTHOR:    Farhan Alam
#>

[cmdletbinding()]
param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,

	#,[string]$OutputDir = "C:\"
	[Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)]	
	[System.String] $Path,
	
	[Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)]	
	[System.String] $XPath,
	
	[ValidateSet('SET')]
	[string]$Action
)

begin {
	$ComputerName = 'localhost', 'DEV', 'Dummy' #Overriding
	$Path = 'E:\Program Files\Application\Site\Web.config'
	$AttributeName = 'maxConcurrentInstances'
	$XPath = "/configuration/system.serviceModel/behaviors/serviceBehaviors/behavior/serviceThrottling[@$AttributeName]"
	$Value = '20'	
}
process{

	#$SuccessComputers  = Join-Path $OutputDir "SuccessComputers.txt"
	#$FailedComputers   = Join-path $OutputDir "FailedComputers.txt"
	$OutputArray = @()
	
	foreach($Computer in $ComputerName) {				
		Write-Verbose "Working on $Computer"
		$OutputObj = New-Object -TypeName PSobject 
		$OutputObj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer.ToUpper()
		$Status = "Failed"
		$Values = '';
		$IsOnline=$false
		if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) { #-ea 0 -ErrorAction SilentlyContinue
			$IsOnline = $true						
			try {					
				$NetworkPath = "\\$Computer\$Path" -replace ":", "$"
				[XML]$XML = Get-Content -Path $NetworkPath
				$Nodes = $XML.SelectNodes($XPath);

				if ($Action -eq 'SET'){
					$Nodes | % { $_.SetAttribute($AttributeName, $Value) }
					#$Nodes | % { $_.InnerXml = $Value }			
					$XML.Save($NetworkPath)
				}				

				$Nodes | % { $Values += $_.GetAttribute($AttributeName) + ' ' }								
				$Status="Success"					
			} catch {
				Write-Verbose "Failed to get to $NetworkPath on $Computer. Error: $_"
				$Status="Failed"
			}
		}
		else {
			Write-Verbose "$Computer is not reachable"
			$IsOnline = $false			
		}
		$OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value $IsOnline
		$OutputObj | Add-Member -MemberType NoteProperty -Name Status -Value $Status	
		$OutputObj | Add-Member -MemberType NoteProperty -Name $AttributeName -Value $Values
		$OutputArray += $OutputObj	
	}	
	$OutputArray | Format-Table -Autosize
	#$OutputArray | ? {$_.Status -eq "Failed" -or $_.IsOnline -eq $false} | Out-File -FilePath $FailedComputers
	#$OutputArray | ? {$_.Status -eq "Success"} | Out-File -FilePath $SuccessComputers
}
end {
}
