import re

PerfMbeanLists =  AdminControl.queryNames('type=Perf,*').split( lineSeparator)

for perfStr in PerfMbeanLists:
    perfObj = AdminControl.makeObjectName( perfStr)
    servername = perfObj.getKeyPropertyList()['process']
    if servername == 'nodeagent' or servername == 'dmgr':
        continue    
    srvrStr = AdminControl.queryNames('type=Server,process=%s,*' % servername)
    srvrObj = AdminControl.makeObjectName( srvrStr)
    params = [ srvrObj, java.lang.Boolean ('true')]
    sigs = ['javax.management.ObjectName', 'java.lang.Boolean']
    stats = AdminControl.invoke_jmx( perfObj, 'getStatsObject', params, sigs)
    
    try:
        apps = [ x for x in stats.getStats("webAppModule").subCollections() ]

        for app in apps:
            print app.getName()
            # print "RequestCount: ", app.getStats("webAppModule.servlets").getStatistic('RequestCount').getCount()
            print "Avg ServiceTime:  ", app.getStats("webAppModule.servlets").getStatistic('ServiceTime').getMean()

    except:
        pass