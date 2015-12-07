# Mario_cVSS


This DSC Class Base Resources contains DSC Resources **VSS and VSSTaskScheduler** , which allows creating VSS on the volumes and registering scheduled jobs.


Installation
-------
-   WMF5 Preview: From an elevated PowerShell session run ‘Install-Module Mario_cVSS’


Requirements
-------

This module requires the latest version of PowerShell v5.0 Production Preview or Windows 10 with the latest build 10586 . 

Details
-------

**VSS** resource has following properties:

- **Drive** - Specify Volume 
- **Size** - Size of Shadow Storgare 

**VSSTaskScheduler** resource has following properties:

- **TaskName** - Name of Scheduled Task 
- **Drive** -Specify Volume
- **Credential** - Administrator Credential to enable Scheduled Job 
- **TimeTrigger** - Time when the job will be run. 

Versions
-------
**1.0.0.0**
- **Initial release of Mario_cVSS module with following resources**
- **VSS**
- **VSSTaskScheduler**

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
