enum Ensure
{
    Absent
    Present
}

<#
   This resource manages the file in a specific path.
   [DscResource()] indicates the class is a DSC resource
#>

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
        This property indicates if the settings should be present or absent
        on the system. For present, the resource ensures the file pointed
        to by $Path exists. For absent, it ensures the file point to by
        $Path does not exist.

        The [DscProperty(Mandatory)] attribute indicates the property is
        required and DSC will guarantee it is set.

        If Mandatory is not specified or if it is defined as
        Mandatory=$false, the value is not guaranteed to be set when DSC
        calls the resource.  This is appropriate for optional properties.
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
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] Set()
    {
        Write-Host "Checking if volume exists"
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
        This method is equivalent of the Test-TargetResource script function.
        It should return True or False, showing whether the resource
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
        This method is equivalent of the Get-TargetResource script function.
        The implementation should use the keys to find appropriate resources.
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
