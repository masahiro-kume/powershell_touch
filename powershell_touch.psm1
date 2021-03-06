#########################################################
## powershell touch funtion Touch_Item                 ##
## Last Edit : May 8th, 2022                           ##
#########################################################

function Touch_Item(){
    <#
    .SYNOPSIS
        UNIX 'touch' command with some extensions

        Touch_Item [-acm] [-r file] [(-t)|(-d) '[[CC]YY]MMDDhhmm[.SS]'|'Windows-DateTime-String'] [-Recurse] file ...

           returns FileInfo/DirectoryInfo(Array) not boolean(0|1).
           makes NewFiles with specifed Extension from the template folder.
           supports [-Recurse] Action into SubFolders.

    .DESCRIPTION
    Imitated to  https://www.freebsd.org/cgi/man.cgi?query=touch
    But, some default actions are differnt from 'touch', so read carefully who are familiar with UNIX/Linux commands.
        * Returns FileInfo|DirectoryInfo(or those array), but not boolean(0|1).
        * Returns $null when nothing did (or everything errors).
        * -A and -h switches are not supported.
        * Rewrites ONLY modification times (LastWriteTime) by default.
        * Creates NOT-ZERO-LENGTH files if new files's extension matches templates' extension.
        * Windows-DateTime-String
            is allowed any string that can be parsed by Get-Date() such as '61Jun25' and/or '2022-05-07T17:17:00' &c.
        * Works with Wild-Card(*).
        * Creates new Directory. (template directories must be prepared)
        * Recurse action is avalable.
        * If some errors occur in action, basically those are ignored,
            and shows each inline-commandlet's error message.

    [DESCRIPTION]
     The touch utility sets the	modification and access times of files. 
     If any file does not exist, it is created with default permissions.
     '~/PwshNew' is a special folder that contains 'Template.EXT's.
     Put blank data files such as 'Template.xlsx' as templates in that folder.
 
     By default, Touch_Item changes only modification times.
     The -a and -m flags may be used to select the access time (LastAccessTime) or the modification time (LastWriteTime) individually.
     Selecting both is not available. (the latest switch has priority).
     By default, the timestamps are set to the current time.
     The -d and -t flags expliitly specify a different time, and the -r flag specifies to set the times those of the specified file.


     The following options are available:

     -a      Change the access time (LastAccessTime) of the file.
             The modification time of the file is not changed.
             The -m flag is not available if this flag setted.

     -c      Do not create the file if it does not exist.

     -d      Change the access and modification	times to the specified datetime instead of the current time of day.
             The argument is of the form Datetime-string which is parsable by Get-Date commandlet.
             A string such as "YYYY-MM-DDThh:mm:SS[.frac][z]" is also available, but [t] option cannot work,
             where the letters represent the following:
                YYYY                At least four decimal digits representing the year.
                MM, DD, hh, mm, SS  As with -t time.
                T                   The letter T or a space is the time designator.
                [.frac]             An optional fraction, consisting of a period followed by one or more digits.
                                    The comma will not work. (depens on The Culture of windows environment)
                [z]                 An optional letter Z indicating the time is in UTC.
                                    Otherwise, the time is assumed to be in local time.
             This flag accepts "[[CC]YY]MMDDhhmm[.SS]" style, so this flag is completely same as -t. 

     -h      This flag is not supported in Touch_Item. (ignored)
             If the file is a symbolic link,
             Touch_Item changes the times of the file that the link points to, rather than the symbolic-link itself.
             (The same result occurs between in FreeBSD and Windows.)
             To implement this option is very complicated in Windows File System, so ommited in this version.

     -m      Change the modification time (LastWriteTime) of the file.
             The access time of the file is not changed.
             When this flag setted, the -a flag is set to $false.

     -r      Use the access and modifications times from the specified file instead of the current time of day.

     -t      Change the access and modification times to the specified time instead of the current time of day.
             The argument is of the form "[[CC]YY]MMDDhhmm[.SS]" where each pair of letters represents the following:
               CC      The first two digits of the year (the century).
               YY      The second two digits of the year.
                       "YYCC" interpretation is different from 'touch' -t.
                       It depens on Get-Date operation. (9 or 999 &c are available in Get-Date.)
               MM      The month of the year, from 01 to 12.
               DD      the day of the month, from 01 to 31.
               hh      The hour of the day, from 00 to 23.
               mm      The minute of the hour, from 00 to 59.
               SS      The second of the minute, from 00 to 60.
             If the "CC" and "YY" letter pairs are not specified, the values default to the current year.
             If the "SS" letter pair is not specified, the value defaults to 0.
             Inner conversion of date-string uses "YYYY/MM/DD hh:mm:SS" format. (Slash and Space separating)
             This flag accepts Datetime-string, so this flag is completely same as -d. 

    [EXIT STATUS]
     The Touch_Item exits with FileInfo|DirectoryInfo( or those array) on success,
     and errors in action are ignored,
     and if nothing did exit with $null.

    .EXAMPLE
    Touch_Item [String]FileName
    Basic Usage:
        Modifys LastWriteTime of the File to Current time.
        If File is not exists, NewFile with length=0 will be created.    
    .EXAMPLE
    Touch_Item FileName FileName ...
    Plural Files:
        Supports plural files.
    .EXAMPLE
    Touch_Item *.tmp
    Wild-card:
        Supports Wild-card.
    .EXAMPLE
    Touch_Item FileName.EXT
    Create files with templates:
        If SOMENAME.EXT exists in ~/PwshNew Folder, Creates a new file from a template file.
        This option is useful when blank data file is not 0-length such as 'NewFile.xlsx'.
        If the template is a folder, the new folder copied form template with it's structure,
        and works into child items recursively.
    .EXAMPLE
    Touch_Item FileName.EXT | ii
    Returns FileInfo:
        Invoke-item with application related extension of new file.
        'Touch_Item NewFile.xlsx | ii' invokes Microsoft(R) Excel for example.
    .EXAMPLE
    Touch_Item -a FileName
    LastAccessTime:
        Changes LastAccessTime instead of LastWriteTime.
    .EXAMPLE
    Touch_Item -c FileName
    Not-Creation Option:
        Not Creat a new file even if it is not exists.
    .EXAMPLE
    Touch_Item -d 'YYYY-MM-DDThh:mm:ss' FileName
    Specifies datetime instead of current time:
        Date string is acceptable in various description.
        See DESCRIPTION in detail.
        Same behavior with -t flag. 
    .EXAMPLE
    Touch_Item -t '[[CC]YY]MMDDhhmm[.SS]' FileName
    Specifies datetime instead of current time:
        Date string is acceptable in various description.
        See DESCRIPTION in detail.
        Same behavior with -d flag. 
    .EXAMPLE
    Touch_Item -r ReferenceFile FileName
    Specifies datetime instead of current time:
        The datetime is read from the refernse file.
    .EXAMPLE
    Touch_Item -Recurse FolderName
    Recurse action into folders:
        If the target item(s) were [Container], Touch_Item works to child items. 
    .LINK
        https://github.com/masahiro-kume
    #>
    enum StampTarget {
        LastWriteTime = 0
        LastAccessTime = 1
    }
    $Recurse = $false
    $StampTarget = [StampTarget]'LastWriteTime'
    $DoNotCreate = $false
    $TargetFiles = @()
    $TargetRecrs = @()
    $i=0
    while($i -lt $args.count){
        $arg = $args[$i]
        if($arg -match "^-"){
            if($arg.ToUpper() -eq '-RECURSE'){
                $Recurse = $true
            }else{
                :labelFor for ($j=1; $j -lt $arg.length; $j++){
                    switch -CaseSensitive ($arg[$j]){
#                       'A' {{$AdjustStr=$args[$i+1];$i++};$DoNotCreate=$true;Break labelFor}
                        'a' {$StampTarget = [StampTarget]'LastAccessTime'}
                        'c' {$DoNotCreate = $true}
#                       'h' {$SymbolicLink = $true}
                        'm' {$StampTarget = [StampTarget]'LastWriteTime'}
                        'r' {if(-not($args[$i+1] -match "^-")){$ReferenceFile=$args[$i+1];$i++};Break labelFor}
                        't' {if(-not($args[$i+1] -match "^-")){[String]$TimeLiteral=$args[$i+1];$i++};Break labelFor}
                        'd' {if(-not($args[$i+1] -match "^-")){[String]$TimeLiteral=$args[$i+1];$i++};Break labelFor}
                    }
                }
            }
        }else{
            $TargetFiles += $arg
        }
        $i++
    }
    $TargetDate = Get-Date
    if($null -ne $TimeLiteral){
        if($TimeLiteral -match "^\d{8,12}(\.\d{1,2})?$"){
            if(-not(($p=$TimeLiteral.IndexOf('.'))+1)){$p=$TimeLiteral.Length}
            $tStr=( $TimeLiteral.Substring(0,$p-8)+"/"+             # [CC[YY]]
                    $TimeLiteral.Substring($p-8,2)+"/"+             # MM
                    $TimeLiteral.Substring($p-6,2)+" "+             # DD
                    $TimeLiteral.Substring($p-4,2)+":"+             # hh
                    $TimeLiteral.Substring($p-2).Replace('.',':'))  # mm[.SS]
            if($tStr -match "^\/"){$tStr = (Get-Date).Year.ToString() + $tStr}
            $TargetDate = Get-Date($tStr)
        }else{
            $TargetDate = Get-Date($TimeLiteral)
        }
    }
    if($null -ne $ReferenceFile){
        if($null -ne ($Ref = Get-ItemProperty $ReferenceFile)){
            $TargetDate = $Ref.$StampTarget
        }
    }
    foreach($myfile in $TargetFiles){
        if(Test-Path $myfile){
            Set-ItemProperty $myfile $StampTarget ($TargetDate)
            $FItem = Get-Item $myfile
            if($Recurse -And $FItem.PSIsContainer){$TargetRecrs+=(Get-ChildItem $FItem -Recurse | ForEach-Object {$_.FullName})}
            Get-Item $FItem
        }elseif(-not($DoNotCreate)){
            $TemplateList=@{}
            $TemplateFolder = "~/PwshNew/"
            if(-not(Test-Path $TemplateFolder)){New-Item $TemplateFolder -type Directory}
            Get-ChildItem $TemplateFolder | ForEach-Object {$TemplateList.Add( ($_.Extension).Trim(".").ToUpper(), $_)}
            $ext=([System.IO.Path]::GetExtension($myfile)).Trim(".").ToUpper()
            $Template = $TemplateList.($ext)
            if ($null -eq $Template) {
                $FItem = New-Item $myfile -type file
                if($null -ne $FItem){
                    Set-ItemProperty $FItem $StampTarget ($TargetDate)
                    Get-Item $FItem
                }
            } else {
                Copy-Item -Path ($Template).FullName -Destination $myfile -Recurse
                $FItem = Get-Item $myfile
                if($null -ne $FItem){
                    Set-ItemProperty $FItem $StampTarget ($TargetDate)
                    if($FItem.PSIsContainer){$TargetRecrs+=(Get-ChildItem $FItem -Recurse | ForEach-Object {$_.FullName})}
                    Get-Item $FItem
                }
            } 
        }
    } 
    foreach($myfile in $TargetRecrs){
        $FItem = Get-Item $myfile
        if($null -ne $FItem){
            Set-ItemProperty $FItem $StampTarget ($TargetDate)
            Get-Item $FItem
        }
    }
}
Set-Alias touch Touch_Item

Export-ModuleMember -Function Touch_Item
Export-ModuleMember -Alias touch