@{
    RootModule            = 'DynamicParams.psm1'
    ModuleVersion         = '1.2.4'
    CompatiblePSEditions  = @(
        'Core'
        'Desktop'
    )
    GUID                  = '144ccec3-f5e2-4691-8eab-f2195feeee1c'
    Author                = 'PSModule'
    CompanyName           = 'PSModule'
    Copyright             = '(c) 2025 PSModule. All rights reserved.'
    Description           = 'A PowerShell module that makes it easier to use dynamic params.'
    PowerShellVersion     = '5.1'
    ProcessorArchitecture = 'None'
    TypesToProcess        = @()
    FormatsToProcess      = @()
    FunctionsToExport     = @(
        'New-DynamicParam'
        'New-DynamicParamDictionary'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @(
        'DynamicParam'
        'DynamicParams'
    )
    ModuleList            = @()
    FileList              = @(
        'DynamicParams.psm1'
    )
    PrivateData           = @{
        PSData = @{
            Tags       = @(
                'dynamicparam'
                'dynamicparams'
                'Linux'
                'MacOS'
                'powershell'
                'powershell-module'
                'PSEdition_Core'
                'PSEdition_Desktop'
                'Windows'
            )
            LicenseUri = 'https://github.com/PSModule/DynamicParams/blob/main/LICENSE'
            ProjectUri = 'https://github.com/PSModule/DynamicParams'
            IconUri    = 'https://raw.githubusercontent.com/PSModule/DynamicParams/main/icon/icon.png'
        }
    }
}
