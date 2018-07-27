Clear-Host
Import-Module PureStoragePowerShellSDK

Configuration Test-PfaPodVolume
{
    Import-DSCResource -Module PfaDscResource
    PfaPodVolume pv
    {
        Pod         = "dsc-test-pod"
        Volume      = "dsc-test-vol"
        PfaEndpoint = "<insert pfa endpoint value here>"
        PfaApiToken = "<insert token value here>"
        Ensure      = "Present"
    }
}
Test-PfaPodVolume
Start-DscConfiguration -Wait -Force Test-PfaPodVolume
