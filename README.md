# PSRobo
Powershell-Robocopy

Welcome to PSRobo, this takes the guess work out of RoboCopy command line arguments.

Copying
.\PSRobo.ps1 
             -Operation Copy 
             -CACLs (if needing NTFS file level permissions) 
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE
             -Target DriveLetter:\FOLDER1\FOLDER2\PARENT

Moving 
.\PSRobo.ps1 
             -Operation Move 
             -CACLs (if needing NTFS file level permissions) 
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE 
             -Target DriveLetter:\FOLDER1\FOLDER2\PARENT

Deleting 
.\PSRobo.ps1 
             -Operation DELTREE (Recursively delete Source directory and files)
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE
