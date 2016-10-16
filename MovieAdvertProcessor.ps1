#DVR Processor Script
#Compares contents of folder which is the output of MCEBuddy against the original file.
#If the files video length are significantly different implying adverts have been removed, moves the new video to Movies folder for Plex and deletes original file from DVR.
$DVRMoviesPath = "M:\DVR Movies\";
$DVRProcessorPath = "M:\DVR Processor\";
$FFMPEGPath = "D:\Users\Sam\Desktop\ffmpeg\bin\";
$MoviesPath="M:\Movies\May Contain Adverts\";



$file=Get-ChildItem $DVRProcessorPath -Filter *.mkv -File|% {$_.BaseName}|Select -first 1; #Get filename
$newTime = (& ${FFMPEGPath}"ffprobe.exe" -i ${DVRProcessorPath}${file}".mkv" -show_entries format=duration -v quiet -of csv="p=0") | Out-String;#Get time of encoded file
$oldTime = (& ${FFMPEGPath}"ffprobe.exe" -i ${DVRMoviesPath}${file}"\"${file}".ts" -show_entries format=duration -v quiet -of csv="p=0") | Out-String;#Get time of unencoded file
$timeDifference = $oldTime-$newTime;#Find difference in time
if ($timeDifference -gt 60){
Move-Item "${DVRProcessorPath}${file}.mkv" "${MoviesPath}";
Remove-Item "${DVRMoviesPath}${file}" -Recurse;
echo "Adverts removed for ${file}";
}else
{
Move-Item "${DVRProcessorPath}${file}.mkv" "${DVRProcessorPath}Manual Check\";
echo "Manual checking removed for ${file}";
}