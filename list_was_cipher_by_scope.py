import re

for SSL_configs in AdminTask.listSSLConfigs('[-all true]').splitlines():
    SSLconfig =  SSL_configs.split()[1]
    config_string = AdminTask.getSSLConfig(['-alias', SSLconfig])
    target_string = re.compile( r'.*securityLevel.(?P<SecurityLevel>\w+)].*'  ).match( config_string ) 
    if target_string:
        SecurityLevel =  target_string.groupdict()['SecurityLevel']
        print "SSLConfig Name:" + SSLconfig
        print "SecurityLevel :" + SecurityLevel
        print "CipherList:"
        print AdminTask.listSSLCiphers(['-sslConfigAliasName', SSLconfig,  '-securityLevel', SecurityLevel])
        print "----------------------------------------------------------------"
