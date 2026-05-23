# Cloudflare IPv6 DDNS for Windows

A lightweight, native PowerShell utility that dynamically updates a Cloudflare DNS `AAAA` record with your local machine's current Global Unicast IPv6 address. Designed to run seamlessly in the background using Windows Task Scheduler without requiring external daemons or third-party client installations.

## Features

- **Native Windows Execution:** Built purely on PowerShell and native `NetTCPIP` cmdlets. No extra software dependencies.
- **Smart IPv6 Filtering:** Automatically filters out Link-Local (`fe80::`) and temporary random privacy addresses, ensuring only your stable, preferred global routing identifier is sent to Cloudflare.
- **Secure Secret Management:** Decouples sensitive production tokens from source control via an external JSON profile.
- **Differential Updates:** Queries Cloudflare first to inspect the remote status and only fires a `PUT` transaction if a local WAN infrastructure shift is detected, minimizing API footprint.

---

## Setup

### 1. Cloudflare prerequisites

1. Open the Cloudflare dashboard.
2. Go to **My Profile > API Tokens** and click **Create Token**.
3. Use the **Edit zone DNS** template.
4. Restrict the token to the zone or domain you want to update.
5. Copy the API token.
6. In the zone Overview page, copy the **Zone ID**.
7. Create the target `AAAA` DNS record in Cloudflare before running the script.

> The script updates an existing record by name, so the DNS record must already exist.

### 2. Configure `config.json`

Copy the example file and edit it with your Cloudflare settings:

```powershell
Copy-Item config.json.example config.json
```

Update `config.json` with:

```json
{
  "CloudflareToken": "your_api_token_here",
  "ZoneId": "your_zone_id_here",
  "RecordName": "subdomain.yourdomain.com"
}
```

### 3. Test the script manually

Run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
& ".\cloudflare-ddns-ipv6.ps1"
```

Verify the output and confirm the Cloudflare `AAAA` record reflects your global IPv6 address.

## Windows Task Scheduler

Configure the script to run on a schedule in Task Scheduler.

1. Open **Task Scheduler** (`taskschd.msc`).
2. Select **Create Task**.
3. Under the **General** tab:
   - Set a task name such as **Cloudflare DDNS IPv6**.
   - Select **Run whether user is logged on or not**.
   - Enable **Run with highest privileges**.
4. Under the **Triggers** tab:
   - Create a new trigger.
   - Set it to start **One time**.
   - Enable **Repeat task every:** and choose a cadence such as **15 minutes**.
   - Set **for a duration of:** to **Indefinitely**.
5. Under the **Actions** tab:
   - Choose **Start a program**.
   - For **Program/script**, enter `powershell.exe`.
   - For **Add arguments**, enter:

```powershell
-ExecutionPolicy Bypass -File "C:\Scripts\ddns-ipv6\cloudflare-ddns-ipv6.ps1" *> "C:\Scripts\ddns-ipv6\ddns.log"
```

6. Under the **Conditions** tab:
   - Ensure **Start only if the following network connection is available** is set to **Any connection**.

## Notes

- The script prefers global unicast IPv6 addresses and ignores link-local or temporary privacy addresses.
- Keep `config.json` private and do not commit it to source control.

## License

This project is available under the [MIT License](LICENSE).