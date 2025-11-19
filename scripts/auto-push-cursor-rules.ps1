param (
    [int]$IntervalSeconds = 60,
    [string]$Remote = "origin",
    [string]$Branch = "main" # Or current branch
)

Write-Host "Starting Auto-Push Script..."
Write-Host "Monitoring repository every $IntervalSeconds seconds."
Write-Host "Pushing to $Remote/$Branch"
Write-Host "Press Ctrl+C to stop."

while ($true) {
    $status = git status --porcelain
    if ($status) {
        Write-Host "Changes detected at $(Get-Date). Committing..."
        
        # Get list of changed files with status symbols
        $changedFiles = $status | ForEach-Object {
            $code = $_.Substring(0, 2)
            $file = $_.Substring(3)
            
            if ($code -match "^\?\?" -or $code -match "A") { "+ $file" }
            elseif ($code -match "D") { "- $file" }
            elseif ($code -match "M") { "~ $file" }
            else { "$code $file" }
        }
        $changedFilesStr = $changedFiles -join ", "
        
        # Add all changes
        git add .
        
        # Commit
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $commitMessage = "Auto-push: $timestamp - Changes: $changedFilesStr"
        git commit -m $commitMessage
        
        # Pull before pushing to avoid conflicts
        Write-Host "Pulling from remote..."
        git pull $Remote $Branch
        
        # Push
        Write-Host "Pushing to remote..."
        git push $Remote $Branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully pushed changes." -ForegroundColor Green
        }
        else {
            Write-Host "Error pushing changes." -ForegroundColor Red
        }
    }
    else {
        Write-Host "No changes detected at $(Get-Date)." -ForegroundColor Gray
    }
    
    Start-Sleep -Seconds $IntervalSeconds
}
