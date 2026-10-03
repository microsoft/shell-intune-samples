# cnssi-1253_high_macos_26.0

macOS 26.0: Security Configuration - cnssi-1253_high

This guide describes the actions to take when securing a macOS 26.0 system against the cnssi-1253_high security benchmark.

Information System Security Officers and benchmark creators can use this catalog of settings in order to assist them in security benchmark creation. This list is a catalog, not a checklist or benchmark, and satisfaction of every item is not likely to be possible or sensible in many operational scenarios.

## Generated policy parts

- `part-01-root` - context: **root**, rules: **90**
- `part-02-root` - context: **root**, rules: **90**
- `part-03-root` - context: **root**, rules: **18**
- `part-04-user` - context: **user**, rules: **2**

## Notes

- Supported rules generated: **200**
- Unsupported rules skipped: **67**
- Use one Intune custom compliance policy per part.
- For `user` context parts, set **Run this script using the logged on credentials** to **Yes**.
- For `root` context parts, set **Run this script using the logged on credentials** to **No**.
