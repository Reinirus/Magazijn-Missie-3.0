$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$port = 8765
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
} catch {
    Write-Host "Poort $port is al in gebruik. Open http://localhost:$port" -ForegroundColor Yellow
    Start-Process "http://localhost:$port"
    Read-Host "Druk op Enter om dit venster te sluiten"
    exit
}

Write-Host "Magazijn Missie draait zonder internet." -ForegroundColor Green
Write-Host "Laat dit venster open tijdens de les. Sluit het venster om te stoppen."
Start-Process "http://localhost:$port"

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'text/javascript; charset=utf-8'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.txt'  = 'text/plain; charset=utf-8'
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $relative = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
        if ([string]::IsNullOrWhiteSpace($relative)) { $relative = 'index.html' }
        $file = [System.IO.Path]::GetFullPath((Join-Path $root $relative))
        if (-not $file.StartsWith($root) -or -not (Test-Path $file -PathType Leaf)) {
            $context.Response.StatusCode = 404
            $context.Response.Close()
            continue
        }
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $extension = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
        $context.Response.ContentType = if ($mime.ContainsKey($extension)) { $mime[$extension] } else { 'application/octet-stream' }
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $context.Response.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
