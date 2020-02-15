NodeName = sys.argv[0]
ServerName = sys.argv[1]
ChainName = sys.argv[2]
maximumPersistentRequestsValue = sys.argv[3]

WCID = AdminConfig.getid('/Node:'+NodeName+'/Server:'+ServerName+'/TransportChannelService:/Chain:'+ChainName+'/')

TPCs = AdminUtilities.convertToList(AdminConfig.showAttribute(WCID, 'transportChannels'))
for TPC in TPCs:
    if AdminConfig.getObjectType(TPC) == 'HTTPInboundChannel':
      HIC = TPC
      break

maximumPersistentRequests = [['maximumPersistentRequests', maximumPersistentRequestsValue]]
AdminConfig.modify(HIC, maximumPersistentRequests)
AdminConfig.save()





# NodeName = "taaripcNode05"
# ServerName = "server1"