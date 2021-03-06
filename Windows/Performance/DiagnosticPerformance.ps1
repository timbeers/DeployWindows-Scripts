#####
#MainPathBootTime
#MainPathBootTime represents the amount of time that elapses between the time the animated Windows logo first appears on the screen and the time that the desktop appears. Keep in mind that even though the system is usable at this point, Windows is still working in the background loading low-priority tasks.
#BootPostBootTime
#BootPostBootTime represents the amount of time that elapses between the time that the desktop appears and the time that you can actually begin using the system.
#BootTime
#Of course, BootTime is the same value that on the General tab is called Boot Duration. This number is the sum of MainPathBootTime and BootPostBootTime. Something that I didn’t tell you before is that Microsoft indicates that your actual boot time is about 10 seconds less that the recorded BootTime. The reason is that it usually takes about 10 seconds for the system to reach an 80-percent idle measurement at which time the BootPostBootTime measurement is recorded.
#####
$Global:EVENTPATH_Performance = "Microsoft-Windows-Diagnostics-Performance/Operational";
$Global:EVENTFILTER_Boot = @{ "LOGNAME" = $EVENTPATH_Performance; "ID" = 100; };
$Global:EVENTFILTER_BootService = @{ "LOGNAME" = $EVENTPATH_Performance; "ID" = 103; };
$Global:EVENTFILTER_BootDriver = @{ "LOGNAME" = $EVENTPATH_Performance; "ID" = 102; };
$Global:EVENTFILTER_BootApplication = @{ "LOGNAME" = $EVENTPATH_Performance; "ID" = 101; };
$Global:EVENT_Performance = Get-WinEvent -listlog $EVENTPATH_Performance;

If ($EVENT_Performance.IsEnabled -eq $true)
{
    Write-Host
    $Events = Get-WinEvent -FilterHashTable $EVENTFILTER_Boot
    $BootTime = @{};
    $MainPathBootTime = @{};
    $BootPostBootTime = @{};
    $BootNumStartupApps = @{};
    $OSLoaderDuration = @{};
    ForEach ($Event In $Events)
    {
        $xml = [xml]$Event.ToXml();
        # $xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'BootTime'}
        
        $BootTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'BootTime'}).'#text');
        $MainPathBootTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'MainPathBootTime'}).'#text');
        $BootPostBootTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'BootPostBootTime'}).'#text');
        $BootNumStartupApps.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'BootNumStartupApps'}).'#text');
        $OSLoaderDuration.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'OSLoaderDuration'}).'#text');
    }
    Write-Host "BootTime (ms)"
    $BootTime.GetEnumerator() | Measure-Object Value -Minimum -Maximum -Average | Format-List Count,Average,Maximum,Minimum
    Write-Host "Main Path Boot Time (ms)"
    $MainPathBootTime.GetEnumerator() | Measure-Object Value -Minimum -Maximum -Average | Format-List Count,Average,Maximum,Minimum
    Write-Host "Boot Post Boot Time (ms)"
    $BootPostBootTime.GetEnumerator() | Measure-Object Value -Minimum -Maximum -Average | Format-List Count,Average,Maximum,Minimum
    
    Write-Host "BootNumStartupApps"
    $BootNumStartupApps.GetEnumerator() | Measure-Object Value -Minimum -Maximum -Average | Format-List Count,Average,Maximum,Minimum
    
    Write-Host "OSLoaderDuration (ms)"
    $OSLoaderDuration.GetEnumerator() | Measure-Object Value -Minimum -Maximum -Average | Format-List Count,Average,Maximum,Minimum
    

    Write-Host
    $Events = Get-WinEvent -FilterHashTable $EVENTFILTER_BootApplication
    $TopItems = 10;
    $Apps = @{};
    $TotalTime = @{};
    Write-Host "Top $TopItems start up applications"
    ForEach ($Event In $Events)
    {
        $xml = [xml]$Event.ToXml();
        
        $Apps.Add([int]$xml.Event.System.EventRecordID, [string]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'Name'}).'#text')
        $TotalTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'TotalTime'}).'#text')
    }
    $TotalTime.GetEnumerator()  | Sort Value -descending | Select -First $TopItems | Foreach {
        Write-Host $Apps.Item($_.Name) $_.Value "ms"
    }
    
    Write-Host
    $Events = Get-WinEvent -FilterHashTable $EVENTFILTER_BootDriver
    $TopItems = 5;
    $Apps = @{};
    $TotalTime = @{};
    Write-Host "Top $TopItems start up drivers"
    ForEach ($Event In $Events)
    {
        $xml = [xml]$Event.ToXml();
        
        $Apps.Add([int]$xml.Event.System.EventRecordID, [string]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'Name'}).'#text')
        $TotalTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'TotalTime'}).'#text')
    }
    $TotalTime.GetEnumerator()  | Sort Value -descending | Select -First $TopItems | Foreach {
        Write-Host $Apps.Item($_.Name) $_.Value "ms"
    }
    
    Write-Host
    $Events = Get-WinEvent -FilterHashTable $EVENTFILTER_BootService
    $TopItems = 5;
    $Apps = @{};
    $TotalTime = @{};
    Write-Host "Top $TopItems start up services"
    ForEach ($Event In $Events)
    {
        $xml = [xml]$Event.ToXml();
        
        #$Apps.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'BootTime'}).'#text');
        
        $Apps.Add([int]$xml.Event.System.EventRecordID, [string]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'Name'}).'#text')
        $TotalTime.Add([int]$xml.Event.System.EventRecordID, [int]($xml.Event.EventData.Data | Sort Name | Where {$_.Name -eq 'TotalTime'}).'#text')
    }
    $TotalTime.GetEnumerator()  | Sort Value -descending | Select -First $TopItems | Foreach {
        Write-Host $Apps.Item($_.Name) $_.Value "ms"
    }

    
}

