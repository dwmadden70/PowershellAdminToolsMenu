# PowerShell Admin Tools Menu

A Windows PowerShell project providing a menu-driven administrator tools suite through an old-style DOS console interface with nested submenus.

## Project purpose

This project provides a simple text-based menu for administrator tools and maintenance tasks. Its old DOS-style interface allows users to navigate nested menus, select an administrative action, and review the result. DISM actions are currently included for online and offline Windows image maintenance.

## Included features

- Classic DOS-style menu layout
- Admin Tools main menu with a Windows Health submenu
- Submenus for health actions and online/offline image selection
- Administrator privilege check
- Automatic log file creation in the `logs` folder
- Exit-code based success/failure messaging
- Live progress indicator for DISM operations
- Menu-driven workflow for easier system maintenance

## GitHub repository

This project is intended to be published under the GitHub user `dwmadden70` as a repository named `PowershellAdminToolsMenu`.

Example remote URL:

<https://github.com/dwmadden70/PowershellAdminToolsMenu.git>

## File structure

- `scripts/Run-AdminTools.ps1` - Main PowerShell script with the DOS-style menu and DISM actions
- `logs/` - Runtime log output directory
- `.gitignore` - Git exclusions for generated files and environment artifacts

## Usage

1. Open Windows PowerShell or PowerShell 7 as Administrator.
2. Run the script from the project root:

   ```powershell
   .\scripts\Run-AdminTools.ps1
   ```

3. Select `Windows Health` from the `Admin Tools` menu.
4. Choose a health action, then select either the online image or offline image option.
5. Monitor the live progress indicator while the DISM operation runs.
6. Review the detailed command output in `logs/dism.log` if an action fails.

At any submenu prompt, enter `m` or `menu` to return directly to the `Admin Tools` menu. Enter `e` or `exit` to terminate the program immediately.

## DISM actions included

- Check health
- Restore health
- Start component cleanup

## Notes

- DISM commands require administrative rights and should be used carefully.
- The script records command output to `logs/dism.log`.
- This project is a menu-driven administrator tools suite; Windows image maintenance is currently provided through the Windows Health menu.
