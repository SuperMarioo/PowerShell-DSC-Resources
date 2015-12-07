# Mario_cVSS


This DSC Class Base Resources contains DSC Resources **VSS and VSSTaskScheduler** , which allows creating VSS on the volumes and registering scheduled jobs.


Installation
-------
-   WMF5 : From an elevated PowerShell session run ‘Install-Module Mario_cVSS’


Requirements
-------

This module requires the latest version of PowerShell v5.0 Production Preview or Windows 10 with the latest build 10586 . 

Details
-------

**VSS** resource has following properties:

- **Drive** - Specify Volume 
- **Size** - Size of Shadow Storage 

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

Examples
-------
**Example 1:**  VSS will be enabled on 4 Drives  and Scheduled for 1:15PM from Monday to Friday (default setting)
``` powershell
configuration VSS
{

    param (
        [Parameter(Mandatory)] 
        [pscredential]$cred
    )

        Import-DscResource -ModuleName Mario_cVSS

    node ("localhost")
    {
      
      VSS Disk_C {

      Ensure = 'present'
      Drive = "C:"
      Size = 1Gb

      }

      VSS Disk_D {

      Ensure = 'present'
      Drive = "D:"
      Size = 1Gb
      
      }

      VSS Disk_F {

      Ensure = 'present'
      Drive = "F:"
      Size = 1Gb
    
      }

      VSS Disk_G {

      Ensure = 'present'
      Drive = "G:"
      Size = 1Gb

      }

      VSSTaskScheduler Disk_C {

       Ensure = 'present'
       Drive = 'C:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Disk_C'
       Credential = $cred
       DependsOn = '[VSS]Disk_C'

      }

       VSSTaskScheduler Disk_D {

       Ensure = 'present'
       Drive = 'D:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Disk_D'
       Credential = $cred
       DependsOn = '[VSS]Disk_D'

      }

      VSSTaskScheduler Disk_F {

       Ensure = 'present'
       Drive = 'F:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Disk_F'
       Credential = $cred
       DependsOn = '[VSS]Disk_F'

      }

      VSSTaskScheduler Disk_G {

       Ensure = 'present'
       Drive = 'G:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Disk_G'
       Credential = $cred
       DependsOn = '[VSS]Disk_G'

      }
    }
}

```
**Example 2:**  VSS will be enabled on Drive C and Scheduled for 1:15PM and 5:15PM from Monday to Friday (default setting)

```powershell
configuration VSS
{
    param (
        [Parameter(Mandatory)] 
        [pscredential]$cred
    )
        Import-DscResource -ModuleName Mario_cVSS

    node ("localhost")
    {

      VSS Disk_C {

      Ensure = 'present'
      Drive = "C:"
      Size = 4Gb

      }

      VSSTaskScheduler Disk_C_Task1 {

       Ensure = 'present'
       Drive = 'C:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Disk_C_Task1'
       Credential = $cred
       DependsOn = '[VSS]Disk_C'

      }

      VSSTaskScheduler Disk_C_Task2 {

       Ensure = 'present'
       Drive = 'C:'
       TimeTrigger = '5:15 PM'
       TaskName = 'Disk_C_Task2'
       Credential = $cred
       DependsOn = '[VSS]Disk_D'

      }
    }
}

```
