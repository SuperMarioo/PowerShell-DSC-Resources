                                                                                    
function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[parameter(Mandatory = $true)]
		[System.String]
		$Template,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,
        [parameter(Mandatory = $true)]
        [Boolean]
        $Subfolders

	)

       
      
## Looking for Paths           




try {
        $findname = dir $path -Directory -ErrorAction Stop

        $oneFolder =  $path 

 Write-Verbose "Checking Conditions"

          

        
If ($Subfolders) {       
        
    $findname = $findname.PSPath.replace("Microsoft.PowerShell.Core\FileSystem::","")    
        
        if ($Ensure -eq "Present") {

        #removeTemplate

        $findname | % { remove-FsrmQuota -Path $_ -Confirm:$false -ErrorAction SilentlyContinue | Out-Null  }
        
        #createTemplate

Write-Verbose "Creating Quota for Multiple Folders with path  $path "
       
        $findname | % { New-FsrmQuota -Path $_ -Template $template -ErrorAction Stop    } 

        } else {


Write-Verbose "Removing Quota for Multiple Folders with path $path "

        $findname | % { remove-FsrmQuota -Path $_ -Confirm:$false }

        }#Ensure Closed



} else { # Close ManyFolders 




        if ($Ensure -eq "Present") {

        #removeTemplate

        remove-FsrmQuota -Path $oneFolder -Confirm:$false -ErrorAction SilentlyContinue | Out-Null 
        
        #createTemplate

Write-Verbose "Creating Quota for Single Folder with path  $path "
       
        New-FsrmQuota -Path $oneFolder -Template $template  
        
       


        }else {


Write-Verbose "Removing Quota for Single Folder with path $path "

         
         remove-FsrmQuota -Path $oneFolder -Confirm:$false }


        }


}Catch {






      
                                   ## Catching Errors
Write-Debug "Errors"
                                $exception = $_

                                Write-Verbose "An error occurred while running Set-TargetResource function"

                                if ($exception.InnerException -ne $null)
                                {

                                $exception = $exception.InnerException
                                Write-Verbose $exception.message

                                }else {


                                 Write-Verbose $exception


                                }




}


}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[parameter(Mandatory = $true)]
		[System.String]
		$Template,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,
        [parameter(Mandatory = $true)]
        [Boolean]
        $Subfolders
	)



## Finding Quats 
Write-Debug "yo"


try{ #checking for Errors

Write-Verbose "Testing if Quotas are Assigned"

        $findname = dir $path -Directory  -ErrorAction Stop
        $oneFolder =  $path 

IF($Subfolders){



                $findname = $findname.PSPath.replace("Microsoft.PowerShell.Core\FileSystem::","")

                $result = @()

                $findname | %  { 

                $test = Get-FsrmQuota $_ -ErrorAction SilentlyContinue

                            if ($test -and $test.template -eq $template){

                            $t = "true"
            
                            $result += $t

                            }else {

                            $f = "false"
                            $result += $f 


                            }

                            }#Closed FindName



    if ($ensure -eq "Present") {

         ## Testing Present 

Write-Verbose "Testing Multiple Folders"


            if ($result -contains "false"){

Write-Verbose "Quota is not  Assigned"

            return $false


            } else {

Write-Verbose "Quota is  Assigned"

            return $true


}

}


 
else {#absent

        ## Testing absent 

              if ($result -contains "false"){

    
Write-Verbose "Quota is Assigned , where it should not be"          
              
              return $true


                    } else {
Write-Verbose "Quota is not Assigned , nothing to configure "



                return $false


                           }

}

}else {## Single Folders 


   if($Ensure -eq "Present"){     

Write-Verbose "Testing Single Folder"

        $test = Get-FsrmQuota -Path $oneFolder -ErrorAction SilentlyContinue


        if($test-and $test.Template -eq $Template) {

Write-Verbose "Quota Exist for $oneFolder , nothing to configure" 

        return $true


        }else{


Write-Verbose "Quota doesn't Exist for $oneFolder , while it should be" 

        return $false


        }


                           }else { #Closed Present

        $test = Get-FsrmQuota -Path $oneFolder  -ErrorAction SilentlyContinue
         
        if (-not $test ) {

Write-Verbose "Quota doesn't Exist for $oneFolder , nothing to configure" 


        return $true



        }else {


Write-Verbose "Quota Exist for $oneFolder , while it should not be ." 

        return $false

        }

}#close Absent




}


}catch { #closed cached


         
                                   ## Catching Errors
Write-Debug "Errors"
                                $exception = $_

                                Write-Verbose "An error occurred while running Testt-TargetResource function"

                                if ($exception.InnerException -ne $null)
                                {

                                $exception = $exception.InnerException
                                Write-Verbose $exception.message

                                }else {

                                  Write-Verbose $exception

                                  return $true

                                }
   


}


}



function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[parameter(Mandatory = $true)]
		[System.String]
		$Template,
        [parameter(Mandatory = $true)]
        [Boolean]
        $Subfolders
	)

Write-Verbose "Checking Configuration"

                   
                   
                    $findname = dir $path -Directory -ErrorAction SilentlyContinue

                    $onefolder = $Path

If($Subfolders){

                    $findname = $findname.PSPath.replace("Microsoft.PowerShell.Core\FileSystem::","")

                                      

$arrypath =@()
$arryTempl =@()                             
$arryEnsure =@()

                    $findname | %  { 

                    $test = Get-FsrmQuota $_ -ErrorAction SilentlyContinue
                     $Configuration = $false

                         
                        
  
                                
                                if ($test -and $test.Template -eq $Template){
Write-Verbose "Quotas Exist"

                                    $arrypath += $test.path
                                    $arryTempl += $test.Template
                                    $arryEnsure += "Present"
                                   
                                }else {



Write-Verbose "Quotas dosent Exist"

                                    $arrypath += $test.path
                                    $arryTempl += $test.Template
                                    $arryEnsure += "Absent"
                                   

                                }

                                    }#closed FindName


$confgiguration = @{



    Path = $arrypath -join " ,"

    Template = $arryTempl -join " ,"
    Ensure = $arryEnsure -join " ,"




}
                    
$confgiguration.add("Subfolders",$Subfolders)

$confgiguration          


}else {#closed Many Folders



           $test = FsrmQuota  $onefolder -ErrorAction SilentlyContinue
        
            $Configuration = @{
                     Template =$test.Template
                     Path =$path 
                     Subfolders = $Subfolders
                   }
            
            if ( $test -and $test.Template -eq $Template){

Write-Verbose "Quotas Exists"

            $Configuration.Add('Ensure','Present')

            return  $Configuration

            }else {

Write-Verbose "Quotas dosent Exists"

            $Configuration.Add('Ensure','absent')

            return  $Configuration

            }


}



}

Export-ModuleMember -Function *-TargetResource



