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
        
        # Get list of changed files for the commit message
        $changedFiles = $status | ForEach-Object { $_.Substring(3) }
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
