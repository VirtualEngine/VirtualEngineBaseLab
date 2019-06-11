The VirtualEngineBaseLab composite DSC resources can be used to create the Virtual Engine standardised
Active Directory lab environment. This module contains the following DSC resources:

### Included Resources

* vBaseLab
 * Creates the lab folders, file shares, OUs, users, service accounts and groups.
* vBaseLabDfs
 * Creates the lab lab DFS root and folder namespaces.
* vBaseLabDns
 * Creates the lab DNS aliases and reverse DNS lookup zone.
* vBaseLabFolders
 * Creates the lab folders and file shares.
* vBaseLabGPOs
 * Restores lab GPOs from a backup.
* vBaseLabGroups
 * Creates the lab Active Directory groups.
* vBaseLabOUs
 * Creates the lab Active Directory organisational units.
* vBaseLabPasswordPolicy
 * Configures the default lab Active Directory domain password policy.
* vBaseLabPrepare
 * Creates the lab seal/preparation script.
* vBaseLabPrinters
 * Creates the shared department printers.
* vBaseLabScheduledTasks
 * Manages the built-in maintenance scheduled tasks.
* vBaseLabServiceAccounts
 * Creates the lab Active Directory service accounts.
* vBaseLabUsers
 * Creates the lab Active Directory users.
* vBaseLabUserThumbnails
 * Adds lab Active Directory user thumbnails/pictures.

### Requirements

There are __dependencies__ on the following DSC resources:

* DFSDsc - https://github.com/PowerShell/DFSDsc
* xSmbShare - https://github.com/PowerShell/xSmbShare
* xActiveDirectory - https://github.com/PowerShell/xActiveDirectory
* PrinterManagement - https://github.com/VirtualEngine/PrinterManagement
* PowerShellAccessControl - https://github.com/rohnedwards/PowerShellAccessControl
* VirtualEngineLab - https://github.com/VirtualEngine/VirtualEngineLab
