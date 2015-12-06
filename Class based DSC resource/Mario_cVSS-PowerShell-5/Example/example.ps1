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