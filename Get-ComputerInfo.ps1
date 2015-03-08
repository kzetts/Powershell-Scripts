function Get-ComputerInfo
{
    [CmdletBinding()]
    Param (
        # ComputerName
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $ComputerName
    )
    Process
    {
        # Check if computers is online
        if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1){
            # Create object for computer information
            $computerInfo = New-Object -TypeName System.Management.Automation.PSObject
 
            Try {
 
                # Get Computer System information
                $computerSystem = Get-WmiObject -ComputerName $ComputerName -Class "Win32_ComputerSystem" -ErrorAction SilentlyContinue
                if (!$?){throw $Error[0].Exception}
                $bios = Get-WmiObject -ComputerName $ComputerName -Class "Win32_Bios" -ErrorAction SilentlyContinue
                if (!$?){throw $Error[0].Exception}
 
                # Get IP Addresses
                $networkConfiguration = Get-WmiObject -ComputerName $ComputerName -Query "Select * From Win32_NetworkAdapterConfiguration Where IPEnabled = True" -ErrorAction SilentlyContinue
                if (!$?){throw $Error[0].Exception}
                $ipAddresses = $networkConfiguration.IPAddress | Where-Object {$_ -match "\d\.\d\.\d\.\d"}
                $ipAddresses = $ipAddresses -join ", "
 
                # Add information to object
                $computerInfo | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value "$($computerSystem.Name)"
                $computerInfo | Add-Member -MemberType NoteProperty -Name "State" -Value "Online"
                $computerInfo | Add-Member -MemberType NoteProperty -Name "IPAddresses" -Value "$ipAddresses"
                $computerInfo | Add-Member -MemberType NoteProperty -Name "Model" -Value "$($computerSystem.Model)"
                $computerInfo | Add-Member -MemberType NoteProperty -Name "SerialNumber" -Value "$($bios.SerialNumber)"
                $computerInfo | Add-Member -MemberType NoteProperty -Name "LoggedOn" -Value "$($computerSystem.Username)"
 
                Return $computerInfo
            }
            Catch [System.Exception] {
                $computerInfo = New-Object -TypeName System.Management.Automation.PSObject
                $computerInfo | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $ComputerName
                $computerInfo | Add-Member -MemberType NoteProperty -Name "State" -Value "Error getting information"
 
                Return $computerInfo
            }
 
 
        }
        else {
            $computerInfo = New-Object -TypeName System.Management.Automation.PSObject
            $computerInfo | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $ComputerName
            $computerInfo | Add-Member -MemberType NoteProperty -Name "State" -Value "Offline"
 
            Return $computerInfo
        }
    }
}