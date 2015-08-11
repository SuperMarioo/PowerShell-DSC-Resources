Volume Shadow Copy Service


This DSC Class Base Resources contains DSC Resources VSS and VSSTaskScheduler , which allows creating VSS on the volumes and registering scheduled jobs.


Details


VSS resource has following properties:
Drive - Specify Volume 
Size - Size of Shadow Storgare 

VSSTaskScheduler resource has following properties:

TaskName - Name of Scheduled Task 
Drive -Specify Volume
Credential - Administrator Credential to enable Scheduled Job 
TimeTrigger - Time when the job will be run. 

SYNTAX

 
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
