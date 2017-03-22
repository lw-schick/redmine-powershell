Function New-RedmineIssue {
    <#
    .SYNOPSIS
    Creates a new redmine issue.
    .DESCRIPTION
    Creates a new redmine issue. This uses the Redmine Rest API.
    .EXAMPLE
    New-RMIssue -ProjectId 314 -DueDate (Get-Date).AddDays(1) -Subject "My subject" -Description "My description. Special chars like äöü are also supported." -RedmineUrl 'https://pm.myredmine.com' -AuthorId 1 -ApiToken 'my-token-here'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $ProjectId,
        
        [int] $TrackerId = 1, # Default = Task
        
        [int] $StatusId = 1, # Default = New
        
        [int] $PriorityId = 9, # Default = Normal 
        
        [Parameter(Mandatory)]
        [int] $AuthorId,
        
        [DateTime] $StartDate,
        
        [Parameter(Mandatory)]
        [DateTime] $DueDate,
        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        [string] $Subject,
        
        [string] $Description = '',
        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        [string] $ApiUrl,
        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        [string] $ApiToken,
        
        [switch] $PassThru
    )
    
    If (!($StartDate)) {
        $StartDate = Get-Date
    }
    
    $Url = "$ApiUrl`/issues.xml?key=$RedmineToken";
    $Body = @{
        issue = @{
            project_id = $ProjectId;
            tracker_id = $TrackerId;
            status_id = $StatusId;
            priority_id = $PriorityId;
            author_id = $AuthorId;
            subject = [System.Net.WebUtility]::HtmlEncode($Subject);
            description = [System.Net.WebUtility]::HtmlEncode($Description);
            start_date = (Get-Date -Date $StartDate -Format "yyyy-MM-dd");
            due_date = (Get-Date -Date $DueDate -Format "yyyy-MM-dd");
        };
    } | ConvertTo-Json;
    
    Write-Verbose "URL: $Url"
    Write-Verbose "Body: $Body"
    
    $Result = Invoke-WebRequest -UseBasicParsing $url -ContentType 'application/json' -Body $Body -Method POST
    
    If ($Result.StatusCode -ne 201) {
        Write-Error "Error: Unexpected Status code $($Result.StatusCode), expected was 201"
    }
    
    If ($PassThru) {
        $Result
    }
}
