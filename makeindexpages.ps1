function Generate-IndexHtml {
    param (
        [string]$folderPath
    )

    $subDirs = Get-ChildItem -Directory -Path $folderPath
    $files = Get-ChildItem -File -Path $folderPath

    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Index of $folderPath</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .icon { width: 32px; height: 32px; }
    </style>
</head>
<body>
    <h1>Index of $folderPath</h1>
    <ul>
"@

    foreach ($dir in $subDirs) {
        $htmlContent += "<li><a href='$($dir.Name)/index.html'>$($dir.Name)/</a></li>`n"
    }

    foreach ($file in $files) {
        if ($file.Extension -eq ".png" -or $file.Extension -eq ".svg") {
            $htmlContent += "<li><a href='$($file.Name)'><img src='$($file.Name)' class='icon' alt='$($file.Name)'> $($file.Name)</a></li>`n"
        } else {
            $htmlContent += "<li><a href='$($file.Name)'>$($file.Name)</a></li>`n"
        }
    }

    $htmlContent += @"
    </ul>
</body>
</html>
"@

    $indexPath = Join-Path -Path $folderPath -ChildPath "index.html"
    $htmlContent | Out-File -FilePath $indexPath -Encoding utf8

    foreach ($dir in $subDirs) {
        Generate-IndexHtml -folderPath $dir.FullName
    }
}

function Generate-IndexMarkdown {
    param (
        [string]$folderPath
    )

    $subDirs = Get-ChildItem -Directory -Path $folderPath
    $files = Get-ChildItem -File -Path $folderPath

    $folderName = Split-Path -Leaf $folderPath
    $markdownContent = "# Index of $folderName`n`n"

    if ($subDirs.Count -gt 0) {
        $markdownContent += "## Directories`n`n"
        foreach ($dir in $subDirs) {
            $markdownContent += "- 📁 [$($dir.Name)]($($dir.Name)/index.md)`n"
        }
        $markdownContent += "`n"
    }

    if ($files.Count -gt 0) {
        $markdownContent += "## Files`n`n"
        foreach ($file in $files) {
            if ($file.Extension -eq ".png" -or $file.Extension -eq ".svg") {
                $markdownContent += "- ![icon]($($file.Name)) [$($file.Name)]($($file.Name))`n"
            } else {
                $markdownContent += "- 📄 [$($file.Name)]($($file.Name))`n"
            }
        }
    }

    $indexPath = Join-Path -Path $folderPath -ChildPath "index.md"
    $markdownContent | Out-File -FilePath $indexPath -Encoding utf8

    foreach ($dir in $subDirs) {
        Generate-IndexMarkdown -folderPath $dir.FullName
    }
}

# Use $PSScriptRoot to refer to the script's directory
Generate-IndexHtml -folderPath $PSScriptRoot
Generate-IndexMarkdown -folderPath $PSScriptRoot

Write-Host "Index files generated successfully!" -ForegroundColor Green
Write-Host "HTML: index.html files created in each directory" -ForegroundColor Cyan
Write-Host "Markdown: index.md files created in each directory" -ForegroundColor Cyan
