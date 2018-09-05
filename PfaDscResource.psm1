enum Ensure
{
    Absent
    Present
}

<#
   Resource to create/remove a volume on the FlashArray specified by the EndPoint property.
#>

[DscResource()]
class PfaVolume
{
    <#
        Specifies the volume to be created / destroyed.
    #>
    [DscProperty(Key)]
    [string]$Volume
    <#
       This property specifies the size of the volume, the unit is represented by the unit property.

    #>
    [DscProperty(Mandatory)]
    [long]$Size
    <#
       A single letter representing the unit associated with the size of the volume:

       - K
       - G (GiB)
       - T (TiB)

    #>
    [DscProperty(Mandatory)]
    [char]$Unit
    <#
        Defines whether the resource (volume) should be present/absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
       This property defines the the endpoint of the FlashArray to create
       the volume on / remove the volume from.
    #>
    [DscProperty(Mandatory)]
    [string] $PfaEndpoint

    <#
       This property specifies API token to be used when connecting to
       the FlashArray.

    #>
    [DscProperty(Mandatory)]
    [string] $PfaApiToken

    <#
        Method to set the resource (volume) to the desired state.
    #>
    [void] Set()
    {
        Write-Host "Checking if volume exists"
        $volumeExists = $this.TestVolume()

        $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError

        if ($this.ensure -eq [Ensure]::Present)
        {
            if (-not $volumeExists)
            {
	            New-PfaVolume -Array $PfaArray -VolumeName $this.Volume -Size $this.Size -Unit $this.Unit 
            }            
        }
        else
        {
            if ($volumeExists)
            {
                Write-Verbose -Message "Removing volume $this.Volume"
                Remove-PfaVolumeOrSnapshot -Array $PfaArray -Name $this.Volume
            }
        }
    }

    <#
        Method to obtain the state the resource (volume) is in.
    #>
    [bool] Test()
    {
        $present = $this.TestVolume()

        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $present
        }
        else
        {
            return -not $present
        }
    }

    <#
        This method returns an instance of this class with the updated key
        properties.
    #>
    [PfaVolume] Get()
    {
        $present = $this.TestVolume()

        if ($present)
        {
            $this.Ensure = [Ensure]::Present
        }
        else
        {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }

    <#
        Helper method to check if the resource (volume) is already present or absent.
    #>
    [bool] TestVolume()
    {
        $present = $true

	    $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError

        if ((Get-PfaNamedVolumes -Array $PfaArray '*' | Select-String $this.Volume).Count -eq 1) {
            $present = $true
        }
        else {
            $present = $false
        }

        return $present
    }
} 

[DscResource()]
class PfaProtectionGroup
{
    <#
        Specifies the name of the protection group to be created / removed.
    #>
    [DscProperty(Key)]
    [string]$ProtectionGroup
  
    <#
        Defines whether the resource (protection group) should be present/absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
       This property defines the the endpoint of the FlashArray to create the
       protection group on / remove the protection group from.
    #>
    [DscProperty(Mandatory)]
    [string] $PfaEndpoint

    <#
       This property specifies API token to be used when connecting to
       the FlashArray.

    #>
    [DscProperty(Mandatory)]
    [string] $PfaApiToken

    <#
        Method to set the resource (protection group) to the desired state.
    #>
    [void] Set()
    {
        Write-Host "Checking if protection group exists"
        $protectionGroupExists = $this.TestProtectionGroup()

        $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError

        if ($this.ensure -eq [Ensure]::Present)
        {
            if (-not $protectionGroupExists)
            {
                New-PfaProtectionGroup -Array $PfaArray -Name $this.ProtectionGroup
            }            
        }
        else
        {
            if ($protectionGroupExists)
            {
                Write-Verbose -Message "Removing protection group $this.ProtectionGroup"
                Remove-PfaProtectionGroupOrSnapshot -Array $PfaArray -Name $this.ProtectionGroup
            }
        }
    }

    <#
        It should return True or False, showing whether the resource
        is in a desired state.
    #>
    [bool] Test()
    {
        $present = $this.TestProtectionGroup()

        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $present
        }
        else
        {
            return -not $present
        }
    }

    <#
        This method returns an instance of this class with the updated key
        properties.
    #>
    [PfaProtectionGroup] Get()
    {
        $present = $this.TestProtectionGroup()

        if ($present)
        {
            $this.Ensure = [Ensure]::Present
        }
        else
        {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }

    <#
        Helper method to check if the resource (protection group) is present / absent.
    #>
    [bool] TestProtectionGroup()
    {
        $present = $true

	    $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError

        if ((Get-PfaProtectionGroups -Array $PfaArray | Select-Object name | Select-String $this.ProtectionGroup).Count -eq 1) {
            $present = $true
        }
        else {
            $present = $false
        }

        return $present
    }
} 

[DscResource()]
class PfaPodVolume
{
    <#
        Specifies the unstretched pod that the volume is to be added to / removed from.
    #>
    [DscProperty(Key)]
    [string]$Pod
    <#
        Specifies the volume to be added to / removed from the pod.
    #>
    [DscProperty(Key)]
    [string]$Volume
    <#
        Specifies whether the resource (pod volume) should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
       This property defines the the endpoint of the FlashArray that
       the pods and volumes reside on.
    #>
    [DscProperty(Mandatory)]
    [string] $PfaEndpoint

    <#
       This property specifies API token to be used when connecting to
       the FlashArray.

    #>
    [DscProperty(Mandatory)]
    [string] $PfaApiToken

    <#
        Method to set the resource (pod volume) to the desired state.
    #>
    [void] Set()
    {
        Write-Host "Checking if volume exists in the pod"
        $volumeExistsInPod = $this.TestPodVolume()

        $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError

        if ($this.ensure -eq [Ensure]::Present)
        {
            if (-not $volumeExistsInPod)
            {
	            Add-PfaVolumeToContainer -Array $PfaArray -Container $this.Pod -Name $this.Volume
            }
        }
        else
        {
            if ($volumeExistsInPod)
            {
                Write-Verbose -Message "Removing volume $this.Volume from pod $this.Pod"
                $PodVolume = $this.Pod + "::" + $this.Volume
                Remove-PfaVolumeFromContainer -Array $PfaArray -Name $PodVolume
            }
        }
    }

    <#
        Method to return True or False, showing whether the resource
        is in a desired state.
    #>
    [bool] Test()
    {
        $present = $this.TestPodVolume()

        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $present
        }
        else
        {
            return -not $present
        }
    }

    <#
        This method returns an instance of this class with the updated key
        properties.
    #>
    [PfaPodVolume] Get()
    {
        $present = $this.TestPodVolume()

        if ($present)
        {
            $this.Ensure = [Ensure]::Present
        }
        else
        {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }

    <#
        Helper method to check if the volume is already present in the pod.
    #>
    [bool] TestPodVolume()
    {
        $present = $true

	    $PfaArray = New-PfaArray -EndPoint $this.PfaEndpoint -ApiToken $this.PfaApiToken -IgnoreCertificateError
        $fqvn     = $this.Pod + "::" + $this.Volume;

        if ((Get-PfaNamedVolumes -Array $PfaArray '*' | Select-String $fqvn).Count -eq 1) {
            $present = $true
        }
        else {
            $present = $false
        }

        return $present
    }
} 
