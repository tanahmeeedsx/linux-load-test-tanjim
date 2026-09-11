# 🚀 Linux System Load Testing, Storage Isolation & Hardening Project

A comprehensive Linux Systems & DevOps hands-on lab focused on service user isolation, temporary storage configuration (`tmpfs`), memory/disk stress testing, OpenSSH security hardening, automated cron monitoring, and safe system cleanup.

---

## 📌 Project Overview & Scenario

In modern production environments, running microservices or background processing tasks safely requires strict user isolation, controlled ephemeral storage, and continuous monitoring to prevent resource starvation.

This project simulates a real-world enterprise infrastructure task where a dedicated service account (`bgdsvc_tanjim26`) is created to manage dynamic temporary files in RAM (`tmpfs`), conduct stress testing under memory/disk load, secure remote access using custom SSH configurations, and maintain automated health logs without risking core system stability.

---

## 📁 Repository Directory Structure

```text
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
    ├── 02_df_before.png
    ├── 02_df_after.png
    ├── 03_free_before.png
    ├── 03_free_during.png
    ├── 03_free_after.png
    ├── 03_dmesg_oom.png
    ├── 04_ssh_success.png
    ├── 05_crontab_l.png
    └── 06_cleanup_verify.png



