[CmdletBinding()]
param()
$scriptName = 'Fonts'
Write-Verbose "[$scriptName] - Importing module"

#region - From [private]
Write-Verbose "[$scriptName] - [private] - Processing folder"

#region - From [private] - [common]
Write-Verbose "[$scriptName] - [private] - [common] - Importing"

$script:FontRegPathMap = @{
    CurrentUser = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    AllUsers    = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
}

$script:FontFolderPathMap = @{
    'Windows' = @{
        CurrentUser = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
        AllUsers    = "$($env:windir)\Fonts"
    }
    'MacOS'   = @{
        CurrentUser = "$env:HOME/Library/Fonts"
        AllUsers    = '/Library/Fonts'
    }
    'Linux'   = @{
        CurrentUser = "$env:HOME/.fonts"
        AllUsers    = '/usr/share/fonts'
    }
}

$script:OS = if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
    'Windows'
} elseif ($IsLinux) {
    'Linux'
} elseif ($IsMacOS) {
    'MacOS'
} else {
    throw 'Unsupported OS'
}

Write-Verbose "[$scriptName] - [private] - [common] - Done"
#endregion - From [private] - [common]
#region - From [private] - [Scope]
Write-Verbose "[$scriptName] - [private] - [Scope] - Importing"

enum Scope {
    CurrentUser
    AllUsers
}

Write-Verbose "[$scriptName] - [private] - [Scope] - Done"
#endregion - From [private] - [Scope]

Write-Verbose "[$scriptName] - [private] - Done"
#endregion - From [private]

#region - From [public]
Write-Verbose "[$scriptName] - [public] - Processing folder"

#region - From [public] - [Get-Font]
Write-Verbose "[$scriptName] - [public] - [Get-Font] - Importing"

function Get-Font {
    <#
        .SYNOPSIS
            Retrieves the installed fonts.

        .DESCRIPTION
            Retrieves the installed fonts.

        .EXAMPLE
            Get-Font

            Gets all the fonts installed for the current user.

        .EXAMPLE
            Get-Font -Name 'Arial*'

            Gets all the fonts installed for the current user that start with 'Arial'.

        .EXAMPLE
            Get-Font -Scope 'AllUsers'

            Gets all the fonts installed for all users.

        .EXAMPLE
            Get-Font -Name 'Calibri' -Scope 'AllUsers'

            Gets the font with the name 'Calibri' for all users.

        .OUTPUTS
            [System.Collections.Generic.List[PSCustomObject]]
    #>
    [Alias('Get-Fonts')]
    [OutputType([System.Collections.Generic.List[PSCustomObject]])]
    [CmdletBinding()]
    param(
        # Specifies the name of the font to get.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [SupportsWildcards()]
        [string[]] $Name = '*',

        # Specifies the scope of the font(s) to get.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Scope[]] $Scope = 'CurrentUser'
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$functionName]"
    }

    process {
        $scopeCount = $Scope.Count
        Write-Verbose "[$functionName] - Processing [$scopeCount] scope(s)"
        foreach ($ScopeItem in $Scope) {
            $scopeName = $ScopeItem.ToString()

            Write-Verbose "[$functionName] - [$scopeName] - Getting font(s)"
            $fontFolderPath = $script:FontFolderPathMap[$script:OS][$scopeName]
            Write-Verbose "[$functionName] - [$scopeName] - Font folder path: [$fontFolderPath]"
            $folderExists = Test-Path -Path $fontFolderPath
            Write-Verbose "[$functionName] - [$scopeName] - Folder exists: [$folderExists]"
            if (-not $folderExists) {
                return $fonts
            }
            $installedFonts = Get-ChildItem -Path $fontFolderPath -File
            $installedFontsCount = $($installedFonts.Count)
            Write-Verbose "[$functionName] - [$scopeName] - Filtering from [$installedFontsCount] font(s)"
            $nameCount = $Name.Count
            Write-Verbose "[$functionName] - [$scopeName] - Filtering based on [$nameCount] name pattern(s)"
            foreach ($fontFilter in $Name) {
                Write-Verbose "[$functionName] - [$scopeName] - [$fontFilter] - Filtering font(s)"
                $filteredFonts = $installedFonts | Where-Object { $_.Name -like "*$fontFilter*" }

                foreach ($fontItem in $filteredFonts) {
                    $fontName = $fontItem.BaseName
                    $fontPath = $fontItem.FullName
                    $fontScope = $scopeName
                    Write-Verbose "[$functionName] - [$scopeName] - [$fontFilter] - Found [$fontName] at [$fontPath]"

                    [PSCustomObject]@{
                        Name  = $fontName
                        Path  = $fontPath
                        Scope = $fontScope
                    }
                }
                Write-Verbose "[$functionName] - [$scopeName] - [$fontFilter] - Done"
            }
            Write-Verbose "[$functionName] - [$scopeName] - Done"
        }
    }

    end {}
}

Write-Verbose "[$scriptName] - [public] - [Get-Font] - Done"
#endregion - From [public] - [Get-Font]
#region - From [public] - [Install-Font]
Write-Verbose "[$scriptName] - [public] - [Install-Font] - Importing"

#Requires -Modules Admin

function Install-Font {
    <#
        .SYNOPSIS
            Installs a font in the system

        .DESCRIPTION
            Installs a font in the system

        .EXAMPLE
            Install-Font -Path C:\FontFiles\Arial.ttf

            Installs the font file 'C:\FontFiles\Arial.ttf' to the current user profile.

        .EXAMPLE
            Install-Font -Path C:\FontFiles\Arial.ttf -Scope AllUsers

            Installs the font file 'C:\FontFiles\Arial.ttf' so it is available for all users.
            This requires administrator rights.

        .EXAMPLE
            Install-Font -Path C:\FontFiles\Arial.ttf -Force

            Installs the font file 'C:\FontFiles\Arial.ttf' to the current user profile.
            If the font already exists, it will be overwritten.

        .EXAMPLE
            Install-Font -Path C:\FontFiles\Arial.ttf -Scope AllUsers -Force

            Installs the font file 'C:\FontFiles\Arial.ttf' so it is available for all users.
            This requires administrator rights. If the font already exists, it will be overwritten.

        .EXAMPLE
            Get-ChildItem -Path C:\FontFiles\ -Filter *.ttf | Install-Font

            Gets all font files in the folder 'C:\FontFiles\' and installs them to the current user profile.

        .EXAMPLE
            Get-ChildItem -Path C:\FontFiles\ -Filter *.ttf | Install-Font -Scope AllUsers

            Gets all font files in the folder 'C:\FontFiles\' and installs them so it is available for all users.
            This requires administrator rights.

        .EXAMPLE
            Get-ChildItem -Path C:\FontFiles\ -Filter *.ttf | Install-Font -Force

            Gets all font files in the folder 'C:\FontFiles\' and installs them to the current user profile.
            If the font already exists, it will be overwritten.

        .EXAMPLE
            Get-ChildItem -Path C:\FontFiles\ -Filter *.ttf | Install-Font -Scope AllUsers -Force

            Gets all font files in the folder 'C:\FontFiles\' and installs them so it is available for all users.
            This requires administrator rights. If the font already exists, it will be overwritten.
    #>
    [Alias('Install-Fonts')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # File or folder path(s) to the font(s) to install.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [string[]] $Path,

        # Scope of the font installation.
        # CurrentUser will install the font for the current user only.
        # AllUsers will install the font so it is available for all users on the system.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Scope[]] $Scope = 'CurrentUser',

        # Recurse will install all fonts in the specified folder and subfolders.
        [Parameter()]
        [switch] $Recurse,

        # Force will overwrite existing fonts
        [Parameter()]
        [switch] $Force
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$functionName]"

        if ($Scope -contains 'AllUsers' -and -not (IsAdmin)) {
            $errorMessage = @"
Administrator rights are required to install fonts in [$($script:FontFolderPathMap[$script:OS]['AllUsers'])].
Please run the command again with elevated rights (Run as Administrator) or provide '-Scope CurrentUser' to your command.
"@
            throw $errorMessage
        }
        $maxRetries = 10
        $retryIntervalSeconds = 1
    }

    process {
        $scopeCount = $Scope.Count
        Write-Verbose "[$functionName] - Processing [$scopeCount] scopes(s)"
        foreach ($scopeItem in $Scope) {
            $scopeName = $scopeItem.ToString()
            $fontDestinationFolderPath = $script:FontFolderPathMap[$script:OS][$scopeName]
            $pathCount = $Path.Count
            Write-Verbose "[$functionName] - [$scopeName] - Processing [$pathCount] path(s)"
            foreach ($PathItem in $Path) {
                Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - Processing"

                $pathExists = Test-Path -Path $PathItem -ErrorAction SilentlyContinue
                if (-not $pathExists) {
                    Write-Error "[$functionName] - [$scopeName] - [$PathItem] - Path not found, skipping."
                    continue
                }
                $item = Get-Item -Path $PathItem -ErrorAction Stop

                if ($item.PSIsContainer) {
                    Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - Folder found"
                    Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - Gathering font(s) to install"
                    $fontFiles = Get-ChildItem -Path $item.FullName -ErrorAction Stop -File -Recurse:$Recurse
                    Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - Found [$($fontFiles.Count)] font file(s)"
                } else {
                    Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - File found"
                    $fontFiles = $Item
                }

                foreach ($fontFile in $fontFiles) {
                    $fontFileName = $fontFile.Name
                    $fontName = $fontFile.BaseName
                    $fontFilePath = $fontFile.FullName
                    Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Processing"

                    $folderExists = Test-Path -Path $fontDestinationFolderPath -ErrorAction SilentlyContinue
                    if (-not $folderExists) {
                        Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Creating folder [$fontDestinationFolderPath]"
                        $null = New-Item -Path $fontDestinationFolderPath -ItemType Directory -Force
                    }
                    $fontDestinationFilePath = Join-Path -Path $fontDestinationFolderPath -ChildPath $fontFileName
                    $fontFileAlreadyInstalled = Test-Path -Path $fontDestinationFilePath
                    if ($fontFileAlreadyInstalled) {
                        if ($Force) {
                            Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Already installed. Forcing install."
                        } else {
                            Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Already installed. Skipping."
                            continue
                        }
                    }

                    $fontType = switch ($fontFile.Extension) {
                        '.ttf' { 'TrueType' }                 # TrueType Font
                        '.otf' { 'OpenType' }                 # OpenType Font
                        '.ttc' { 'TrueType' }                 # TrueType Font Collection
                        '.pfb' { 'PostScript Type 1' }        # PostScript Type 1 Font
                        '.pfm' { 'PostScript Type 1' }        # PostScript Type 1 Outline Font
                        '.woff' { 'Web Open Font Format' }    # Web Open Font Format
                        '.woff2' { 'Web Open Font Format 2' } # Web Open Font Format 2
                    }

                    if ($null -eq $fontType) {
                        # Write-Warning "[$fontFileName] - Unknown font type. Skipping."
                        continue
                    }

                    Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Installing font"

                    $retryCount = 0
                    $fileCopied = $false

                    do {
                        try {
                            $null = $fontFile.CopyTo($fontDestinationFilePath)
                            $fileCopied = $true
                        } catch {
                            $retryCount++
                            if (-not $fileRemoved -and $retryCount -eq $maxRetries) {
                                Write-Error $_
                                Write-Error "Failed [$retryCount/$maxRetries] - Stopping"
                                break
                            }
                            Write-Verbose "Failed [$retryCount/$maxRetries] - Retrying in $retryIntervalSeconds seconds..."
                            Start-Sleep -Seconds $retryIntervalSeconds
                        }
                    } while (-not $fileCopied -and $retryCount -lt $maxRetries)

                    if (-not $fileCopied) {
                        continue
                    }
                    $registeredFontName = "$fontName ($fontType)"
                    if ($script:OS -eq 'Windows') {
                        Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Registering font as [$registeredFontName]"
                        $regValue = if ('AllUsers' -eq $Scope) { $fontFileName } else { $fontDestinationFilePath }
                        $params = @{
                            Name         = $registeredFontName
                            Path         = $script:FontRegPathMap[$scopeName]
                            PropertyType = 'string'
                            Value        = $regValue
                            Force        = $true
                            ErrorAction  = 'Stop'
                        }
                        $null = New-ItemProperty @params
                    } elseif ($script:OS -eq 'Linux') {
                        fc-cache -fv
                    }
                    Write-Verbose "[$functionName] - [$scopeName] - [$fontFilePath] - Done"
                }
                if ($item.PSIsContainer) {
                    Write-Verbose "[$functionName] - [$scopeName] - [$PathItem] - Done"
                }
            }
            Write-Verbose "[$functionName] - [$scopeName] - Done"
        }
    }

    end {
        Write-Verbose "[$functionName] - Done"
    }
}

Write-Verbose "[$scriptName] - [public] - [Install-Font] - Done"
#endregion - From [public] - [Install-Font]
#region - From [public] - [Uninstall-Font]
Write-Verbose "[$scriptName] - [public] - [Uninstall-Font] - Importing"

#Requires -Modules Admin, DynamicParams

function Uninstall-Font {
    <#
        .SYNOPSIS
            Uninstalls a font from the system.

        .DESCRIPTION
            Uninstalls a font from the system.

        .EXAMPLE
            Uninstall-Font -Name 'Courier New'

            Uninstalls the 'Courier New' font from the system for the current user.

        .EXAMPLE
            Uninstall-Font -Name 'Courier New' -Scope AllUsers

            Uninstalls the Courier New font from the system for all users.

        .OUTPUTS
            None
    #>
    [Alias('Uninstall-Fonts')]
    [CmdletBinding()]
    param (
        # Scope of the font to uninstall.
        # CurrentUser will uninstall the font for the current user.
        # AllUsers will uninstall the font so it is removed for all users.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Scope[]] $Scope = 'CurrentUser'
    )

    DynamicParam {
        $paramDictionary = New-DynamicParamDictionary

        $dynName = @{
            Name                            = 'Name'
            Type                            = [string[]]
            Alias                           = @('FontName', 'Font')
            Mandatory                       = $true
            HelpMessage                     = 'Name of the font to uninstall.'
            ValueFromPipeline               = $true
            ValueFromPipelineByPropertyName = $true
            ValidationErrorMessage          = "The font name provided was not found in the selected scope [$Scope]."
            ValidateSet                     = if ([string]::IsNullOrEmpty($Scope)) {
                (Get-Font -Scope 'CurrentUser' -Verbose:$false).Name
            } else {
                (Get-Font -Scope $Scope -Verbose:$false).Name
            }
            DynamicParamDictionary          = $paramDictionary
        }
        New-DynamicParam @dynName

        return $paramDictionary
    }

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$functionName]"

        if ($Scope -contains 'AllUsers' -and -not (IsAdmin)) {
            $errorMessage = @"
Administrator rights are required to uninstall fonts in [$($script:FontFolderPath['AllUsers'])].
Please run the command again with elevated rights (Run as Administrator) or provide '-Scope CurrentUser' to your command.
"@
            throw $errorMessage
        }
        $maxRetries = 10
        $retryIntervalSeconds = 1
    }

    process {
        $Name = $PSBoundParameters['Name']

        $scopeCount = $Scope.Count
        Write-Verbose "[$functionName] - Processing [$scopeCount] scopes(s)"
        foreach ($scopeItem in $Scope) {
            $scopeName = $scopeItem.ToString()

            $nameCount = $Name.Count
            Write-Verbose "[$functionName] - [$scopeName] - Processing [$nameCount] font(s)"
            foreach ($fontName in $Name) {
                Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Processing"
                $font = Get-Font -Name $fontName -Scope $Scope
                Write-Verbose ($font | Out-String) -Verbose
                $filePath = $font.Path

                $fileExists = Test-Path -Path $filePath -ErrorAction SilentlyContinue
                if (-not $fileExists) {
                    Write-Warning "[$functionName] - [$scopeName] - [$fontName] - File [$filePath] does not exist. Skipping."
                } else {
                    Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Removing file [$filePath]"
                    $retryCount = 0
                    $fileRemoved = $false
                    do {
                        try {
                            Remove-Item -Path $filePath -Force -ErrorAction Stop
                            $fileRemoved = $true
                        } catch {
                            # Common error; 'file in use'. Usually VSCode or any web browser.
                            $retryCount++
                            if (-not $fileRemoved -and $retryCount -eq $maxRetries) {
                                Write-Error $_
                                Write-Error "Failed [$retryCount/$maxRetries] - Stopping"
                                break
                            }
                            Write-Verbose $_
                            Write-Verbose "Failed [$retryCount/$maxRetries] - Retrying in $retryIntervalSeconds seconds..."
                            #TODO: Find a way to try to unlock file here.
                            Start-Sleep -Seconds $retryIntervalSeconds
                        }
                    } while (-not $fileRemoved -and $retryCount -lt $maxRetries)

                    if (-not $fileRemoved) {
                        break  # Break to skip unregistering the font if the file could not be removed.
                    }
                }

                if ($script:OS -eq 'Windows') {
                    $fontDestinationRegPath = $script:FontRegPathMap[$scopeName]
                    Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Checking if font is registered at path [$fontDestinationRegPath]"
                    $fontRegistryPathExists = Get-ItemProperty -Path $fontDestinationRegPath -Name $fontName -ErrorAction SilentlyContinue
                    if (-not $fontRegistryPathExists) {
                        Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Font is not registered. Skipping."
                    } else {
                        Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Unregistering font with path [$fontDestinationRegPath]"
                        Remove-ItemProperty -Path $fontDestinationRegPath -Name $fontName -Force -ErrorAction Stop
                    }
                }
                Write-Verbose "[$functionName] - [$scopeName] - [$fontName] - Done"
            }
            Write-Verbose "[$functionName] - [$scopeName] - Done"
        }
    }

    end {
        Write-Verbose "[$functionName] - Done"
    }
}

Write-Verbose "[$scriptName] - [public] - [Uninstall-Font] - Done"
#endregion - From [public] - [Uninstall-Font]

Write-Verbose "[$scriptName] - [public] - Done"
#endregion - From [public]


$exports = @{
    Alias    = '*'
    Cmdlet   = ''
    Function = @(
        'Get-Font'
        'Install-Font'
        'Uninstall-Font'
    )
    Variable = ''
}
Export-ModuleMember @exports

