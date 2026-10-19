# cis_lvl2_macos_26.0

macOS 26.0: Security Configuration - cis_lvl2

This guide describes the actions to take when securing a macOS 26.0 system against the cis_lvl2 security benchmark.

## Generated policy parts

- `part-01-root` - context: **root**, rules: **90**
- `part-02-root` - context: **root**, rules: **18**
- `part-03-user` - context: **user**, rules: **2**

## Notes

- Supported rules generated: **110**
- Unsupported rules skipped: **7**
- Use one Intune custom compliance policy per part.
- For `user` context parts, set **Run this script using the logged on credentials** to **Yes**.
- For `root` context parts, set **Run this script using the logged on credentials** to **No**.
