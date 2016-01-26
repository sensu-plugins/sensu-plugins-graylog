import urllib2
import json
import sys
import getopt
import socket
import time

def main(argv):
    host = socket.getfqdn()
    user = "graylog2"
    password = "mypass"
    port = "12900"
    try:
        opts, args = getopt.getopt(argv, "h:u:p:P:", ["host=","user=","pass=","port="])
    except getopt.GetoptError:
        print 'flag error'
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--host"):
            host = arg
        elif opt in ("-u", "--user"):
            user = arg
        elif opt in ("-p", "--pass"):
            password = arg
        elif opt in ("-P", "--port"):
            port = arg

    # do stuff
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, 'http://'+ host + ':' + port + '/system/metrics', user, password)
    authhandler = urllib2.HTTPBasicAuthHandler(passman)
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)
    
    pagehandle = urllib2.urlopen('http://'+ host + ':' + port + '/system/metrics')
    data = json.load(pagehandle)

    print 'graylog.%s.graylog.kafkajournal.uncommittedMessages %d %d\n' % (host, data['gauges']['org.graylog2.shared.journal.KafkaJournal.uncommittedMessages']['value'], int(time.time()))
    print 'graylog.%s.graylog.kafkajournal.unflushedMessages %d %d\n' % (host, data['gauges']['org.graylog2.shared.journal.KafkaJournal.unflushedMessages']['value'], int(time.time()))
    sys.exit(0)

if __name__ == "__main__":
    main(sys.argv[1:])
