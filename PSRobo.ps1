param (
       [ValidateSet('Help','Copy','Move','DELTREE','GUI')]
       [Parameter(
                  Position=0,
                  HelpMessage='Enter either: Help, Copy, Move, DELTREE, GUI'
                  )] 
       [string] $Operation='GUI',
       [Parameter(Position=1)][switch] $CACLs,
       [Parameter(Position=2)][int] $DaysOld,
       [Parameter(Position=3)][int] $DaysNew,
       [Parameter(Position=4)][string] 
       [ValidateScript({(Test-Path $_) -eq $true})]
       $Source,
       [Parameter(Position=5)][string] 
       [ValidateScript({($Operation -match 'Copy') -or ($Operation -match 'Move')})]
       $Target
       ) 

# Author Brad Lape, RackSquared
Write-Host 'Welcome to PSRobo, this takes the guess work out of RoboCopy command line arguments.' -ForegroundColor Green
Write-Host ' '

# Functions
    # check if ISE is running and check if Interactive to suggest command line help
    function Test-Interactive
    {
        <#
        .Synopsis
        Determines whether both the user and process are interactive.
        #>

        [CmdletBinding()] Param()
        [Environment]::UserInteractive -and
        !([Environment]::GetCommandLineArgs() |? {$_ -ilike '-NonI*'})
    }

    If ((!$psISE) -or ((Test-Interactive) -eq $False) -and ($Operation -match 'GUI')) {
                                                                                       $Operation = 'Help'
                                                                                       }

    # Changing target folder based on whether the target is just a drive letter or a directory
    Function Robo-Target {
                          If (([bool]($drives | Select-String -Pattern $Target.Replace('\','')) -eq $true) -or ([bool]($drives | Select-String -Pattern $Source.Replace('\','')) -eq $true)) {$script:robotarget = $Target}
                                                                                                                                                                                                                           Else {$script:robotarget = "$Target\$leaf"}
                          }

    # Clear all variables Function
    Function Clear-Vars {
                         $ErrorActionPreference = 'SilentlyContinue' # to suppress console error output when variables are not set
                         (Get-Variable).Name | ForEach-Object {clv $_ -Force -ErrorAction SilentlyContinue}
                         $ErrorActionPreference = 'Continue' # back to default
                         }
    
    # PSRobo Operation GUI
    Function ROBOop {
                                               [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
                                               [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    
                                               # Set the size of your form
                                               $Form = New-Object System.Windows.Forms.Form
                                               $Form.width = 500
                                               $Form.height = 400
                                               $Form.Text = ”RoboCopy Operation Selection"
 
                                               # Set the font of the text to be used within the form
                                               $Font = New-Object System.Drawing.Font("Times New Roman",12)
                                               $Form.Font = $Font
 
                                               # Create a group that will contain your radio buttons
                                               $MyGroupBox = New-Object System.Windows.Forms.GroupBox
                                               $MyGroupBox.Location = '40,10'
                                               $MyGroupBox.size = '400,150'
                                               $MyGroupBox.text = "Choose which operation to perform:"
    
                                               # Create the collection of radio buttons
                                               $RadioButton1 = New-Object System.Windows.Forms.RadioButton
                                               $RadioButton1.Location = '20,35'
                                               $RadioButton1.size = '350,20'
                                               $RadioButton1.Checked = $false 
                                               $RadioButton1.Text = "Copy"
 
                                               $RadioButton2 = New-Object System.Windows.Forms.RadioButton
                                               $RadioButton2.Location = '20,65'
                                               $RadioButton2.size = '350,20'
                                               $RadioButton2.Checked = $false
                                               $RadioButton2.Text = "Move"

                                               $RadioButton3 = New-Object System.Windows.Forms.RadioButton
                                               $RadioButton3.Location = '20,95'
                                               $RadioButton3.size = '350,20'
                                               $RadioButton3.Checked = $false
                                               $RadioButton3.Text = "Delete"
                                               
                                               $RadioButton4 = New-Object System.Windows.Forms.RadioButton
                                               $RadioButton4.Location = '20,125'
                                               $RadioButton4.size = '350,20'
                                               $RadioButton4.Checked = $true
                                               $RadioButton4.Text = "Command line usage help"
                                               
                                                
                                               $chkACLs = New-Object Windows.Forms.checkbox 
                                               $chkACLs.Location = '60,160'
                                               $chkACLs.Width = 280; $chkACLs.Top = 160
                                               $chkACLs.Text = "Copy ACLs" 
                                               $chkACLs.Checked = $true
                                               $chkACLs.TabIndex = 2 
                                               $form.Controls.Add($chkACLs)
                                               
                                               
                                               $lblDO = New-Object System.Windows.Forms.Label   
                                               $lblDO.Text = "Number of Days Old(er):"  
                                               $lblDO.Top = 195 ; $lblDO.Left = 60; $lblDO.Width=50 ;$lblDO.AutoSize = $true 
                                               $form.Controls.Add($lblDO) 
                                               $txtDO = New-Object Windows.Forms.TextBox  
                                               $txtDO.TabIndex = 0 
                                               $txtDO.Top = 195; $txtDO.Left = 240; $txtDO.Width = 40;  
                                               [int]$txtDO.Text = 
                                               $form.Controls.Add($txtDO)     
                                               
                                               $lblDN = New-Object System.Windows.Forms.Label   
                                               $lblDN.Text = "Number of Days New(er):"  
                                               $lblDN.Top = 220 ; $lblDN.Left = 60; $lblDN.Width=50 ;$lblDN.AutoSize = $true 
                                               $form.Controls.Add($lblDN) 
                                               $txtDN = New-Object Windows.Forms.TextBox  
                                               $txtDN.TabIndex = 0 
                                               $txtDN.Top = 220; $txtDN.Left = 240; $txtDN.Width = 40;  
                                               [int]$txtDN.Text = 
                                               $form.Controls.Add($txtDN) 
                                               
                                               # Add an OK button
                                               # Thanks to J.Vierra for simplifing the use of buttons in forms
                                               $OKButton = new-object System.Windows.Forms.Button
                                               $OKButton.Location = '130,250'
                                               $OKButton.Size = '100,40' 
                                               $OKButton.Text = 'OK'
                                               $OKButton.DialogResult=[System.Windows.Forms.DialogResult]::OK
 
                                               #Add a cancel button
                                               $CancelButton = new-object System.Windows.Forms.Button
                                               $CancelButton.Location = '255,250'
                                               $CancelButton.Size = '100,40'
                                               $CancelButton.Text = "Cancel"
                                               $CancelButton.DialogResult=[System.Windows.Forms.DialogResult]::Cancel
 
                                               # Add all the Form controls on one line 
                                               $form.Controls.AddRange(@($MyGroupBox,$OKButton,$CancelButton))
 
                                               # Add all the GroupBox controls on one line
                                               $MyGroupBox.Controls.AddRange(@($Radiobutton1,$RadioButton2,$RadioButton3,$RadioButton4))
    
                                               # Assign the Accept and Cancel options in the form to the corresponding buttons
                                               $form.AcceptButton = $OKButton
                                               $form.CancelButton = $CancelButton
 
                                               # Activate the form
                                               $form.Add_Shown({$form.Activate()})    
    
                                               # Get the results from the button click
                                               $dialogResult = $form.ShowDialog()
 
                                               # If the OK button is selected
                                               if ($dialogResult -eq "OK"){
                                                                           # Check the current state of each radio button and respond accordingly
                                                                           if ($RadioButton1.Checked){$script:Operation = 'Copy'}
                                                                           elseif ($RadioButton2.Checked){$script:Operation = 'Move'}
                                                                           elseif ($RadioButton3.Checked){$script:Operation = 'DELTREE'}
                                                                           elseif ($RadioButton4.Checked = $true){$script:Operation = 'Help'}
                                                                           if (($chkACLs.Checked) -and ($RadioButton3.Checked -eq $false)) {
                                                                                                                                            $script:CACLs = $true
                                                                                                                                            }
                                                                                                                                            Else {
                                                                                                                                                  $script:CACLs = $null
                                                                                                                                                  }
                                                                           if ($txtDO.Text -gt 0) {$script:DaysOld = $txtDO.Text}
                                                                                                                                Else {
                                                                                                                                      $script:DaysOld = $null
                                                                                                                                      }
                                                                           if ($txtDN.Text -gt 0) {$script:DaysNew = $txtDN.Text}
                                                                                                                                Else {
                                                                                                                                      $script:DaysNew = $null
                                                                                                                                      }
                                                                           }
                                               if ($dialogResult -eq "Cancel") {
                                                                                Write-Host 'Cancel was pressed, terminating script!' -ForegroundColor Red
                                                                                Start-Sleep 5
                                                                                Clear-Vars
                                                                                exit
                                                                                }
                                               }

# prerequesites
$datetime = (Get-Date).DateTime
If ((Test-Interactive) -eq $False) {$path2script = $pwd.Path.ToString()}
If ((Test-Interactive) -eq $True) {$path2script = Split-Path $script:MyInvocation.MyCommand.Path}
$scriptname = $MyInvocation.MyCommand.Name -Replace ('.ps1','')
$drives = (Get-WmiObject Win32_Logicaldisk).DeviceID
$ROBOargs = New-Object System.Collections.Arraylist
$ROBOargs.AddRange(@("/S","/A-:RASH","/FP","/XJD","/XO","/R:1","/W:1","/MT:20","/TEE","/V"))
# extra Junction point switches "/XJF","/XJ"

# lauching RoboCopy Operation selection box
If ($Operation -match 'GUI') {
                              ROBOop
                              }

Switch ($Operation) {
                     'Help' {
Write-Host 'PowerShell Command Line Usage:' -ForegroundColor Green
Write-Host ' '
Write-Host 'Copying
.\PSRobo.ps1 
             -Operation Copy 
             -CACLs (if needing NTFS file level permissions) 
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE
             -Target DriveLetter:\FOLDER1\FOLDER2\PARENT
' -ForegroundColor DarkYellow
Write-Host 'Moving 
.\PSRobo.ps1 
             -Operation Move 
             -CACLs (if needing NTFS file level permissions) 
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE 
             -Target DriveLetter:\FOLDER1\FOLDER2\PARENT
' -ForegroundColor DarkYellow
Write-Host 'Deleting 
.\PSRobo.ps1 
             -Operation DELTREE (Recursively delete Source directory and files)
             -DaysOld 1095 (if only needing +3yr old data or older)
             -DaysNew 3 (if only needing 3 day old data or newer) 
             -Source DriveLetter:\FOLDER1\FOLDER2\PARENT\SOURCE 
' -ForegroundColor DarkYellow

                             clv datetime,path2script,scriptname,ROBOargs -Force -ErrorAction SilentlyContinue
                             exit
                             }

                     'Move' {
                             $ROBOargs.Add("/MOVE") | Out-Null
                             $ROBOargs.Add("/XF *.lnk") | Out-Null          
                             }

                     'DELTREE' {
                                New-Item -ItemType Directory -Path "$path2script\PURGE" -Force | Out-Null
                                $ROBOargs.Add("/E") | Out-Null
                                $ROBOargs.Add("/MOVE") | Out-Null
                                $ROBOargs.Add("/CREATE") | Out-Null
                                $ROBOargs.Add("/PURGE") | Out-Null
                                $robotarget = "$path2script\PURGE"
                                }
                     }
If ($CACLs -eq $True) {$ROBOargs.Add("/COPYALL") | Out-Null}
If ($DaysOld -gt '0') {$ROBOargs.Add("/MinAge:$DaysOld") | Out-Null}
If ($DaysNew -gt '0') {$ROBOargs.Add("/MaxAge:$DaysOld") | Out-Null} 

# functions
Function Get-Folder {
                     Param (
                            [parameter(Mandatory=$true)]
                            [alias('Source','Target')]
                            $destination
                            )
                     
                     If ($destination -match 'Target') {$option = $true}          
                     Add-Type -AssemblyName System.Windows.Forms
                     $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                                                                                                      Description = "Select a $destination"
                                                                                                      SelectedPath = "$path2script"
                                                                                                      ShowNewFolderButton = $option
                                                                                                      }
                     [void]$FolderBrowser.ShowDialog()
                     $FolderBrowser.SelectedPath
                     }

# getting source folder if not declared on CLI arguments
If (!$Source) {
               Write-Host 'Select SOURCE path:' -ForegroundColor Green
               Do {$Source = Get-Folder -destination Source} Until ((Test-Path $Source))
               }

    # checking if source is only just a drive letter or not
If ([bool]($drives | Select-String -Pattern $Source.Replace('\','')) -eq $true) {$leaf = $Source.Replace(':','').Replace('\','')+'_drive'}
                                                                                                                                         Else {$leaf = Split-Path $Source -Leaf}

# getting target folder if not declared on CLI arguments
If (($Operation -notmatch 'DELTREE') -and (!$Target)) {
                                                       Write-Host 'Select TARGET path (parent):' -ForegroundColor Green
                                                       Do {$Target = Get-Folder -destination Target} Until ($Target)
                                                       If ($Target -match $leaf) {
                                                                                  Write-Host 'Choose PARENT target folder instead!' -ForegroundColor Red
                                                                                  Write-Host ' '
                                                                                  clv Source -Force -ErrorAction SilentlyContinue
                                                                                  $Target = Get-Folder -destination Source
                                                                                  }
               
                                                       }
If ($Operation -notmatch 'DELTREE') {Robo-Target}

# Declaring Source and Target to console
Write-Host ' '
Write-Host "Source is: $Source" -ForegroundColor Green
Write-Host ' '
Write-Host "Target is: $robotarget" -ForegroundColor Green
Write-Host ' '

If ((!$Source) -or (!$Target) -and ($Operation -notmatch 'DELTREE')) {
                                                                      Write-Host 'Source or Target is NULL, terminating script!' -ForegroundColor Red
                                                                      Start-Sleep 5
                                                                      Clear-Vars
                                                                      Exit
                                                                      }

# Starting Robocopy in 10....1
$secondsRunning = 0;  
Write-Output "Robocopy starting in.... *CTRL+Break to abort*"
while( (-not $Host.UI.RawUI.KeyAvailable) -and ($secondsRunning -lt 10) ){
                                                                          Write-Host (10-$secondsRunning)
                                                                          Start-Sleep -Seconds 1
                                                                          $secondsRunning++
                                                                         }

# logging script name, user, host and date
echo "PowerShell script $scriptname run by $env:USERNAME on host name $env:COMPUTERNAME on this date: $datetime" | Out-File -FilePath $path2script\$leaf.log -Encoding utf8 -Append

# starting RoboCopy
robocopy ""$Source"" ""$robotarget"" $ROBOargs /LOG+:""$path2script\$leaf.log""

# cleanup
ii "$path2script\$leaf.log"
If ("$path2script\PURGE") {Remove-Item "$path2script\PURGE" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null}
Clear-Vars