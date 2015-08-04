enum Ensure 
{ 
    Absent 
    Present 
}


[DscResource()]

class VSS {


           [DscProperty(Key)]
           [string]$Volume
           
           #[DscProperty()]
           #[string]$Size

           [DscProperty()]
           [Ensure] $Ensure = "Present"


[VSS] Get() {
$vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $volume -or $_.DeviceID -eq $volume }
$shadow = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }
$vssconfig =[hashtable]::new()

$vssconfig.add("Ensure",$this.Ensure)
$vssconfig.add("Volume",$this.Volume)

return $vssconfig





}



[void] set() {



if ($this.Ensure -eq [ensure]::Present){

Write-Verbose " Getting Current Volume Drive "

$vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Volume -or $_.DeviceID -eq $this.Volume }
$WMI=[WMICLASS]"root\cimv2:win32_shadowcopy"

Write-Verbose "Creating Shadow Copy on the Volume "

$result=$WMI.create($vol.DeviceID, "ClientAccessible")

#vssadmin Resize ShadowStorage /For=$($this.Volume) /On=$($this.Volume) /MaxSize=$($this.Size)


                                        }##Ensure Present

else {

Write-Verbose " Removing Shadow Copys "

        Write-Verbose "Disabling VSS on $($this.Volume)"
        vssadmin delete shadows /for=$($this.Volume) /Quiet
        
 
}





}

[bool]test() {



$vol=Get-WmiObject -class win32_volume | Where { $_.DriveLetter -eq $this.Volume -or $_.DeviceID -eq $this.Volume }

$testingvolue  = Get-WmiObject -class win32_shadowcopy | Where { $_.VolumeName -eq $vol.DeviceID }



if ($this.Ensure -eq [ensure]::Present){


if ($testingvolue){
Write-Verbose "Voulme Already Enabled "
return $true
}else {

return $false
Write-Verbose "Voulme Already Enable where should not be"
}

}## Closed Tag Ensure Present
else {

if ($testingvolue){
Write-Verbose "Voulme Already Enable where should not be"

return $false }else {

Write-Verbose "Voulme Already Disabled "
return $true



}

}



}


}

[DscResource()]

class VSSTask {


           [DscProperty()]
           [string]$TimeTrigger
           
           [DscProperty(Key)]
           [string]$TaskName

           [DscProperty()]
           [string]$Drive

           [DscProperty()]
           [Ensure] $Ensure = "Present"


[VSSTask] Get() {


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
Write-Verbose "Creating Shadow Copy on the Volume "


## Register Scheduled job


$triggertime = New-JobTrigger –Weekly –DaysOfWeek 1,2,3,4,5 –At $this.TimeTrigger 
$asadmin = New-ScheduledJobOption -RunElevated 



$param={

param($deviceid)

([WMICLASS]"root\cimv2:win32_shadowcopy").create($deviceid, "ClientAccessible")

}


Register-ScheduledJob –Name $this.TaskName  -ScriptBlock $param `
–Trigger $triggertime -ScheduledJobOption $asadmin -ArgumentList ($deviceid)



                                        }##Ensure Present

else {

Write-Verbose " Removing Scheduled jobs "

        Unregister-ScheduledJob -Name $this.TaskName
        
 
}





}

[bool]test() {

$Task = Get-Scheduledjob  $this.TaskName -ErrorAction SilentlyContinue


if ($Task) {

$trigger = Get-JobTrigger $Task -ErrorAction SilentlyContinue
$trigger = $trigger.at.ToShortTimeString()

}else{

$trigger=""

}

$formatedTime = ([datetime] $this.TimeTrigger).ToShortTimeString()





if ($this.Ensure -eq [ensure]::Present){


## Testing Condtions 

        if ($Task.name -eq $this.TaskName -and $trigger -eq $formatedTime){
        
        Write-Verbose "All good with Task "
        
        return $true


        }else {

           Write-Verbose "Something Wrong with Task "

           return $false


        }



}## Closed Tag Ensure Present
else {
        if($task){

       Write-Verbose "Task exist where not supposed to  "
        return $false

        }else {
        Write-Verbose "All good with Task is not present "
        
         
         return $true

        }



}

}



}

