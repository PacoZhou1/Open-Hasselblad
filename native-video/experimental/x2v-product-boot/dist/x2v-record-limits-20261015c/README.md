# X2V recording-duration / thermal-stop incremental candidate

User approved and permanently installed on 2026-10-15. The installed supervisor and three GUI files match the manifest; the boot module selects 20261015c. Running state reads 300 seconds and Low temperature. Physical power-cycle validation has not been performed.

Default 5 minutes; selectable 1–30 minutes or 永不 with explicit warning.
Native roller/confirmation components; persistent settings; supervisor-enforced stop and save.
High/Critical native thermal status stops recording and exits video mode; unknown/stale status
blocks recording. 永不 does not disable thermal/storage checks.

Apply only on the tested installed 20261014zm GUI/supervisor baseline with the aligned
20261015b receiver. Three GUI files plus x2v_product_boot_20261015c.sh are supplied.
The session continues to reference the existing aligned x2v_video_session_20261014zl.sh.
No receiver library, ISP geometry, calibration or thermal thresholds are changed.

See ../../evidence/record-limits-20261015/README.md for test results and limits.
The temporary test's debug commands, fake-temperature hook, and cgroup adaptation are not present.
Do not use the general package.py blindly: its old receiver pin predates the aligned preview fix.
