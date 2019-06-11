configuration vBaseLabDns {
    param (
        ## IP address used to calculate reverse lookup zone name
        [Parameter(Mandatory)]
        [System.String] $IPAddress,

        ## Domain root FQDN used to AD paths
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )

    Import-DscResource -Module xDnsServer;

    if ($IPAddress.EndsWith('.in-addr.arpa')) {

        xDnsServerPrimaryZone 'ReverseLookup' {
            Name = $IPAddress;
            DynamicUpdate = 'NonsecureAndSecure';
        }

    }
    else {

        $ipQuartets = $IPAddress.Split('.');
        xDnsServerPrimaryZone 'ReverseLookup' {
            Name = '{0}.{1}.{2}.in-addr.arpa' -f $ipQuartets[2], $ipQuartets[1], $ipQuartets[0];
            DynamicUpdate = 'NonsecureAndSecure';
        }

    }

} #end configuration
