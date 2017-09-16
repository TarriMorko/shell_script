import re

search_text = "j2c"

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
    
def listStatsSubCollections( object ):

    sub = object.subCollections()
    if not sub:
        target_stat = re.compile( r'.*' + search_text + '*' ).match( object.getName() )
        if target_stat:
            print object.getName()
            print object.getStatistic('PoolSize').getCurrent()            
        return

    for sub_item in sub:
        sub_name = sub_item.getName()
        listStatsSubCollections( object.getStats(sub_name) )


listStatsSubCollections(stats)