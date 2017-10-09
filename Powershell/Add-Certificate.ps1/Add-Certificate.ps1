<#
*********************************************************************************************************
* Created by Ioan Popovici   | Requires PowerShell 3.0                                                  *
* ===================================================================================================== *
* Modified by   |    Date    | Revision | Comments                                                      *
* _____________________________________________________________________________________________________ *
* Ioan Popovici | 2017-09-26 | v1.0     | First version                                                 *
* ===================================================================================================== *
*                                                                                                       *
*********************************************************************************************************

.SYNOPSIS
    This PowerShell Script is used to add a certificate to the certificate store.
.DESCRIPTION
    This PowerShell Script is used to add a certificate to the certificate store using the certificate key in base64 format.
.EXAMPLE
    C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -NoExit -NoProfile -File Add-Certificate.ps1
.NOTES
    Credit to FTW:
    https://home.configmgrftw.com/certificate-deployment-with-configmgr/
.LINK
    https://sccm-zone.com
    https://github.com/JhonnyTerminus/SCCM
#>

##*=============================================
##* VARIABLE DECLARATION
##*=============================================
#region VariableDeclaration

## Result object initialization
[psObject]$Result = @()
## Certificate variables
[array]$cerStores =@('Root','TrustedPublisher')
[string]$cerStringBase64 = '
    MIIC7TCCAdWgAwIBAgIQYexQKvQO66dOug2InrN2ZzANBgkqhkiG9w0BAQsFADAm
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    R1TFx1baj97rlziBt2XVZYG9tEFpPxRPD4A5FjRCix/Q
'

#endregion
##*=============================================
##* END VARIABLE DECLARATION
##*=============================================

##*=============================================
##* FUNCTION LISTINGS
##*=============================================
#region FunctionListings

#region Function Add-Certificate
Function Add-Certificate {
    <#
    .SYNOPSIS
        This function is used to add a certificate to the certificate store.
    .DESCRIPTION
        This function is used to add a certificate to the certificate store using the certificate base64 key.
    .PARAMETER cerStringBase64
        The certificate key to add in base64 format.
    .PARAMETER cerStoreLocation
        The certificate Store Location to search. The Default value used is 'LocalMachine'.
        Available Values:
            CurrentUser
            LocalMachine
    .PARAMETER cerStoreName
        The certificate Store Name to search.
        Available Values for CurentUser:
            ACRS
            SmartCardRoot
            Root
            Trust
            AuthRoot
            CA
            UserDS
            Disallowed
            My
            TrustedPeople
            TrustedPublisher
            ClientAuthIssuer
        Available Values for LocalMachine:
            rustedPublisher
            ClientAuthIssuer
            Remote Desktop
            Root
            TrustedDevices
            WebHosting
            CA
            WSUS
            Request
            AuthRoot
            TrustedPeople
            My
            SmartCardRoot
            Trust
            Disallowed
            SMS
    .EXAMPLE
        Add-Certificate -cerStringBase64 $cerStringBase64 -cerStoreName 'TrustedPublisher'
    .NOTES
        This is an internal script function and should typically not be called directly.
    .LINK
        https://sccm-zone.com
        https://github.com/JhonnyTerminus/SCCM
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('cString')]
        [string]$cerStringBase64,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('cLocation')]
        [string]$cerStoreLocation = 'LocalMachine',
        [Parameter(Mandatory=$true,Position=2)]
        [Alias('cStore')]
        [string]$cerStoreName
    )

    ## Create certificate store object
    $cerStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $cerStoreName, $cerStoreLocation

    ## Open the certificate store as Read/Write
    $cerStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

    ## Convert the base64 string
    $certByteArray = [System.Convert]::FromBase64String($cerStringBase64)

    ## Create new certificate object
    $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

    ## Add certificate to the store
    $Certificate.Import($certByteArray)
    $cerStore.Add($Certificate)

    ## Close the certificate store
    $cerStore.Close()
}
#endregion

#endregion
##*=============================================
##* END FUNCTION LISTINGS
##*=============================================

##*=============================================
##* SCRIPT BODY
##*=============================================
#region ScriptBody

## Cycle specified certificate stores and add the specified certificate
$cerStores | ForEach-Object {
    Try {
        $AddCertificate = Add-Certificate -cerStringBase64 $cerStringBase64 -cerStoreName $_ -ErrorAction 'Stop'

        #  Create the Result Props
        $ResultProps = [ordered]@{
            'Store' = $_
            'Certificate' = $cerStringBase64
            'Status'  = 'Add Certificate - Success!'
        }

        #  Adding ResultProps hash table to result object
        $Result += New-Object 'PSObject' -Property $ResultProps
    }
    Catch {

        #  Create the Result Props
        $ResultProps = [ordered]@{
            'Store' = $_
            'Certificate' = $cerStringBase64
            'Status'  = 'Add Certificate - Failed!'
        }

        #  Adding ResultProps hash table to result object
        $Result += New-Object 'PSObject' -Property $ResultProps
    }
}

## Return result object
Write-Output -InputObject $Result

#endregion
##*=============================================
##* END SCRIPT BODY
##*=============================================
