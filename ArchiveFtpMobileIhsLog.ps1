$HOSTNAME=hostname
$LastCharacter=$HOSTNAME[-1]
$Today=[datetime]::Today
$Yesterday=[datetime]::Today.AddDays(-1)


if ($LastCharacter -eq "P" ) {
  $DaysToRemove=30
} elseif ($LastCharacter -eq "C" ) {
  $DaysToRemove=5
} else {
  echo "Make sure run this in the right server !!!"
  exit
}


Remove-Item C:\ihslog\FTP\*
mkdir C:\ihslog\FTP\$WAS
Set-Location C:\ihslog


# param([string] $log_filename)

function rotate_file([string] $log_filename) {
  $oldfile=$log_filename
  $newfile=$oldfile.$Yesterday
  Copy-Item $oldfile $newfile
  Compress-Archive .\$oldfile -DestinationPath .\$oldfile.zip
  >$oldfile
}

$p1 = rotate_file "http_plugin.log"



