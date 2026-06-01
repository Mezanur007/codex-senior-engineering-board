param(
    [string]$Root = ".",
    [int]$LargeFileLines = 500
)

$ErrorActionPreference = "Stop"
$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$ignoredDirectoryNames = @(".git", "node_modules", "vendor", "dist", "build", ".next", ".turbo", "coverage", "target", ".venv", "venv", "__pycache__")

function Test-IgnoredPath {
    param([string]$Path)
    $relative = Get-RelativePath $Path
    $parts = $relative -split '[\\/]+'
    foreach ($part in $parts) {
        if ($ignoredDirectoryNames -contains $part) {
            return $true
        }
    }
    return $false
}

function Get-RelativePath {
    param([string]$Path)
    $rootPath = $resolvedRoot
    if (-not $rootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $rootPath = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    }
    $rootUri = New-Object System.Uri($rootPath)
    $pathUri = New-Object System.Uri($Path)
    $relativeUri = $rootUri.MakeRelativeUri($pathUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

$files = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force |
    Where-Object { -not (Test-IgnoredPath $_.FullName) }

$manifestNames = @(
    "package.json", "pnpm-lock.yaml", "yarn.lock", "package-lock.json",
    "composer.json", "requirements.txt", "pyproject.toml", "Pipfile",
    "Gemfile", "go.mod", "Cargo.toml", "pom.xml", "build.gradle",
    "pubspec.yaml", "Dockerfile", "docker-compose.yml", "docker-compose.yaml",
    "firebase.json", "vercel.json", "netlify.toml", "next.config.js", "next.config.mjs"
)

$ciPatterns = @(".github/workflows", ".gitlab-ci.yml", "azure-pipelines.yml", "Jenkinsfile")
$testPattern = '(?i)(test|spec|__tests__|tests)'
$todoPattern = '(TODO|FIXME|HACK|XXX)'
$secretPattern = '(?i)(api[_-]?key|secret|password|passwd|token|private[_-]?key|client[_-]?secret|connection[_-]?string)\s*[:=]'

Write-Output "# Repo Snapshot"
Write-Output ""
Write-Output "Root: $resolvedRoot"
Write-Output "Generated: $(Get-Date -Format s)"
Write-Output ""

Write-Output "## File Counts By Extension"
$files |
    Group-Object { if ($_.Extension) { $_.Extension.ToLowerInvariant() } else { "[no extension]" } } |
    Sort-Object Count -Descending |
    Select-Object -First 30 |
    ForEach-Object { Write-Output ("- {0}: {1}" -f $_.Name, $_.Count) }
Write-Output ""

Write-Output "## Important Manifests And Config"
$manifestFiles = $files | Where-Object { $manifestNames -contains $_.Name }
if ($manifestFiles) {
    $manifestFiles | Sort-Object FullName | ForEach-Object { Write-Output ("- " + (Get-RelativePath $_.FullName)) }
} else {
    Write-Output "- None found"
}
Write-Output ""

Write-Output "## CI And Deployment Files"
$ciFiles = $files | Where-Object {
    $relative = Get-RelativePath $_.FullName
    foreach ($pattern in $ciPatterns) {
        if ($relative -like "$pattern*") { return $true }
        if ($_.Name -eq $pattern) { return $true }
    }
    return $false
}
if ($ciFiles) {
    $ciFiles | Sort-Object FullName | ForEach-Object { Write-Output ("- " + (Get-RelativePath $_.FullName)) }
} else {
    Write-Output "- None found"
}
Write-Output ""

Write-Output "## Test Files"
$testFiles = $files | Where-Object { (Get-RelativePath $_.FullName) -match $testPattern }
Write-Output ("- Count: {0}" -f $testFiles.Count)
$testFiles | Sort-Object FullName | Select-Object -First 30 | ForEach-Object { Write-Output ("- " + (Get-RelativePath $_.FullName)) }
if ($testFiles.Count -gt 30) { Write-Output ("- ... {0} more" -f ($testFiles.Count - 30)) }
Write-Output ""

Write-Output "## Large Files"
$largeFiles = foreach ($file in $files) {
    $lineCount = 0
    try {
        $lineCount = (Get-Content -LiteralPath $file.FullName -ReadCount 1000 -ErrorAction Stop | Measure-Object -Line).Lines
    } catch {
        continue
    }
    if ($lineCount -ge $LargeFileLines) {
        [PSCustomObject]@{ Path = (Get-RelativePath $file.FullName); Lines = $lineCount }
    }
}
if ($largeFiles) {
    $largeFiles | Sort-Object Lines -Descending | Select-Object -First 30 | ForEach-Object {
        Write-Output ("- {0} lines: {1}" -f $_.Lines, $_.Path)
    }
} else {
    Write-Output "- None found at threshold $LargeFileLines lines"
}
Write-Output ""

Write-Output "## TODO / FIXME Markers"
$todoMatches = foreach ($file in $files) {
    try {
        Select-String -LiteralPath $file.FullName -Pattern $todoPattern -AllMatches -ErrorAction Stop |
            ForEach-Object { [PSCustomObject]@{ Path = (Get-RelativePath $_.Path); Line = $_.LineNumber; Marker = $_.Matches[0].Value } }
    } catch {
        continue
    }
}
if ($todoMatches) {
    $todoMatches | Select-Object -First 50 | ForEach-Object {
        Write-Output ("- {0}:{1} [{2}]" -f $_.Path, $_.Line, $_.Marker)
    }
    if ($todoMatches.Count -gt 50) { Write-Output ("- ... {0} more" -f ($todoMatches.Count - 50)) }
} else {
    Write-Output "- None found"
}
Write-Output ""

Write-Output "## Possible Secret Assignments"
Write-Output "Values are intentionally not printed."
$secretMatches = foreach ($file in $files) {
    try {
        Select-String -LiteralPath $file.FullName -Pattern $secretPattern -AllMatches -ErrorAction Stop |
            ForEach-Object { [PSCustomObject]@{ Path = (Get-RelativePath $_.Path); Line = $_.LineNumber } }
    } catch {
        continue
    }
}
if ($secretMatches) {
    $secretMatches | Select-Object -First 50 | ForEach-Object {
        Write-Output ("- {0}:{1}" -f $_.Path, $_.Line)
    }
    if ($secretMatches.Count -gt 50) { Write-Output ("- ... {0} more" -f ($secretMatches.Count - 50)) }
} else {
    Write-Output "- None found"
}
