FROM kernelci/lava-docker:2017.06

# Add device configuration
COPY devices/* /etc/lava-server/dispatcher-config/devices/
COPY device-types/* /etc/lava-server/dispatcher-config/device-types

COPY scripts/setup.sh .

EXPOSE 69/udp 80 3079 5555 5556

CMD /start.sh && /setup.sh && bash
