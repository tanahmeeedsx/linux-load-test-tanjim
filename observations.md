# Load Test Observations and Metrics

## 1. Environment Details
- **Service Account:** `bgdsvc_tanjim26`
- **Project Directory:** `linux-load-test-tanjim`
- **Mount Point:** `/mnt/bgdsvc_tanjim26_tmp` (256M tmpfs)

## 2. Resource Utilization Analysis
- **Disk Pressure (`tmpfs`):** The RAM-backed storage reached ~98% to 100% capacity during file generation using `dd`. Write speed was limited by available tmpfs allocation.
- **Memory & Stress Metrics:**
  - `free -h` showed an increase in used RAM and shared memory buffers during `stress-ng` execution.
  - The system recovered available memory immediately after the `stress-ng` processes completed.
- **Kernel OOM Behavior:** Checked kernel ring buffer using `dmesg | grep -i oom`. No fatal OOM killer invocation was triggered as the memory stress stayed within safe hardware thresholds.

## 3. SSH Hardening Verification
- **Configured Port:** 2222
- **Authentication:** ED25519 Key-based only (`PasswordAuthentication no`).
- **Access Test:** Successfully verified connection via port 2222. Shell access restricted appropriately for service isolation.

## 4. Cron & Log Monitoring
- Crontab configured for `bgdsvc_tanjim26` to run monitoring every 5 minutes and daily old file cleanups.
- Verified entries via `crontab -l -u bgdsvc_tanjim26`.

## 5. Cleanup Verification
- Executed `04_cleanup.sh`.
- Confirmed total removal of user account (`id`), tmpfs mount points, and scheduled cron jobs.
