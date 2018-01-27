#DVR Processor Script
#Compares contents of folder which is the output of MCEBuddy against the original file.
#If the files video length are significantly different implying adverts have been removed, moves the new video to Movies folder for Plex and deletes original file from DVR.
$DVRMoviesPath = "";#Path of folder that records DVR Movies
$DVRProcessorPath = "";#Path of oflder that MCEBuddy outputs to
$FFMPEGPath = "";#Path of folder containning FFMEPG.exe
$MoviesPath="";#Path to copy movies to after
$TimeDifference = 60;#Limit for manual error checking


try {
$file=Get-ChildItem $DVRProcessorPath -Filter *.mkv -File|% {$_.BaseName}|Select -first 1; #Get filename
}catch{
echo "Path not found";
exit;
}

if($file -eq $null){
echo "No file found";
exit;
}

$newTime = (& ${FFMPEGPath}"ffprobe.exe" -i ${DVRProcessorPath}${file}".mkv" -show_entries format=duration -v quiet -of csv="p=0") | Out-String;#Get time of encoded file
$oldTime = (& ${FFMPEGPath}"ffprobe.exe" -i ${DVRMoviesPath}${file}"\"${file}".ts" -show_entries format=duration -v quiet -of csv="p=0") | Out-String;#Get time of unencoded file
$timeDifference = $oldTime-$newTime;#Find difference in time

if ($timeDifference -gt 60){
Move-Item "${DVRProcessorPath}${file}.mkv" "${MoviesPath}";#Move new file to Movies library
Remove-Item "${DVRMoviesPath}${file}" -Recurse;#Remove original file
echo "Adverts removed for ${file}";
}else{
Move-Item "${DVRProcessorPath}${file}.mkv" "${DVRProcessorPath}Manual Check\";#Move to extra folder for manual checking
    if($oldTime -eq $null){
    echo "Original file not found";
}
echo "Manual checking required for ${file}";
}
