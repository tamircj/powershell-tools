param(
    [Parameter(Mandatory=$True)]
    [string]$inPath,
    [Parameter(Mandatory=$True)]
    [string]$outPath
)

function Copy-FilesNotEquals {
    param( [string]$inPath, [string]$outPath )
    $files_to_copy = Get-ChildItem $inPath -Force
    for ($i=0; $i -lt $files_to_copy.Count; $i++) 
    {
        $currentOutPath = Join-Path -Path $outPath -ChildPath $files_to_copy[$i].Name
        if (Test-Path -Path $files_to_copy[$i].FullName -PathType Container)
        {
            if (-not(Test-Path -Path $currentOutPath -PathType Container))
            {
                New-Item -ItemType directory -Path $currentOutPath -Force | Out-Null
            }
            Copy-FilesNotEquals -inPath $files_to_copy[$i].FullName -outPath $currentOutPath
        }
        else
        {
            if (Test-Path -Path $currentOutPath -PathType Any)
            {
                #Hash option: (use .Hash when comparing)
                #$currentInPathHash = Get-FileHash -Path $files_to_copy[$i].FullName -Algorithm MD5
                #$currentOutPathHash = Get-FileHash -Path $currentOutPath -Algorithm MD5
                
                #LastWriteTime option: (use .LastWriteTime when comparing)
                $currentInPathFile = Get-Item -Path $files_to_copy[$i].FullName
                $currentOutPathFile = Get-Item -Path $currentOutPath

                if ($currentInPathFile.LastWriteTime -ne $currentOutPathFile.LastWriteTime)
                {
                    Copy-Item -Path $files_to_copy[$i].FullName -Destination $currentOutPath -Force | Out-Null
                }
            }
            else
            {
                Copy-Item -Path $files_to_copy[$i].FullName -Destination $currentOutPath -Force  | Out-Null
            }
        }
    }
}

function Strip-OldFiles{
    param( [string]$inPath, [string]$outPath )
    $files_to_strip = Get-ChildItem $outPath -Force
    for ($i=0; $i -lt $files_to_strip.Count; $i++) 
    {
        $currentOutPath = Join-Path -Path $inPath -ChildPath $files_to_strip[$i].Name
        if (Test-Path -Path $currentOutPath -PathType Any)
        {
            if (Test-Path -Path $files_to_strip[$i].FullName -PathType Container)
            {
                Strip-OldFiles -inPath $currentOutPath -outPath $files_to_strip[$i].FullName
            }
        }
        else
        {
            Remove-Item -Path $files_to_strip[$i].FullName -Force -Recurse
        }
      
    }
}

Copy-FilesNotEquals -inPath $inPath -outPath $outPath 
Strip-OldFiles -inPath $inPath -outPath $outPath
