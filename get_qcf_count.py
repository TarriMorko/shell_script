import re

PerfMbeanLists =  AdminControl.queryNames('type=Perf,*').split( lineSeparator)

for perfStr in PerfMbeanLists:
    perfObj = AdminControl.makeObjectName( perfStr)
    servername = perfObj.getKeyPropertyList()['process'] 
    print servername
    if servername == 'nodeagent' or servername == 'dmgr':
        continue
    srvrStr = AdminControl.queryNames('type=Server,process=%s,*' % servername)
    srvrObj = AdminControl.makeObjectName( srvrStr)
    params = [ srvrObj, java.lang.Boolean ('true')]
    sigs = ['javax.management.ObjectName', 'java.lang.Boolean']
    stats = AdminControl.invoke_jmx( perfObj, 'getStatsObject', params, sigs)
    
    try:
        for subJCAconnectionpool in stats.getStats('j2cModule').subCollections(): 
            # print subJCAconnectionpool.getName
            for cf in subJCAconnectionpool.subCollections(): 
                qcf = re.compile( r'.*qcf*' ).match( cf.getName() ) # DEBUG
                if qcf:
                    print cf.getName()    # cf.listStatisticNames()
                    print cf.getStatistic('PoolSize').getCurrent()
    except:
        pass