## Config Example


configuration VSS
{
    param (

        [Parameter(Mandatory)] 
        [pscredential]$cred

    )
  Import-DscResource -ModuleName Mario_cVSS
 


    node ("localhost")
    {
       VSS Drive_C {

        Ensure = 'Present'
        Size = '2.10GB'
        Volume = 'C:'

       }

       VSS Drive_D {

        Ensure = 'Present'
        Size = '2.90GB'
        Volume = 'D:'

       }

      VSSTaskScheduler NewTask1 {

       Ensure = 'Present'
       Drive = 'C:'
       TimeTrigger = '1:15 PM'
       TaskName = 'Task1'
       DependsOn = '[VSS]Drive_C'
       Credential = $cred

       }



       VSSTaskScheduler NewTask2 {

       Ensure = 'Present'
       Drive = 'C:'
       TimeTrigger = '2:16 PM'
       TaskName = 'Task2'
       DependsOn = '[VSS]Drive_C'
       Credential = $cred

       }

       
       VSSTaskScheduler NewTask3 {

       Ensure = 'Present'
       Drive = 'D:'
       TimeTrigger = '7:17 PM'
       TaskName = 'Task3'
       DependsOn = '[VSS]Drive_D'
       Credential = $cred

       }

       VSSTaskScheduler NewTask4 {

       Ensure = 'Present'
       Drive = 'D:'
       TimeTrigger = '5:18 PM'
       TaskName = 'Task4'
       DependsOn = '[VSS]Drive_D'
       Credential = $cred

       }


       
    }
}
