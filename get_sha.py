import os
import subprocess

def run():
    home = os.path.expanduser('~')
    keystore = os.path.join(home, '.android', 'debug.keystore')
    try:
        out = subprocess.check_output(f'keytool -keystore {keystore} -list -v -storepass android', shell=True)
        with open('keytool_out.txt', 'wb') as f:
            f.write(out)
    except Exception as e:
        with open('keytool_out.txt', 'w') as f:
            f.write(str(e))

run()
