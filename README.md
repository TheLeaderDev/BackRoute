# BackRoute
Welcome to the `BackRoute` project!
BackRoute is a lightweight and reliable solution to create a tunnel between two servers using `IPv4` and `IPv6`, supporting `GRE`, `IPIP`, or `SIT`. This project runs on Netplan and establishes a connection between two servers with a simple configuration. Its goal is to provide a secure and stable connection across different networks, bypass restrictions, and keep data transfer fast and steady.

BackRoute creates a Layer 3 tunnel between the `SERVER` and a `CLIENT` server using local IPs. By default, this tunnel does not support Port Forwarding and only provides a secure path for data transfer. However, with your creativity, you can combine it with advanced tunneling tools and Port Forward setups to build a flexible and powerful system.

Keep in mind that these capabilities only work if your local IPs are not blocked by ISPs, network Routers, or filtering systems.

## Features
- **Local IP–Based Tunnel** <br> 
  The tunnel is established through locally created IPs that are only recognized by the two defined servers. Each side knows the real IP behind the virtual one.
- **Multiple Tunnel Modes**  <br>
  Supports **GRE**, **IPIP**, and **SIT**, allowing you to choose the most suitable method based on your network conditions.
- **IPv4 & IPv6 Support** <br> 
  Depending on the selected mode, you can create and use either IPv4 or IPv6 local addresses.
- **Secure Local Communication** <br> 
  The connection between servers is securely established through the generated local IPs.
- **Environment-Dependent Flexibility** <br> 
  Performance may vary depending on datacenter policies, ISP routing rules, intermediate routers, and filtering conditions. Different modes may perform better in different environments.
- **Composable with Port Forwarding** <br> 
  Fully compatible with Port Forward setups. With some creativity, you can combine BackRoute with other tunneling methods to build powerful solutions or even revive techniques that seem unusable.

## Before You Install
> The installation of this tunnel is completely manual, and there is no ready-made script available. <br>
> You need to perform the setup steps yourself and configure both servers (`SERVER` and `CLIENT`) <br>
> according to the instructions. Don’t worry; the process is simpler than it may seem. <br>
> In this project, you can create two types of IP addresses: IPv4 and IPv6. The type of IP depends on the method you choose <br>
> - `GRE` and `IPIP` create only local `IPv4` addresses.<br>
> - `SIT` provides only a local `IPv6` address. <br>

> The installation steps are divided into two main sections: IPv4 and IPv6. Each section contains <br>
> steps specific to the selected method, so you only need to follow the steps for the method you choose. <br>
> Whichever method you select, you must create the configuration files on both servers and fill in the values. <br>
> The values you are allowed to customize are explained below so you know exactly what each one does : <br>

> `mode` → used to select the tunnel method. <br>
> `local` → enter the IP of your current server here. <br>
> `remote` → enter the IP of the remote server here. <br>
> `addresses` → this is the local IP you are creating. You can change it if you are familiar with it; otherwise, do not modify it. <br>

## Installation and Configuration
#### First, install the general initial prerequisites :
```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install netplan.io -y
sudo apt-get install iproute2 -y
sudo mkdir -p /root/backroute
echo -e '\e[32mPackages & Prerequisites Installed\e[0m'
```

## Select your preferred Method

### IPV4 :
<details dir="ltr">
<summary>GRE Method</summary> <br>
  
Install the initial prerequisites for GRE mode :

<pre><code>sudo modprobe ip_gre
echo "ip_gre" | sudo tee /etc/modules-load.d/backroute-gre.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipv4.conf
sudo sysctl --system
echo -e '\e[32mGRE Successfully Activated\e[0m'
</code></pre>

First, we create the configuration file on the (Server) :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>


Place these values inside the file and customize them : <br>

<pre><code>network:
  version: 2 
  tunnels:
    BackRoute:
      mode: gre 
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 10.10.10.1/30
</code></pre>

Now, do the same on the (CLIENT) server.

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mode: gre
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 10.10.10.2/30
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

</details

<br> 

<details dir="ltr">
<summary>IPIP Method</summary> <br>

Install the initial prerequisites for IPIP mode :

<pre><code>sudo modprobe ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
echo -e '\e[32mIPIP Successfully Activated\e[0m'
</code></pre>

First, we create the configuration file on the (Server) :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

Place these values inside the file and customize them : <br>

<pre><code>network:
  version: 2 
  tunnels:
    BackRoute:
      mode: ipip 
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 10.10.10.1/30
</code></pre>

Now, do the same on the (CLIENT) server.

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mode: ipip
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 10.10.10.2/30
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

</details
   
<br>

### IPV6 :

<details dir="ltr">
<summary>SIT Method</summary> <br>

Install the initial prerequisites for SIT mode :

<pre><code>sudo modprobe sit
echo "sit" | sudo tee /etc/modules-load.d/backroute-sit.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee /etc/sysctl.d/backroute-ipv6.conf
sudo sysctl --system
echo -e '\e[32mSIT Successfully Activated\e[0m'
</code></pre>

First, we create the configuration file on the (Server) :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

Place these values inside the file and customize them : <br>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mode: sit
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 23e7:dc8:9a0::1/64
</code></pre>

Now, do the same on the (CLIENT) server.

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mode: sit
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 23e7:dc8:9a0::2/64   
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

</details

<br> <br> 

## Creating a System (Mandatory)

#### On both servers, first run the following command to create the service file :

```
sudo nano /etc/systemd/system/backroute.service
```
First, place the following contents directly into the file without making any changes, then press Ctrl + X + Y :

```
[Unit]
Description=BackRoute GRE Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backroute/backroute-start.sh
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
```

Now enter the following command to create the BackRoute service start file :

```
sudo nano /root/backroute/backroute-start.sh
```
Place the following contents into the file, then press Ctrl + X + Y :

```
#!/bin/bash
sudo netplan apply
```
Give the file the necessary permissions :

```
sudo chmod +x /root/backroute/backroute-start.sh
```
Enable the service :

```
sudo systemctl daemon-reload
sudo systemctl enable backroute.service
sudo systemctl start backroute.service
echo -e '\e[32mService BackRoute Successfully Created\e[0m'
```

## Creating a Cron Job (Optional)

By running the following command, a 10-minute cron job will be automatically set up :

```
(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart backroute.service") | crontab -
echo -e '\e[32mCron job BackRoute Successfully Created\e[0m'
```
