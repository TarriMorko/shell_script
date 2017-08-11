
import re

PerfMbeanLists =  AdminControl.queryNames('type=Perf,*').split( lineSeparator)

for perfStr in PerfMbeanLists:
    perfObj = AdminControl.makeObjectName( perfStr)
    servername = perfObj.getKeyPropertyList()['process'] 
    srvrStr = AdminControl.queryNames('type=Server,process=%s,*' % servername)
    srvrObj = AdminControl.makeObjectName( srvrStr)
    params = [ srvrObj, java.lang.Boolean ('true')]
    sigs = ['javax.management.ObjectName', 'java.lang.Boolean']
    stats = AdminControl.invoke_jmx( perfObj, 'getStatsObject', params, sigs)
    
    try:
        for subJCAconnectionpool in stats.getStats('j2cModule').subCollections(): 
            # print subJCAconnectionpool.getName
            for cf in subJCAconnectionpool.subCollections(): 
                j2c = re.compile( r'.*j2c*' ).match( cf.getName() ) # DEBUG
                if j2c:
                    print cf.getName()    # cf.listStatisticNames()
                    print cf.getStatistic('PoolSize').getCurrent()
    except:
        pass