$seconds = 60
1..$seconds |
ForEach-Object { $percent = $_ * 100 / $seconds; 
 
  Write-Progress -Activity "CHUPAME LA PIJA" -Status "$($seconds - $_) seconds remaining..." -PercentComplete $percent; 
  
  Start-Sleep -Seconds 1
  } 

  Write-Warning "warning text"