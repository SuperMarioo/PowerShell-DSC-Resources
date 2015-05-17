

enum Ensure 
{ 
    Absent 
    Present 
}

[DscResource()]
class VMNetworkAdapter{

    
    
    [DscProperty(Key)]
    [string]$Name
  
    [DscProperty(Mandatory)]
    [Bool] $ManagementOS
    
    [DscProperty(Mandatory)]
    [String] $SwitchName

    [DscProperty()]
    [String] $VMName

    [DscProperty()]
    [Bool] $DynamicMacAddress

    [DscProperty()]
    [String] $StaticMacAddress

    [Ensure] $Ensure




    [VMNetworkAdapter] Get() 
    {
            
            DATA localizedData
{
    # same as culture = "en-US"
ConvertFrom-StringData @'    
    VMNameAndManagementTogether=VMName cannot be provided when ManagementOS is set to True.
    MustProvideVMName=Must provide VMName parameter when ManagementOS is set to False.
    GetVMNetAdapter=Getting VM Network Adapter information.
    FoundVMNetAdapter=Found VM Network Adapter.
    NoVMNetAdapterFound=No VM Network Adapter found.
    StaticAndDynamicTogether=StaticMacAddress and DynamicMacAddress parameters cannot be provided together.
    ModifyVMNetAdapter=VM Network Adapter exists with different configuration. This will be modified.
    EnableDynamicMacAddress=VM Network Adapter exists but without Dynamic MAC address setting.
    EnableStaticMacAddress=VM Network Adapter exists but without static MAC address setting.
    PerformVMNetModify=Performing VM Network Adapter configuration changes.
    CannotChangeHostAdapterMacAddress=VM Network adapter in configuration is a host adapter. Its configuration cannot be modified.
    AddVMNetAdapter=Adding VM Network Adapter.
    RemoveVMNetAdapter=Removing VM Network Adapter.
    VMNetAdapterExistsNoActionNeeded=VM Network Adapter exists with requested configuration. No action needed.
    VMNetAdapterDoesNotExistShouldAdd=VM Network Adapter does not exist. It will be added.
    VMNetAdapterExistsShouldRemove=VM Network Adapter Exists. It will be removed.
    VMNetAdapterDoesNotExistNoActionNeeded=VM Network adapter does not exist. No action needed.
'@
}


             
            $vmAdapterConfig =[hashtable]::new()
            $vmAdapterConfig.add('Name',$this.Name)
            $vmAdapterConfig.add('SwitchName',$this.SwitchName)
            
            
               if ($this.ManagementOS -and $this.VMName) {
        throw $localizedData.VMNameAndManagementTogether
    }

    if ((-not $this.ManagementOS) -and (-not $this.VMName)) {
         throw $localizedData.MustProvideVMName
    }


            $Arguments=[hashtable]::new()
            $Arguments.add('Name',$this.Name)


            if($this.VMName){

            $Arguments.add('VMName',$this.VMName)

            }elseif ($this.ManagementOS) {

                 $Arguments.add('ManagementOS',$true)
                 $Arguments.add('SwitchName',$this.SwitchName)
            }
            Write-Verbose $localizedData.GetVMNetAdapter
            $NetAdapter = Get-VMNetworkAdapter @Arguments -ErrorAction SilentlyContinue
            if ($NetAdapter) {
            Write-Verbose $localizedData.FoundVMNetAdapte

             if ($this.ManagementOS) {
            $vmAdapterConfig.Add('ManagementOS',$true)
            } elseif ($this.VMName) {
            $vmAdapterConfig.Add('VMName',$this.VMName)
                                 }

             $vmAdapterConfig.Add('DynamicMacAddress', $NetAdapter.DynamicMacAddressEnabled)
             if (-not ($NetAdapter.DynamicMacAddressEnabled)) {
            $vmAdapterConfig.Add('StaticMacAddress', $NetAdapter.MacAddress)   
                                }

            $vmAdapterConfig.Add('Ensure','Present')
            }else {
            Write-Verbose $localizedData.NoVMNetAdapterFound
            $vmAdapterConfig.Add('Ensure','Absent')
                  }

        return $vmAdapterConfig


    }

 
    [bool] Test()
    {
    DATA localizedData
{
    # same as culture = "en-US"
ConvertFrom-StringData @'    
    VMNameAndManagementTogether=VMName cannot be provided when ManagementOS is set to True.
    MustProvideVMName=Must provide VMName parameter when ManagementOS is set to False.
    GetVMNetAdapter=Getting VM Network Adapter information.
    FoundVMNetAdapter=Found VM Network Adapter.
    NoVMNetAdapterFound=No VM Network Adapter found.
    StaticAndDynamicTogether=StaticMacAddress and DynamicMacAddress parameters cannot be provided together.
    ModifyVMNetAdapter=VM Network Adapter exists with different configuration. This will be modified.
    EnableDynamicMacAddress=VM Network Adapter exists but without Dynamic MAC address setting.
    EnableStaticMacAddress=VM Network Adapter exists but without static MAC address setting.
    PerformVMNetModify=Performing VM Network Adapter configuration changes.
    CannotChangeHostAdapterMacAddress=VM Network adapter in configuration is a host adapter. Its configuration cannot be modified.
    AddVMNetAdapter=Adding VM Network Adapter.
    RemoveVMNetAdapter=Removing VM Network Adapter.
    VMNetAdapterExistsNoActionNeeded=VM Network Adapter exists with requested configuration. No action needed.
    VMNetAdapterDoesNotExistShouldAdd=VM Network Adapter does not exist. It will be added.
    VMNetAdapterExistsShouldRemove=VM Network Adapter Exists. It will be removed.
    VMNetAdapterDoesNotExistNoActionNeeded=VM Network adapter does not exist. No action needed.
'@
}
     


                  if ($this.ManagementOS -and $this.VMName) {
        throw $localizedData.CannotChangeHostAdapterMacAddress
    }

    if ((-not $this.ManagementOS) -and (-not $this.VMName)) {
       throw $localizedData.MustProvideVMName
    }

     if ($this.DynamicMacAddress -and $this.StaticMacAddress) {
       throw $localizedData.StaticAndDynamicTogether
    }


    $Arguments=[hashtable]::new()
    $Arguments.add('Name',$this.Name)

    if($this.VMName){

    $Arguments.add('VMName',$this.VMName)

    }elseif ($this.ManagementOS) {

         $Arguments.add('ManagementOS',$true)
         $Arguments.add('SwitchName',$this.SwitchName)
    }
    Write-Verbose $localizedData.GetVMNetAdapter
    $NetAdapter = Get-VMNetworkAdapter @Arguments -ErrorAction SilentlyContinue
    
    ## Testing Condition 


    if ($this.Ensure -eq [ensure]::Present) {

            if ($NetAdapter) {
            
            
            
            
            }else {
            
             Write-Verbose $localizedData.VMNetAdapterDoesNotExistShouldAdd

             return $false
            
            }        






    }else {



        if ($NetAdapter) {
            Write-Verbose $localizedData.VMNetAdapterExistsShouldRemove
            return $false
        } else {
            Write-Verbose $localizedData.VMNetAdapterDoesNotExistNoActionNeeded
            return $true
        }





    }






       
    }


    [void] Set()
    {
     
    }


}





$test = [VMNetworkAdapter]::new()


$test.Name = "Jazda"
$test.VMName = "Windows8"
$test.ManagementOS = $false
$test.Ensure = "Present"
$test.SwitchName = "internal"


$test.get()
$test.test()
$test.set()