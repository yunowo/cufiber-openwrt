import sys
import csv
import cucommon

INTERFACES = ['eth0.2'] + ['macvlan' + str(x) for x in range(1, 11)]

if __name__ == '__main__':
    logger = cucommon.get_logger('/tmp/cubatch.log')

    username = []
    password = []
    print(sys.path[0])
    with open(sys.path[0] + '/users.csv', 'r') as file:
        user_reader = csv.reader(file, delimiter=',')
        for row in user_reader:
            username.append(row[0])
            password.append(row[1])

    current = 0
    info = cucommon.IfInfo()
    for interface in INTERFACES:
        ip = info.get_ip(interface, logger)
        success = False
        retry = 0
        while not success and retry < 5 and current < len(username):
            result = cucommon.login(username[current], password[current], ip, logger)
            try:
                msg = result['msg']
                success = result['success'] == 'true'
                logger.info('Result: %s %s', username[current], msg)
                if msg == 'connection created':
                    success = True
                    current -= 1
            except:
                logger.error('Result: %s network error', username[current])
            finally:
                current += 1
                retry += 1
