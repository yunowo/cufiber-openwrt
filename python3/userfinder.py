import ifcfg

import cucommon

INTERFACES = []

if __name__ == '__main__':
    logger = cucommon.get_logger('/tmp/userfinder.log')

    with open('userfinder.txt', 'r') as file:
        usernum = int(file.readline().strip('\n'))
        begin = int(file.readline().strip('\n'))
        password = file.readline().strip('\n')
        INTERFACES = file.readline().strip('\n').split(',')
    current_user = begin
    info = cucommon.IfInfo()
    for interface in INTERFACES:
        ip = info.get_ip(interface, logger)

        success = False
        while not success and current_user - begin < usernum:
            result = cucommon.login(str(current_user), password, ip, logger)
            try:
                msg = result['msg']
                success = result['success'] == 'true'
                logger.info('Result: %s %s', current_user, msg)
                if success is True:
                    with open('users.txt', 'a') as file:
                        file.write(str(current_user) + "," + password + "\n")
                if msg == 'connection created':
                    success = True
                    current_user -= 1
            except:
                logger.error('Result: %s network error', current_user)
            finally:
                current_user += 1
