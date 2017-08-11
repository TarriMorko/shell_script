
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
        for apps in stats.getStats('webAppModule').subCollections(): 
            print apps.getName()
            for war in apps.subCollections(): 
                print war.getName()    # war.listStatisticNames()
                print war.getStatistic('ServiceTime').getCount()   # DEBUG
    except:
        pass