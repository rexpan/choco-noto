$fontUrl = 'https://noto-website-2.storage.googleapis.com/pkgs/Noto-hinted.zip'
$checksumType = 'sha256';
$checksum = '837B4A9352FCE32AD7F298FBF155AF1DA5B6F3F8DBD995EB63FDD8E82117E4AE';

$destination = Join-Path $Env:Temp 'NotoFonts'

Install-ChocolateyZipPackage -PackageName 'NotoFonts' -url $fontUrl -unzipLocation $destination -ChecksumType "$checksumType" -Checksum "$checksum"

$FontFiles = (
  (Get-ChildItem $destination -Include '*.otf' -Recurse) +
  (Get-ChildItem $destination -Include '*.ttf' -Recurse)
  ) | Select-Object -ExpandProperty FullName

$Installed = Add-Font $FontFiles -Multiple

If ($Installed -eq 0) {
   Throw 'All font installation attempts failed!'
} elseif ($Installed -lt $FontFiles.count) {
   Write-Host "$Installed fonts were installed." -ForegroundColor Cyan
   Write-Warning "$($FontFiles.count - $Installed) submitted font paths failed to install."
} else {
   Write-Host "$Installed fonts were installed."
}

Remove-Item $destination -Recurse
