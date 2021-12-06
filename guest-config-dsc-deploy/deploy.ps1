Import-Module GuestConfiguration

$ConfigName = 'MonitorAntivirus'
$ResourceGroupName = 'test-lab'
$StorageAccountName = 'jacobconfig'
$StorageContainerName = 'guestpolicy'
$DisplayName = 'Monitor Endpoint Security'
$Description = 'Audit endpoint security presence'
$myGuid = New-Guid

# Only needed if passing params to New-GuestConfigurationPolicy
Import-LocalizedData -BaseDirectory '.\EndPointProtectionDSC\AzureGuestConfigurationPolicy\ParameterFiles' `
    -FileName 'EPAntivirusStatus.Params.psd1' `
    -BindingVariable ParameterValues | Out-Null

# Compile the .MOF file from DSC config
.\EndPointProtectionDSC\AzureGuestConfigurationPolicy\Configurations\MonitorAntivirus.ps1

# Create & publish the policy to Azure
# Default scope is current Subscription context    
New-GuestConfigurationPackage `
    -Name $ConfigName `
    -Configuration .\$ConfigName\$ConfigName.mof `
    -Force | `
Publish-GuestConfigurationPackage `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $StorageAccountName `
    -StorageContainerName $StorageContainerName `
    -Force | `
New-GuestConfigurationPolicy `
    -PolicyId $myGuid.Guid `
    -DisplayName $DisplayName `
    -Description $Description `
    -Path './policies' `
    -Platform 'Windows' `
    -Parameter $ParameterValues `
    -Version 1.0.0 | `
Publish-GuestConfigurationPolicy
