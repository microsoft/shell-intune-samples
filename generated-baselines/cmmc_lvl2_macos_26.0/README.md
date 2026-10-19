# cmmc_lvl2_macos_26.0

macOS 26.0: Security Configuration - cmmc_lvl2

This guide describes the actions to take when securing a macOS 26.0 system against the cmmc_lvl2 security benchmark.

Information System Security Officers and benchmark creators can use this catalog of settings in order to assist them in security benchmark creation. This list is a catalog, not a checklist or benchmark, and satisfaction of every item is not likely to be possible or sensible in many operational scenarios.

## Generated policy parts

- `part-01-root` - context: **root**, rules: **90**
- `part-02-root` - context: **root**, rules: **89**
- `part-03-user` - context: **user**, rules: **2**

## Notes

- Supported rules generated: **181**
- Unsupported rules skipped: **34**
- Use one Intune custom compliance policy per part.
- For `user` context parts, set **Run this script using the logged on credentials** to **Yes**.
- For `root` context parts, set **Run this script using the logged on credentials** to **No**.
