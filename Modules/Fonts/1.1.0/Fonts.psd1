@{
    RootModule            = 'Fonts.psm1'
    ModuleVersion         = '1.1.0'
    CompatiblePSEditions  = @(
        'Core'
        'Desktop'
    )
    GUID                  = '9e217d74-4cfc-450b-bd02-e0fc26325bc0'
    Author                = 'PSModule'
    CompanyName           = 'PSModule'
    Copyright             = '(c) 2024 PSModule. All rights reserved.'
    Description           = 'A PowerShell module for managing fonts.'
    PowerShellVersion     = '5.1'
    ProcessorArchitecture = 'None'
    RequiredModules       = @(
        'Admin'
        'DynamicParams'
    )
    RequiredAssemblies    = @()
    ScriptsToProcess      = @()
    TypesToProcess        = @()
    FormatsToProcess      = @()
    NestedModules         = @()
    FunctionsToExport     = @(
        'Get-Font'
        'Install-Font'
        'Uninstall-Font'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = '*'
    ModuleList            = @()
    FileList              = @()
    PrivateData           = @{
        PSData = @{
            Tags       = @(
                'fonts'
                'Linux'
                'MacOS'
                'powershell'
                'powershell-module'
                'PSEdition_Core'
                'PSEdition_Desktop'
                'Windows'
            )
            LicenseUri = 'https://github.com/PSModule/Fonts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/PSModule/Fonts'
            IconUri    = 'https://raw.githubusercontent.com/PSModule/Fonts/main/icon/icon.png'
        }
    }
}

