Add-Type -AssemblyName System.IO.Compression
$zipPath = "c:\Users\abdul\OneDrive\Desktop\Comp Lang NEW\ISD-TV-Display-System\ISD-TV-Display-System\display\bootanimation.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $null = $zip.CreateEntryFromFile("c:\Users\abdul\OneDrive\Desktop\Comp Lang NEW\ISD-TV-Display-System\ISD-TV-Display-System\display\temp_boot\desc.txt", "desc.txt", [System.IO.Compression.CompressionLevel]::NoCompression)
    $null = $zip.CreateEntryFromFile("c:\Users\abdul\OneDrive\Desktop\Comp Lang NEW\ISD-TV-Display-System\ISD-TV-Display-System\display\temp_boot\part0\000.png", "part0/000.png", [System.IO.Compression.CompressionLevel]::NoCompression)
} finally {
    $zip.Dispose()
}
