#requires -Version 5

configuration  vBaseLabDfs {
    param (
        ## Collection of folders
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Folders,
        
        ## Domain credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## DFS root share
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DFSRoot = 'DFS',
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',
        
        ## File server FQDN containing the user's home directories and profile shares
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FileServer = 'controller.lab.local',
        
        ## Collections of departments to create department DFS shares
        [Parameter()]
        [System.String[]] $Departments
    )
    
    Import-DscResource -Module DFSDsc, PSDesiredStateConfiguration;
    
    $dfsRootFolder = $Folders | Where-Object { $_.DfsRoot -eq $true } | Select-Object -First 1;
    
    if ($dfsRootFolder) {
        
        WindowsFeature 'FS_DFS_Namespace' {
            Name   = 'FS-DFS-Namespace';
            Ensure = 'Present';
        }
        
        WindowsFeature 'RSAT_DFS_Mgmt_Con' {
            Name   = 'RSAT-DFS-Mgmt-Con';
            Ensure = 'Present';
        }
        
        $rootId = $dfsRootFolder.Path.Replace(':','').Replace(' ','').Replace('\','_');
        $rootIdConfig = '{0}Config' -f $rootId;
        ## If the node is a domain controller, a DFS root is automatically created using the NetBIOS name.
        $netBIOSFileServer = $FileServer.Split('.')[0]

        DFSNamespaceServerConfiguration $rootIdConfig {
            ## Required for Server 2016 (https://github.com/PowerShell/xDFS/issues/15)
            IsSingleInstance     = 'Yes';
            UseFQDN              = $false;
            PsDscRunAsCredential = $Credential;
            DependsOn            = '[WindowsFeature]FS_DFS_Namespace', '[WindowsFeature]RSAT_DFS_Mgmt_Con';
        }

        DFSNamespaceRoot $rootId {
            Path                 = '\\{0}\{1}' -f $DomainName, $DFSRoot;
            TargetPath           = '\\{0}\{1}' -f $netBIOSFileServer, $dfsRootFolder.Share;
            Description          = $dfsRootFolder.Description;
            Type                 = 'DomainV2';
            Ensure               = 'Present'; 
            PsDscRunAsCredential = $Credential;
            DependsOn            = "[DFSNamespaceServerConfiguration]$rootIdConfig";
        }
        
        ## Create the DFS folders
        $dfsFolders = $Folders | Where-Object { $_.DfsPath };
        foreach ($dfsFolder in $dfsFolders) {
            
            $folderId = 'DFS_{0}' -f $dfsFolder.Path.Replace(':','').Replace(' ','').Replace('\','_');
            DFSNamespaceFolder $folderId {
                Path                 = '\\{0}\{1}\{2}' -f $DomainName, $DFSRoot, $dfsFolder.DfsPath;
                TargetPath           = '\\{0}\{1}' -f $FileServer, $dfsFolder.Share;
                Description          = $dfsFolder.Description;
                Ensure               = 'Present';
                PsDscRunAsCredential = $Credential;
                DependsOn            = "[DFSNamespaceRoot]$rootId";
            }
            
        } #end foreach DFS folder
        
        ## Create the department DFS folders
        foreach ($department in $Departments) {
            
            $folderId = 'DFS_Department_{0}' -f $department.Replace(' ','');
            DFSNamespaceFolder $folderId {
                Path                 = '\\{0}\{1}\Departments\{2}' -f $DomainName, $DFSRoot, $department;
                TargetPath           = '\\{0}\{1}' -f $FileServer, $department;
                Description          = '{0} Department' -f $department;
                Ensure               = 'Present';
                PsDscRunAsCredential = $Credential;
                DependsOn            = "[DFSNamespaceRoot]$rootId";
            }
            
        } #end foreach department folder
        
    } #end if DFS Root
    
} #end configuration
