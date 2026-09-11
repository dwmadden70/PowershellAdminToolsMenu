# PowerShell Admin Tools Menu

A Windows PowerShell project providing a menu-driven administrator tools suite through an old-style DOS console interface with nested submenus.

## Project purpose

This project provides a simple text-based menu for administrator tools and maintenance tasks. Its old DOS-style interface allows users to navigate nested menus, select an administrative action, and review the result. DISM actions are currently included for online and offline Windows image maintenance.

## Included features

- Classic DOS-style menu layout
- Main menu for DISM actions
- Submenus for online/offline image selection
- Administrator privilege check
- Automatic log file creation in the `logs` folder
- Exit-code based success/failure messaging
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

3. Use the menu to choose a DISM task.
4. Select either the online image or offline image option when prompted.
5. Review the output and the log file if an action fails.

## DISM actions included

- Check health
- Restore health
- Start component cleanup

## Notes

- DISM commands require administrative rights and should be used carefully.
- The script records command output to `logs/dism.log`.
- This project is intended as a functional repair-menu scaffold for Windows image maintenance tasks.
