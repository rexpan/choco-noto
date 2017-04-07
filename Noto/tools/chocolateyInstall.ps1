function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

$fontHelpersPath = (Join-Path (Get-CurrentDirectory) 'FontHelpers.ps1')
. $fontHelpersPath

$fontUrl = 'https://noto-website.storage.googleapis.com/pkgs/Noto-hinted.zip'
$checksumType = 'sha256';
$checksum = 'D5E5BACE69570F348228E864444155657C1E7ECA50857B9DE4981FBD9B5122DD';

$destination = Join-Path $Env:Temp 'NotoFonts'

Install-ChocolateyZipPackage -PackageName 'NotoFonts' -url $fontUrl -unzipLocation $destination -ChecksumType "$checksumType" -Checksum "$checksum"

$shell = New-Object -ComObject Shell.Application
$fontsFolder = $shell.Namespace(0x14)

$fontFiles = (Get-ChildItem $destination -Recurse -Filter *.otf) +
             (Get-ChildItem $destination -Recurse -Filter *.ttf)

$fss = for($i=0; $i -lt $fontFiles.length; $i+=10){
    ,($fontFiles[$i .. ($i+9)])
}

for($i=0; $i -lt $fss.length; $i+=1){
    $fs = $fss[$i];

    # unfortunately the font install process totally ignores shell flags :(
    # http://social.technet.microsoft.com/Forums/en-IE/winserverpowershell/thread/fcc98ba5-6ce4-466b-a927-bb2cc3851b59
    # so resort to a nasty hack of compiling some C#, and running as admin instead of just using CopyHere(file, options)
    $commands = $fs |
    % { Join-Path $fontsFolder.Self.Path $_.Name } |
    ? { Test-Path $_ } |
    % { "Remove-SingleFont '$_' -Force;" }

    # http://blogs.technet.com/b/deploymentguys/archive/2010/12/04/adding-and-removing-fonts-with-windows-powershell.aspx
    $fs |
    % { $commands += "Add-SingleFont '$($_.FullName)';" }

    $toExecute = ". $fontHelpersPath;" + ($commands -join ';')
    Start-ChocolateyProcessAsAdmin $toExecute
}

Remove-Item $destination -Recurse


