import re

search_text = "jdbc"

PerfMbeanLists =  AdminControl.queryNames('type=Perf,*').split( lineSeparator)

for perfStr in PerfMbeanLists:
    perfObj = AdminControl.makeObjectName( perfStr)
    servername = perfObj.getKeyPropertyList()['process'] 
    srvrStr = AdminControl.queryNames('type=Server,process=%s,*' % servername)
    srvrObj = AdminControl.makeObjectName( srvrStr)
    params = [ srvrObj, java.lang.Boolean ('true')]
    sigs = ['javax.management.ObjectName', 'java.lang.Boolean']
    stats = AdminControl.invoke_jmx( perfObj, 'getStatsObject', params, sigs)
    
def listStatsSubCollections( object ):
    try:
        sub = object.subCollections()
        if not sub:
            # print object.getName(), ", No subCollections."
            target_stat = re.compile( r'.*' + search_text + '*' ).match( object.getName() )
            if target_stat:
                print object.getName()    # object.listStatisticNames()
                print object.getStatistic('PoolSize').getCurrent()            
            return
    except:
        return
    try:
        #print object.getName(), ", has subCollections..."
        for sub_item in sub:
            # print sub_item.getName()
            sub_name = sub_item.getName()
            listStatsSubCollections( object.getStats(sub_name) )
    except:
        print 'Unknown'
        return

listStatsSubCollections(stats)