@{
    RootModule            = 'NerdFonts.psm1'
    ModuleVersion         = '1.1.1'
    CompatiblePSEditions  = @(
        'Core'
        'Desktop'
    )
    GUID                  = '56922ac0-0cfb-4400-88ca-939f238b5d8f'
    Author                = 'PSModule'
    CompanyName           = 'PSModule'
    Copyright             = '(c) 2026 PSModule. All rights reserved.'
    Description           = 'A PowerShell module to download and install fonts from NerdFonts.'
    PowerShellVersion     = '5.1'
    ProcessorArchitecture = 'None'
    RequiredModules       = @(
        @{
            ModuleName     = 'Admin'
            ModuleVersion  = '1.1.0'
            MaximumVersion = '1.999.999'
        }
        @{
            ModuleName     = 'Fonts'
            ModuleVersion  = '1.1.0'
            MaximumVersion = '1.999.999'
        }
    )
    TypesToProcess        = @()
    FormatsToProcess      = @()
    FunctionsToExport     = @(
        'Get-NerdFont'
        'Install-NerdFont'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @(
        'Get-NerdFonts'
        'Install-NerdFonts'
    )
    ModuleList            = @()
    FileList              = @(
        'FontsData.json'
        'NerdFonts.psm1'
    )
    PrivateData           = @{
        PSData = @{
            Tags       = @(
                'fonts'
                'Linux'
                'MacOS'
                'module'
                'nerdfonts'
                'powershell'
                'powershell-module'
                'PSEdition_Core'
                'PSEdition_Desktop'
                'Windows'
            )
            LicenseUri = 'https://github.com/PSModule/NerdFonts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/PSModule/NerdFonts'
            IconUri    = 'https://raw.githubusercontent.com/PSModule/NerdFonts/main/icon/icon.png'
        }
    }
}
