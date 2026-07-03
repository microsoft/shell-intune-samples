# Contributing

Thanks for your interest in improving the Intune shell script samples. This
repository is maintained by the Microsoft Intune Customer Experience Engineering
team. The scripts here are **samples** for education — they are meant to be
downloaded, tested, and adapted, and should be run only in a **non-production /
test** environment.

## Contributor License Agreement

Most contributions require you to agree to a Contributor License Agreement (CLA)
declaring that you have the right to, and actually do, grant us the rights to use
your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether
you need to provide a CLA and decorate the PR appropriately (status check,
comment). Simply follow the bot's instructions. You only need to do this once
across all repositories using our CLA.

## Code of Conduct

This project has adopted the
[Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the
[Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any
questions or comments.

## Before you open a pull request

1. Read [AGENTS.md](AGENTS.md) and [docs/conventions.md](docs/conventions.md) for
   the script style (header, banner, idempotency, logging).
2. Add the Microsoft copyright + MIT license header to any new file.
3. Run the verify loop and make sure it passes:

   ```bash
   ./scripts/verify.sh
   ```

4. Test your sample in a non-production environment and describe how you tested
   it in the pull request.
5. Follow the PR conventions in
   [.github/instructions/telemetry.instructions.md](.github/instructions/telemetry.instructions.md).

## Reporting security issues

Please report security issues privately as described in [SECURITY.md](SECURITY.md).
Do not open a public issue for a security vulnerability.
