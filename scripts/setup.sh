#!/bin/bash
# Set LAVA Server IP
if [[ -n "$LAVA_SERVER_IP" ]]; then
	sed -i "s/.*LAVA_SERVER_IP =.*/LAVA_SERVER_IP = $LAVA_SERVER_IP/g" /etc/lava-dispatcher/lava-dispatcher.conf
fi

# Create admin users
echo "from django.contrib.auth.models import User; User.objects.create_superuser('khilman', 'admin@localhost.com', 'lava4me')" | lava-server manage shell
echo "from django.contrib.auth.models import User; User.objects.create_superuser('jbrunet', 'admin@localhost.com', 'lava4me')" | lava-server manage shell
echo "from django.contrib.auth.models import User; User.objects.create_superuser('ptitiano', 'admin@localhost.com', 'lava4me')" | lava-server manage shell

# Add users and tokens from /tmp/tokens
for file in $(ls /tmp/tokens/*); do
    user=$(basename $file)
    token=$(cat $file)
    pwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    echo "Adding username $user with token $token"
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('$user', 'admin@localhost.com', '$pwd')" | lava-server manage shell
    lava-server manage tokens add --user $user --secret $token
    rm -f $file
done

# add remote workers
SLAVE=lab-slave-0
lava-server manage workers add $SLAVE

# add remote devices
/add-boards.py --slave $SLAVE
