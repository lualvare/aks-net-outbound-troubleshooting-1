param location string
param clusterName string
param aksSubnetId string
param nodeCount int = 2
param vmSize string = 'Standard_B4ms'
param agentpoolName string = 'nodepool1'
param aksClusterNetworkPlugin string = 'azure'
param aksNetworkPluginMode string = 'overlay'
param aksPodCidr string = '192.168.0.0/16'
param aksServiceCidr string = '10.0.0.0/16'
param aksDnsServiceIP string = '10.0.0.10'
param aksClusterNetworkPolicy string = 'calico'

@description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'managedNATGateway'
  'userAssignedNATGateway'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'
param aksClusterLoadBalancerSku string = 'standard'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: agentpoolName
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
        vnetSubnetID: aksSubnetId
      }
    ]
    networkProfile: {
      networkPlugin: aksClusterNetworkPlugin
      networkPluginMode: aksNetworkPluginMode
      podCidr: aksPodCidr
      serviceCidr: aksServiceCidr
      dnsServiceIP: aksDnsServiceIP
      networkPolicy: aksClusterNetworkPolicy
      outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
    }
  }
}

var config = aks.listClusterAdminCredential().kubeconfigs[0].value

output aks_principal_id string = aks.identity.principalId
output controlPlaneFQDN string = aks.properties.fqdn
output kubeConfig string = config
