param disks_az104_disk1_name string = 'az104-disk1'

resource disks_az104_disk1_name_resource 'Microsoft.Compute/disks@2026-03-02' = {
  name: disks_az104_disk1_name
  location: 'francecentral'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 32
    diskIOPSReadWrite: 500
    diskMBpsReadWrite: 60
    encryption: {
      type: 'EncryptionAtRestWithPlatformKey'
    }
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enabled'
    dataAccessAuthMode: 'None'
  }
}
