# DDNS IPv6 Script

A lightweight script to update dynamic DNS (DDNS) records with the current public IPv6 address.

## Overview

This script detects the current IPv6 address assigned to the host and updates a DDNS provider with the new value. It is useful for systems that do not have a static IPv6 address and need to keep DNS records in sync.

## Requirements

- PowerShell 5.1 or later / PowerShell Core
- IPv6 connectivity
- Access to a supported DDNS provider API
- Credentials or API token for the DDNS service

## Installation

1. Clone or download the repository to a local folder.
2. Place the script in a folder such as `c:\Scripts\ddns-ipv6`.
3. Ensure the script file has the correct execution permissions.

## Configuration

1. Edit the script to configure the DDNS provider endpoint and authentication details.
2. Set the hostname or DDNS record name that should be updated.
3. Optionally update polling intervals or logging settings if available.

## Usage

Run the script from PowerShell:

```powershell
cd c:\Scripts\ddns-ipv6
.\update-ddns-ipv6.ps1
```

If the script supports parameters, supply them as needed:

```powershell
.\update-ddns-ipv6.ps1 -ApiKey "YOUR_API_KEY" -Hostname "example.yourddns.com"
```

## Troubleshooting

- Verify the system has an active IPv6 address.
- Confirm the DDNS service credentials and API endpoint are correct.
- Check for firewall or network restrictions blocking API access.

## Notes

- This README provides a general guide. Adjust settings based on the specific implementation details of the script.
- Keep sensitive API credentials secure and avoid committing them to version control.
