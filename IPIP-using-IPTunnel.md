# IPIP using IP Tunnel

To set up IPIP on an IP Tunnel,
the steps are simpler.

Just follow the instructions below 

Install the initial prerequisites for IPIP :

<pre><code>sudo modprobe ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
sudo mkdir -p /root/backroute
echo -e '\e[32mIPIP Successfully Activated\e[0m'
</code></pre>

### SERVER :

Create the tunnel start script using the following command :

```
sudo nano /root/backroute/backroute-ipip-start.sh
```

Now, place the script codes into the file, customize them, and then press Ctrl + X + Y:

```
sudo ip tunnel add BackRoute mode ipip local [SERVER_IP] remote [CLIENT_IP] ttl 255
sudo ip link set BackRoute up
sudo ip addr add 10.10.10.1/30 dev BackRoute
```

### CLIENT :

```
sudo nano /root/backroute/backroute-ipip-start.sh
```

```
sudo ip tunnel add BackRoute mode ipip local [CLIENT_IP] remote [SERVER_IP] ttl 255
sudo ip link set BackRoute up
sudo ip addr add 10.10.10.2/30 dev BackRoute
```

# Create the Service File

On both servers, first run the following command to create the service file :

```
sudo nano /root/backroute/backroute-ipip-start.sh
```

First, place the following contents directly into the file without making any changes, then press Ctrl + X + Y :

```
[Unit]
Description=BackRoute IPIP Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backroute/backroute-ipip-start.sh
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
```

Give the file the necessary permissions :

```
sudo chmod +x /root/backroute/backroute-ipip-start.sh
```

Enable the service :

```
sudo systemctl daemon-reload
sudo systemctl enable backroute-ipip.service
sudo systemctl start backroute-ipip.service
echo -e '\e[32mService BackRoute Successfully Created\e[0m'
```

# ## Remove All

```
sudo systemctl stop backroute-ipip.service
sudo systemctl disable backroute-ipip.service
sudo rm /etc/systemd/system/backroute-ipip.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
sudo rm /root/backroute/backroute-ipip-start.sh
sudo ip link set BackRoute down
sudo ip tunnel del BackRoute
sudo rm -rf /root/backroute
echo -e '\e[31mCompletely Removed\e[0m'
```
