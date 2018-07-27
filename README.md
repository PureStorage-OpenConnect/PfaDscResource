# PfaDscResource
PowerShell module that implements a DSC resource to ensure a volume is present/absent in an active cluster pod.

## Installation Instructions

1. Copy the .psm1 and .psd1 files to C:\Program Files\WindowsPoweerShell\Modules\PfaDscResource.

2. The Test-PodVolumeResource.ps1 script serves as a means of testing the resource, to use this supply the
   name of an existing volume, the name of a non-stetched active cluster pod, an array end point and api token string
   (obtainable from the Purity GUI) and substitute the place holders in the script with these.

## License

Pure Storage invite customers and prospects to fork this repository and add their own reslource(s) to it. Pull requests are also welcome. However, please be aware that the use of this software comes under the Apache 2.0 license, meaning that end users use the software at their own risk subject to their own testing. 
