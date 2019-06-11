configuration vBaseLabGroups {
    param (
        ## Collection of groups
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Groups,
        
        ## Collection of users to nest in groups
        [Parameter()]
        [System.Collections.Hashtable[]] $Users,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )
    
    $rootDN = ',DC={0}' -f $DomainName -split '\.' -join ',DC=';
    
    Import-DscResource -Module xActiveDirectory;
    
    foreach ($group in $Groups) {
        
        if ([System.String]::IsNullOrEmpty($group.Path)) {
            $groupPath = $rootDN.TrimStart(',');
        }
        else {
            $groupPath = '{0}{1}' -f $group.Path, $rootDN;
        }

        if ($group.Members) {
            $groupMembers = $group.Members;
        }
        elseif ($Users) {
            $groupMembers = $Users.Where({ $_.Department -eq $group.Name}).SamAccountName;
        }
        else {
            $groupMembers = '';
        }
        
        if ($group.Scope) {
            $groupScope = $group.Scope;
        }
        else {
            $groupScope = 'Global';
        }

        if ($group.ManagedBy) {
            $user = $Users.Where({ $_.SamAccountName -eq $group.ManagedBy });
            $userCN = '{0} {1}' -f $user.GivenName, $user.Surname;

            xADGroup "xADGroup_$($group.Name)" {
                GroupName = $group.Name;
                Path = $groupPath;
                Description = $group.Description;
                MembersToInclude = $groupMembers
                ManagedBy = 'CN={0},{1}{2}' -f $userCN, $user.Path, $rootDN;
                GroupScope = $groupScope;
            }
            
        }
        else {

            xADGroup "xADGroup_$($group.Name)" {
                GroupName = $group.Name;
                Path = $groupPath;
                Description = $group.Description;
                MembersToInclude = $groupMembers;
                GroupScope = $groupScope;
            }

        }

    } #end foreach group

} #end configuration
