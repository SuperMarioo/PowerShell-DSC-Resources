# Mario_cVSS


This DSC Class Base Resources contains DSC Resources **VSS and VSSTaskScheduler** , which allows creating VSS on the volumes and registering scheduled jobs.


Installation
-------
-   If you are using WMF4 / PowerShell Version 4: Unzip the content under $env:ProgramFilesWindowsPowerShellModules folder

-   If you are using WMF5 Preview: From an elevated PowerShell session run ‘Install-Module Mario_cVSS’


VSS resource has following properties:
Drive - Specify Volume 
Size - Size of Shadow Storgare 

VSSTaskScheduler resource has following properties:

TaskName - Name of Scheduled Task 
Drive -Specify Volume
Credential - Administrator Credential to enable Scheduled Job 
TimeTrigger - Time when the job will be run. 

SYNTAX


DataDisk -outputpath C:\DataDisk
Start-DscConfiguration -Path C:\DataDisk -Wait -Force -Verbose
```
VSS [String] #ResourceName
{
    Drive = [string]
    Size = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
}

 
VSSTaskScheduler [String] #ResourceName
{
    Credential = [PSCredential]
    TaskName = [string]
    [DependsOn = [string[]]]
    [Drive = [string]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    [TimeTrigger = [string]]
}
