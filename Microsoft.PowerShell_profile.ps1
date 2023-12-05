Set-Alias k kubectl
Set-Alias ipy ipython
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

function touch
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        throw "file already exists"
    }
    else
    {
        # echo $null > $file
        New-Item -ItemType File -Name ($file)
    }
}

function gitacp {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [String[]] $message
  )
  echo "> git add ."
  git add .

  echo "> git commit -a -m "$message""
  git commit -a -m "$message"

  echo "> git push"
  git push
}

function Write-BranchName () {
    try {
        $branch = git rev-parse --abbrev-ref HEAD

        if ($branch -eq "HEAD") {
            # we're probably in detached HEAD state, so print the SHA
            $branch = git rev-parse --short HEAD
            Write-Host " ($branch)" -ForegroundColor "red" -NoNewline
        } else {
            # we're on an actual branch, so print it
            Write-Host " ($branch)" -ForegroundColor "blue" -NoNewline
        }
    } catch {
        # we'll end up here if we're in a newly initiated git repo
        Write-Host " (no branches yet)" -ForegroundColor "yellow" -NoNewline
    }
}

function Write-ShortStatus () {
    try {
        $status = git -c color.status=always status -sz 
        Write-Host "[" -NoNewline
        Write-Host $status -NoNewline
        Write-Host "]"
    } catch {
        Write-Host "No git status" -ForegroundColor "red"
    }
}


function Is-GitRepository {
    try {
        if( 'true' -eq $(git rev-parse --is-inside-work-tree )){
            $insideGitRepo = $true
        }else{
            $insideGitRepo = $false
        }
    } catch {
        $insideGitRepo = $false
    }
    return $insideGitRepo
}

function prompt {
    $base = "PS "
    $path = "$($executionContext.SessionState.Path.CurrentLocation)"
    $userPrompt = "$('>' * ($nestedPromptLevel + 1)) "

    Write-Host "$base" -NoNewline

    if (Is-GitRepository) {
        Write-Host $path -NoNewline
        Write-BranchName
        Write-ShortStatus
    } else {
        # we're not in a repo so don't bother displaying branch name/sha
        Write-Host $path
    }

    return $userPrompt
}

function proj ([string]$searchTerm = ''){

    Set-Location ~\Documents\projects\; Get-ChildItem -Directory -Name | fzf --query=$searchTerm | Set-Location
}

function mvnw {
    $currDir = Get-Item .
    While ($currDir -and !(Test-Path -Path (Join-Path $currDir.FullName 'mvnw.cmd'))) {
        $currDir = ($currDir).Parent
    }
    if ($currDir){
        $mvnw = Join-Path $currDir.FullName 'mvnw.cmd'
        Invoke-Expression -Command "$mvnw $args"
    }else {
        Write-Information 'No maven wrapper found in parent directories, running mvn'
        Invoke-Expression -Command "mvn $args"
    }
}

