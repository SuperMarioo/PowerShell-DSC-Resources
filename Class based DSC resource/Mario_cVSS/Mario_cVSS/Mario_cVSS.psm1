enum Ensure 
{ 
    Absent 
    Present 
}


[DscResource()]


class VSS {


           [DscProperty(Key)]
           [string]$Drive
           
           [DscProperty(mandatory)]
           [string]$Size

           [DscProperty()]
           [Ensure] $Ensure = "Present"
           



[VSS] Get() {

Write-Verbose "Getting Current Configuration"

        $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }
        $shadow = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }
        $vssconfig =[hashtable]::new()
        
        $vssconfig.add("Ensure",$this.Ensure)
        $vssconfig.add("Drive",$this.Drive)
        $vssconfig.add("Size",$this.Size)

        return $vssconfig
        
}  

[void] set() {
                $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }
                $shadow = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }

                     if ($this.Ensure -eq [ensure]::Present){

                    
                        if($shadow -and $(-not($this.CheckDrive())))
                        {

                                ## Changing the size of ShadowStorage

                            Write-Verbose "Changing only the size"
                
                        vssadmin Resize ShadowStorage /For=$($this.Drive) /On=$($this.Drive) /MaxSize=$($this.Size)


                        }elseif(-not $shadow -and $(-not($this.CheckDrive()))){


                                  Write-Verbose " Getting Current Drive "

                $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }
                $WMI=[WMICLASS]"root\cimv2:win32_shadowcopy"

                    Write-Verbose "Creating Shadow Copy on the Drive "

                $WMI.create($vol.DeviceID, "ClientAccessible")

                vssadmin Resize ShadowStorage /For=$($this.Drive) /On=$($this.Drive) /MaxSize=$($this.Size)

                        }
                    
                                        ##Ensure Present

                 } else {

                    Write-Verbose " Removing Shadow Copys on $($this.Drive) "

       
                vssadmin delete shadows /for=$($this.Drive) /Quiet
                        
                        $this.RemoveStorage()
 
                        }



}

[bool] test() {

Write-Verbose "Getting Current Configuration"

        $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }

        $testingVolume  = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }
       

        $VolumeSizeResult = $this.CheckDrive()




                if ($this.Ensure -eq [ensure]::Present){


                    if ($testingVolume -and $VolumeSizeResult -eq $true){

                            Write-Verbose "Shadow Copy is Enabled on the $($this.Drive) Drive"

                            return $true
                    }else {

                            Write-Verbose "Shadow Copy  is not  Enabled on the $($this.Drive) Or the size is wrong"
                            return $false

                          }

                }else {

                    if ($testingVolume){
                        
                        Write-Verbose "Shadow Copy  is Enabled on the $($this.Drive) Drive where it should be Disabled"

                        return $false 

                    }else {

                        Write-Verbose "Shadow Copy  is Disabled on the $($this.Drive) Drive"

                        return $true


                          }

                    }



}


##Helper Methods

<#[string] CurrentSize ($Currentsize) {


$current = [string]::Format('{0:0.00}GB', $Currentsize / 1GB)



return $current

}


#>

[bool] CheckDrive (){

## Checking Drive to Selected Drive
       
        $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }
        
        $testingVolume  = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }
      if($testingVolume.count -gt 1)
      {
        $currentVolume = $testingVolume.VolumeName[0]

      }elseif($testingVolume.count -eq 1)
        {

        $currentVolume = $testingVolume.VolumeName

        }
        else{

        $currentVolume=""

        }
## Using Regex to extract Drive 

        [regex]$regex = "{(\S)*}"
        $extractedString = $regex.Matches($currentVolume) | foreach-object {$_.Value}

## Getting Current size of the Shadow Copy


     IF ($extractedString)
     {
        $Currentsize = (Get-WmiObject Win32_ShadowStorage |  where {$_.Volume -match $extractedString } ).maxspace
     
     }else 
     {
        $Currentsize = ""


     }
        
    
        #$currensize = $this.CurrentSize($Currentsize)

        $TestingResult = $this.size -eq  $Currentsize
        
        

return $TestingResult


}


[void] RemoveStorage () {

        $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }

    
        $AssignDrive = $vol.DeviceID


                [regex]$regex = "{(\S)*}"
        $extractedString = $regex.Matches($AssignDrive) | foreach-object {$_.Value}

        Get-WmiObject Win32_ShadowStorage |  where {$_.Drive -match $extractedString } | Remove-WmiObject -ErrorAction SilentlyContinue


     

}

}



[DscResource()]

class VSSTaskScheduler {
           
           [DscProperty(mandatory)]
           [pscredential]$Credential

           [DscProperty(mandatory)]
           [string]$TimeTrigger

           [DscProperty(mandatory)]
           [DscProperty(Key)]
           [string]$TaskName

           [DscProperty(mandatory)]
           [string]$Drive


           [DscProperty()]
           [Ensure] $Ensure = "Present"


[VSSTaskScheduler] Get() {

Write-Verbose "Getting Current Configuration" 

$Task = Get-Scheduledjob  $this.TaskName -ErrorAction SilentlyContinue
$trigger = ($Task | Get-JobTrigger ).At.ToShortTimeString()
$vsstaskconfig =[hashtable]::new()
$vsstaskconfig.add('Ensure',$this.Ensure)
$vsstaskconfig.add('TaskName',$Task.Name)
$vsstaskconfig.add('TimeTrigger',$trigger)
$vsstaskconfig.add('Drive',$this.Drive)

return $vsstaskconfig





}

[void] set() {



            if ($this.Ensure -eq [ensure]::Present){

                Write-Verbose " Getting scheduled job  "

            $vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Drive -or $_.DeviceID -eq $this.Drive }
            $WMI=[WMICLASS]"root\cimv2:win32_shadowcopy"
            $deviceid = $vol.DeviceID
                
                Write-Verbose "Registering Scheduled Job $($this.TaskName) "


                ## Register Schedule job
            
            
            $triggertime = New-JobTrigger –Weekly –DaysOfWeek 1,2,3,4,5 –At $this.TimeTrigger 
            $joboption = New-ScheduledJobOption -RunElevated 
            
            
                ## Seting Up Param to register Scheduled job

            $param={
            
            param($deviceid)
            
            ([WMICLASS]"root\cimv2:win32_shadowcopy").create($deviceid, "ClientAccessible")
            
            }


            Register-ScheduledJob –Name $this.TaskName  -ScriptBlock $param `
            –Trigger $triggertime -ScheduledJobOption $joboption -ArgumentList ($deviceid) -Credential $this.Credential



            }else {

                Write-Verbose "Removing Scheduled job $($this.TaskName) "

            Unregister-ScheduledJob -Name $this.TaskName
        
 
                   }
}

[bool]test() {

$Task = Get-Scheduledjob  $this.TaskName -ErrorAction SilentlyContinue

## Testing if Task Exist 

            if ($Task) {
            
            $trigger = Get-JobTrigger $Task -ErrorAction SilentlyContinue
            $trigger = $trigger.at.ToShortTimeString()
            
            }else{
            
            $trigger=""
            
            }
            
            $SpecifiedTime = ([datetime] $this.TimeTrigger).ToShortTimeString()

                if ($this.Ensure -eq [ensure]::Present){


                    if ($Task.name -eq $this.TaskName -and $trigger -eq $SpecifiedTime){
        
                            Write-Verbose "Scheduled job $($this.TaskName) already exist"
        
                        return $true


                    }else {

                            Write-Verbose "Scheduled job $($this.TaskName) doesn't exist"

                        return $false


                           }



                } else {

                    if($task){

                            Write-Verbose "Scheduled job $($this.TaskName) already exist where it shoube be deleted"

                        return $false

                    }else {

                            Write-Verbose "Scheduled job $($this.TaskName) doesn't exist"

                        return $true

                            }

}

}



}
