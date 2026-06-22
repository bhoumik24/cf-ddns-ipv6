# --- CONFIGURATION (DYNAMIC LOADING) ---
# Locates config.json in the exact same directory where the script lives
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "config.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found at $ConfigFile. Please create it using the template."
    Exit
}

# Safely parse the raw text file from JSON to a standard PSCustomObject
try {
    $RawJson = Get-Content -Raw -Path $ConfigFile
    $Config = ConvertFrom-Json -InputObject $RawJson
} catch {
    Write-Error "Failed to parse JSON file structure: $_"
    Exit
}

# Access properties directly from the object
$Token      = $Config.CloudflareToken
$ZoneId     = $Config.ZoneId
$RecordName = $Config.RecordName

if (-not $Token -or -not $ZoneId -or -not $RecordName) {
    Write-Error "Invalid configuration. CloudflareToken, ZoneId, and RecordName are all required inside config.json."
    Exit
}
# ---------------------------------------

# 1. Fetch the machine's current Global Unicast IPv6 Address
$IpAddress = (Get-NetIPAddress -AddressFamily IPv6 -AddressState Preferred | 
    Where-Object { $_.IPAddress -notlike "f*" -and $_.IPAddress -notlike ":*" -and $_.SuffixOrigin -ne "Random" }).IPAddress[0]

if (-not $IpAddress) {
    Write-Error "No valid global IPv6 address discovered on local interfaces."
    Exit
}

# 2. Set up headers for the Cloudflare v4 API
$Headers = @{
    "Authorization" = "Bearer $Token"
    "Content-Type"  = "application/json"
}

# 3. Retrieve the specific Identifier for the DNS record
$GetUrl = "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records?type=AAAA&name=$RecordName"
try {
    $RecordResponse = Invoke-RestMethod -Uri $GetUrl -Method Get -Headers $Headers
    if ($RecordResponse.success -and $RecordResponse.result.Count -gt 0) {
        $RecordId = $RecordResponse.result[0].id
        $CurrentRecordIp = $RecordResponse.result[0].content
    } else {
        Write-Error "Could not find an existing AAAA record named $RecordName."
        Exit
    }
} catch {
    Write-Error "API call to fetch record metadata failed: $_"
    Exit
}

# 4. Update the record if the IP address has changed
if ($IpAddress -eq $CurrentRecordIp) {
    Write-Output "IP address matches ($IpAddress). No update required."
} else {
    Write-Output "IP mismatch detected. Cloudflare: $CurrentRecordIp | Local: $IpAddress. Updating..."
    
    $UpdateUrl = "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records/$RecordId"
    $Body = @{
        type    = "AAAA"
        name    = $RecordName
        content = $IpAddress
        ttl     = 1 
        proxied = $false 
    } | ConvertTo-Json

    try {
        $UpdateResponse = Invoke-RestMethod -Uri $UpdateUrl -Method Put -Headers $Headers -Body $Body
        if ($UpdateResponse.success) {
            Write-Output "Successfully updated AAAA record to $IpAddress"
        } else {
            Write-Error "Cloudflare rejected the update request."
        }
    } catch {
        Write-Error "Failed to update record: $_"
    }
}