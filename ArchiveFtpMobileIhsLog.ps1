$HOSTNAME=hostname
$LastCharacter=$HOSTNAME[-1]
$Yesterday=[datetime]::Today.AddDays(-1)
$Yesterday=$Yesterday.Year.ToString() + "." + $Yesterday.Month.ToString() + "." + $Yesterday.Day.ToString()
$ErrorActionPreference='silentlycontinue'

if ($LastCharacter -eq "P" ) {
  $DaysToRemove=30
} elseif ($LastCharacter -eq "T" ) {
  $DaysToRemove=5
} else {
  Write-Output "Make sure run this in the right server !!!"
  exit
}


Remove-Item C:\ihslog\FTP\*
mkdir C:\ihslog\FTP\$WAS
Set-Location C:\ihslog


# param([string] $log_filename)

function rotate_file([string] $log_filename) {
  $oldfile=$log_filename
  $newfile=$oldfile.ToString() + "." + $Yesterday.ToString()
  Copy-Item $oldfile $newfile
  Compress-Archive .\$newfile -DestinationPath .\$newfile.zip
  Remove-Item $newfile
  Clear-Content $oldfile
}


rotate_file "http_plugin.log"
rotate_file "error.log"
rotate_file "ssl_error.log"
rotate_file "access.log"
rotate_file "ssl_access.log"

Copy-Item *$Yesterday*zip C:\ihslog\FTP
Get-ChildItem -Path C:\ihslog -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddDays(-$DaysToRemove) } | Remove-Item -Force


  # cd /ihslog
  # tar -cvf ./${HOSTNAME}_IHSLOG_${Yesterday}.tar FTP
  # mv ${HOSTNAME}_IHSLOG_${Yesterday}.tar FTP

  # ###    ftp -inv < /home/ihsadmin/ftp.cfg > /home/ihsadmin/ftp.out

  # /home/ihsadmin/ftp_used.sh >/home/ihsadmin/temp.ftp.cfg
  # ftp -inv </home/ihsadmin/temp.ftp.cfg >/home/ihsadmin/ftp.out
  # rm /home/ihsadmin/temp.ftp.cfg