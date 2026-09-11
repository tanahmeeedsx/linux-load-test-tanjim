<div align="center">

# 🛠️ Linux Load Testing & System Hardening

**Service isolation · Ephemeral storage · Stress testing · SSH hardening · Cron automation**

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Ubuntu%2026.04-E95420?logo=ubuntu&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

</div>

---

## 📖 Overview

A hands-on Linux systems lab that simulates how a production service account gets provisioned, stress-tested, secured, and monitored — the way it would actually be done on a real server.

The scenario: create an isolated, non-root service account (`bgdsvc_tanjim26`), give it a 256 MB RAM-backed scratch space (`tmpfs`), push it to its limits with CPU/memory/disk stress tests, lock down SSH access to key-only auth on a non-default port, wire up automated health monitoring via cron, and finally tear everything down cleanly with a single idempotent script.

Every step below is backed by a real terminal run and a screenshot in this repo.

---

## 📂 Repository Structure

```
linux-load-test-tanjim/
├── README.md
├── observations.md
├── scripts/
│   ├── 01_create_user.sh
│   ├── 02_setup_tmpfs.sh
│   ├── 03_stress_and_populate.sh
│   ├── 04_cleanup.sh
│   ├── bgdsvc_tanjim26_monitor.sh
│   └── bgdsvc_tanjim26_cleanup_old_files.sh
└── screenshots/
    ├── 00_svc_name.png
    ├── 01_id_created.png
    ├── 02_df_before.png / 02_df_after.png
    ├── 03_free_before.png / 03_free_during.png / 03_free_after.png
    ├── 03_dmesg_oom.png
    ├── 04_ssh_success.png
    ├── 05_crontab_l.png
    └── 06_cleanup_verify.png
```

---

## 🧰 Tools & Technologies

| Category | Tools |
|---|---|
| OS | Ubuntu 26.04 LTS |
| Scripting | Bash |
| Storage | `tmpfs`, `mount`, `df` |
| Load Testing | `stress-ng`, `dd` |
| Access Control | OpenSSH, ED25519 keys, `/usr/sbin/nologin` |
| Monitoring | `cron`, `free`, `dmesg` |
| Version Control | Git & GitHub |

---

## ⚙️ What Was Built

**1. Service account isolation**
Created `bgdsvc_tanjim26` as a system user with a `nologin` shell — no interactive access, only what automation needs.

**2. Ephemeral storage (`tmpfs`)**
Mounted a 256 MB RAM-backed volume at `/mnt/bgdsvc_tanjim26_tmp` for fast, disposable scratch space.

**3. Stress testing**
Filled the tmpfs volume with `dd`, then hit CPU and memory with `stress-ng`, capturing `free -h` before/during/after and checking the kernel log for OOM events.

**4. SSH hardening**
Generated an ED25519 keypair, moved SSH off port 22 to **2222**, disabled password auth and root login, and restricted access to the service account only.

**5. Automated monitoring**
Cron jobs running every 5 minutes to log memory/disk state, plus a daily job to purge stale temp files.

**6. Clean teardown**
One script (`04_cleanup.sh`) reverses everything — kills processes, removes cron entries, unmounts storage, deletes the user — verified with a final `id` / `mount` / `ps` check.

---

## 🐛 Challenges & How They Were Solved

| Problem | Cause | Fix |
|---|---|---|
| `dmesg: read kernel buffer failed: Operation not permitted` | Modern kernels restrict `dmesg` for non-root users | Ran with `sudo dmesg \| grep -i oom` |
| `This account is currently not available` on SSH login | Service account correctly uses `nologin` shell | Expected — confirms the key-auth handshake worked while blocking interactive shell |
| `stress-ng` aborted: `temp-path '.' must be readable and writeable` | Script ran from a directory the service user couldn't write to | Pointed the stress test explicitly at `/mnt/bgdsvc_tanjim26_tmp` |

---

## 💡 Takeaways

- Changing the SSH port and disabling password auth meaningfully shrinks the attack surface on a public-facing box.
- `tmpfs` is a great fit for throwaway working data — fast, and automatically wiped on unmount/reboot.
- A dedicated cleanup script isn't optional — without one, test accounts and mounts quietly pile up.
- Kernel OOM behavior is worth checking directly rather than assuming the process just "handled it."

---

## ▶️ Running It Yourself

```bash
git clone https://github.com/tanahmeeedsx/linux-load-test-tanjim.git
cd linux-load-test-tanjim
chmod +x scripts/*.sh

./scripts/01_create_user.sh
./scripts/02_setup_tmpfs.sh
./scripts/03_stress_and_populate.sh --all
./scripts/04_cleanup.sh
```

---

<div align="center">

Built by **Tanjim Ahmed** · [GitHub](https://github.com/tanahmeeedsx) · [LinkedIn](https://linkedin.com/in/tanahmedd)

</div>
