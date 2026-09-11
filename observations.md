# Load Testing Observations

## Test Summary
- **Service Account:** `bgdsvc_tanjim26`
- **Mount Point:** `/mnt/bgdsvc_tanjim26_tmp`
- **Allocated tmpfs Size:** 256MB
- **Tools Used:** `stress-ng`, `dd`, `free`, `df`, `dmesg`, `ssh`, `cron`

## Part 1 — User Creation
The service account `bgdsvc_tanjim26` was created as a system account with `/usr/sbin/nologin` as its shell, so it has no interactive login capability — only what automated scripts and SSH key auth grant it. `01_create_user.sh` checks with `id` before creating the user, so re-running it is safe and does nothing if the account already exists.

## Part 2 — Tmpfs Setup
A 256MB RAM-backed `tmpfs` volume was mounted at `/mnt/bgdsvc_tanjim26_tmp` and ownership handed to `bgdsvc_tanjim26`. `02_setup_tmpfs.sh` checks `mountpoint -q` first, so it's idempotent — running it again just reports the mount already exists instead of remounting.

## Part 3 — Stress Testing
- **Disk fill:** Writing files in a loop with `dd` against the 256M cap. `df -h` moved from 0% to ~98–100% usage; once full, further writes failed cleanly instead of corrupting anything already written.
- **CPU + Memory (`stress-ng`):** Running `--cpu` and `--vm` stress drove CPU and memory usage up sharply for the test duration, confirmed by comparing `free -h` output before, during, and after the run — available memory dropped noticeably during the test and recovered immediately once `stress-ng` exited.
- **Combined test:** Running disk fill and CPU/memory stress together produced a sharper, more realistic load spike than any single test alone — closer to what an actual traffic surge would look like.
- **OOM check:** `sudo dmesg | grep -i oom` was checked after the combined run. No OOM-killer activity was logged, meaning the stress stayed within safe limits and never forced the kernel to kill a process.

## Part 4 — SSH Key-Based Access
An `ed25519` key pair was generated and the public key installed into `bgdsvc_tanjim26`'s `authorized_keys` (`.ssh` set to `700`, `authorized_keys` set to `600`). Connecting with `ssh -i ~/.ssh/bgdsvc_tanjim26_key -p 2222 bgdsvc_tanjim26@localhost` authenticated successfully — the key was accepted, and the resulting **"This account is currently not available"** message is the expected response from a `nologin` shell, not an authentication failure. It confirms the SSH handshake and key verification worked exactly as intended, while the account itself still can't be used for an interactive session.

## Part 5 — SSH Hardening
`sshd_config` was hardened with `Port 2222` (moved off the default port 22), `PermitRootLogin no`, `PasswordAuthentication no`, and `AllowUsers bgdsvc_tanjim26`. After restarting the SSH service, only key-based login for this specific account was possible — password attempts and root login were no longer accepted.

## Part 6 — Cron Monitoring & Automation
Two cron jobs were scheduled under `bgdsvc_tanjim26`: a monitoring script every 5 minutes that logs memory (`free -h`) and tmpfs usage (`df -h`) to a dedicated log file, and a daily cleanup job at 2:00 AM that deletes tmpfs files older than 1 day. `crontab -l -u bgdsvc_tanjim26` confirmed both entries were registered correctly.

## Part 7 — Cleanup Execution
`04_cleanup.sh` tore everything down in reverse order: killed any remaining processes owned by the service account, removed its crontab, deleted the monitor/cleanup scripts from `/usr/local/bin`, unmounted and removed the tmpfs mount point, removed the log directory, and finally deleted the user account itself.

## Part 8 — Final Verification
Running `id bgdsvc_tanjim26`, `mount | grep bgdsvc_tanjim26`, and `ps -u bgdsvc_tanjim26` after cleanup confirmed the account, mount, and processes were all fully gone — no leftover artifacts, and the system was returned to its original state.

## Reflection

**What did you observe when the system was under load, and what would you do differently if this were a real production server?**

The most interesting part wasn't the stress test itself — it was how many small permission and environment assumptions broke along the way. `dmesg` refused to run as a normal user until I added `sudo`, and `stress-ng` aborted the very first time it ran because it tried to write to the current working directory instead of the tmpfs mount I'd actually set up for it. Neither of those showed up in `free -h` or `df -h`; they were silent failures I only caught by reading the actual error text instead of assuming the script "just worked" because it printed something.

Once the test was actually running correctly, memory was the resource that moved the most — CPU spiked and dropped back almost instantly, but combined memory and tmpfs pressure took noticeably longer to recover, even though the kernel's OOM-killer never had to step in. That gap between "load exists" and "the kernel had to intervene" is exactly the window a real production system needs to catch on its own, because by the time `dmesg` shows an OOM kill, something has already been forcibly terminated.

If this were a real production server, I'd stop trusting a fixed 256MB `tmpfs` cap and a cron job that only writes to a log file as my safety net. I'd put the service inside a `cgroup`/systemd slice with an actual memory ceiling below the OOM threshold, so the process gets throttled or restarted on my terms instead of the kernel's, and I'd wire the monitoring script into something that pages a human at a warning threshold — not a log nobody reads until after something has already broken.
