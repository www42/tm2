# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This creates OnPrem AD users.
# Run this script on the domain controller VM.
# ------------------------------------------------------------------------------------

Import-Module -Name activedirectory
$Domain = Get-ADDomain | % forest
$OU = New-ADOrganizationalUnit -Name 'Classical Physics' -PassThru
$Group = New-ADGroup -Name 'Classical Physics' -DisplayName 'Classical Physics' -GroupScope Global -Path $OU.DistinguishedName -PassThru
$SecurePW = ConvertTo-SecureString -String 'Pa55w.rd1234' -AsPlainText -Force
$Names = @(
    'Isaac Newton'
    'Wilhem Leibniz'
    'Willy Wien'
    'Ludwig Boltzmann'
    'James Maxwell'
)
foreach ($Name in $Names) {
    $FirstName = $Name.Split(' ')[0] 
    $User = New-ADUser -Name $Name `
                       -UserPrincipalName "$FirstName@$Domain" `
                       -SamAccountName $FirstName `
                       -Path $OU.DistinguishedName `
                       -AccountPassword $SecurePW `
                       -PasswordNeverExpires $true `
                       -Enabled $true `
                       -PassThru
    Add-ADGroupMember -Members $User -Identity $Group 
}
