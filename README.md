# BackRoute
Welcome to the `BackRoute` project! <br>
BackRoute is a lightweight and reliable solution to create a `tunnel` between two servers <br>
using `IPv4` and `IPv6`, supporting `GRE`, `IPIP`, or `SIT`. It is designed to provide a secure <br>
and stable connection across different networks, bypass restrictions, and keep data transfer fast and steady. <br>

BackRoute creates a Layer 3 tunnel between a client server and a remote server using local IPs. By default, <br>
it does not support Port Forwarding and simply provides a secure path for data transfer. However, with your creativity, <br>
you can combine it with advanced tunneling tools and Port Forward setups to build a flexible and powerful system. <br>

Keep in mind that these capabilities only work if your local IPs are not blocked by ISPs, network routers, or filtering systems.

## Features
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
> The installation of this tunnel is completely manual there’s no ready made installation script involved. You’ll need to go through the setup steps yourself and configure both servers (`remote` and `client`)      according to the instructions provided below. Don’t worry it’s simpler than you might think.
> This tunnel ultimately gives you a `local IP` in fact, two “non real” IPs that only the two defined servers recognize, and only they know which real IP is hidden behind them. In total, you can create two types of > IP addresses: `IPv4` and `IPv6`.
> This entirely depends on the mode you choose:
> - `GRE` and `IPIP` both create only local `IPv4` addresses.
> - `SIT` can only provide a local `IPv6` address.

> If I had to recommend one of the modes, I would definitely suggest GRE.
> However, as mentioned earlier, the final choice entirely depends on your server’s datacenter, ISP routing policies, intermediate router configurations, and the filtering conditions in your network.
> In general, the rules and restrictions can vary significantly from one country or network to another, and only through your own testing and evaluation can you determine the most optimal setup.

> I will divide the installation steps into two main categories:
> IPv4 and IPv6
> Each category has its own steps depending on the method you choose, and you can follow only the steps related to your selected method.

## Installation and Configuration
#### First, install the general initial prerequisites :
```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install netplan.io -y
sudo apt-get install iproute2 -y
sudo mkdir -p /root/backroute
echo -e '\e[32mPackages & prerequisites installed\e[0m'
```
#### IPV4 :
<details dir="ltr">
<summary>GRE Method</summary> <br>
  
Install the initial prerequisites for GRE mode :

<pre><code>sudo modprobe ip_gre
echo "ip_gre" | sudo tee /etc/modules-load.d/backroute-gre.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipv4.conf
sudo sysctl --system
echo -e '\e[32mGRE successfully activated\e[0m'
</code></pre>

First, we create the configuration file on the Server :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>


Place these values inside the file and customize them : <br>
The values you are allowed to customize, in order, are: mode, local, remote, and addresses. <br>
- mode → used to select the tunnel method. <br>
- local → enter the IP of your current server here. <br>
- remote → enter the IP of the remote server here. <br>
- addresses → this is the local IP you are creating. You can change it if you are familiar with it; if not, do not modify it.


<pre><code>network:
  version: 2 
  tunnels:
    BackRoute:
      mode: gre 
      local: 0.0.0.0
      remote: 0.0.0.0
      addresses:
        - 10.10.10.1/30
</code></pre>

Now, do the same exact configuration file setup for the opposite server as well :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mode: gre
      local: 0.0.0.0
      remote: 0.0.0.0
      addresses:
        - 10.10.10.2/30
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

</details
