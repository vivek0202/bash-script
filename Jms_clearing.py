from java.lang import System

uname = raw_input('Enter WebLogic Admin Username: ')
pwd = System.console().readPassword('Enter WebLogic Admin Password: ')
url = raw_input('Enter Admin URL (e.g., t3://localhost:7001): ')

try:
    connect(uname, pwd, url)
except:
    print('Unable to connect to admin server at ' + url)
    exit()

print 'JMS Queue depths'
servers = domainRuntimeService.getServerRuntimes()
if (len(servers) > 0):
    for server in servers:
        jmsRuntime = server.getJMSRuntime()
        jmsServers = jmsRuntime.getJMSServers()
        for jmsServer in jmsServers:
            destinations = jmsServer.getDestinations()
            for destination in destinations:
                name = destination.getName()
                pending = destination.getMessagesPendingCount()
                if pending > 0:
                    cleared = destination.deleteMessages("")
                    print "Queue:", name, "Pending:", pending, "Cleared:", cleared
