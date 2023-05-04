$computerList = 'server01', 'server02', 'server03', 'server04', 'server05', 'server06', 'server07', 'server08', 'server09', 'server10'
 
$c1 = 0
 
foreach ($computer in $computerList) {
$c1++
Write-Progress -Id 0 -Activity 'Checking servers' -Status "Processing $($c1) of $($computerList.count)" -CurrentOperation $computer -PercentComplete (($c1/$computerList.Count) * 100)
$services = Get-Service
$c2 = 0
    foreach ($service in $services) {
        $c2++
        Write-Progress -Id 1 -ParentId 0 -Activity 'Getting services' -Status "Processing $($c2) of $($services.count)" -CurrentOperation $service.DisplayName -PercentComplete (($c2/$services.count) * 100)
        $c3 = 0
    if ($service.ServicesDependedOn) {
        foreach ($dependency in $service.ServicesDependedOn) {
            $c3++
            Write-Progress -Id 2 -ParentId 1 -Activity 'Getting dependency services' -Status "Processing $($c3) of $($service.ServicesDependedOn.Count)" -CurrentOperation $dependency.Name -PercentComplete (($c3/$service.ServicesDependedOn.count) * 100)
            Start-Sleep -Milliseconds 50
        }
    }
 
else {
    Write-Progress -Id 2 -ParentId 1 -Activity 'Getting dependency services' -PercentComplete 100
    }
 
Start-Sleep -Milliseconds 50
    }
 
Start-Sleep -Milliseconds 50
}