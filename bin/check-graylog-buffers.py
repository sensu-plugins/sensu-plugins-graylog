import urllib2
import json
import sys
import getopt
import socket

def main(argv):
    host = socket.getfqdn()
    user = "graylog2"
    password = "mypass"
    port = "12900"
    warnThreshold = 80.0
    critThreshold = 90.0
    try:
        opts, args = getopt.getopt(argv, "h:u:p:P:w:c:", ["host=","user=","pass=","port=", "warn=", "crit="])
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
        elif opt in ("-w", "--warn"):
            warnThreshold = float(arg)
        elif opt in ("-c", "--crit"):
            critThreshold = float(arg)

    # do stuff
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, 'http://'+ host + ':' + port + '/system/buffers', user, password)
    authhandler = urllib2.HTTPBasicAuthHandler(passman)
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)
    
    pagehandle = urllib2.urlopen('http://'+ host + ':' + port + '/system/buffers')
    data = json.load(pagehandle)

    if data['buffers']['process']['utilization_percent'] >= warnThreshold:
        print 'WARNING: process buffer utilization is %.2f%%, threshold is %.2f%%' % (data['buffers']['process']['utilization_percent'], warnThreshold)
        sys.exit(1)
    elif data['buffers']['process']['utilization_percent'] >= critThreshold:
        print 'CRITICAL: process buffer utilization is %.2f%%, threshold is %.2f%%' % (data['buffers']['process']['utilization_percent'], critThreshold)
        sys.exit(2)
    else:
        print 'OK: process buffer utilization is %.2f%%' % data['buffers']['process']['utilization_percent']
        sys.exit(0)

if __name__ == "__main__":
    main(sys.argv[1:])
