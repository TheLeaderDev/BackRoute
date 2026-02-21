# BackRoute
Welcome to the `BackRoute` project! BackRoute is a lightweight and reliable solution to create a tunnel between two servers with `IPv4` and `IPv6`, using `GRE`, `IPIP`, or `SIT`. This project is designed to build a secure and stable connection between servers across different networks, bypass restrictions, and keep your data transfer fast and steady. In this README, you’ll find step-by-step instructions for installing, configuring, and running BackRoute, including details on tunnel modes and how to run the tunnel continuously as a `service` without interruptions.
## Introduction
BackRoute creates a Layer 3 network tunnel that can establish a connection between a client server and a remote server using different modes with local IPs. By default, this tunnel doesn’t support Port Forwarding and simply provides a secure path for data transfer between the IPs. But this is where your creativity comes in !! you can combine BackRoute with advanced tunneling tools and Port Forward setups to build a flexible and powerful system that goes beyond the limitations of a simple Layer 3 tunnel. Sometimes, combining BackRoute with tools that seem broken can work like a charm.

Of course, it’s worth noting that all these capabilities only hold if your local IPs on the servers aren’t blocked by ISPs, network routers, or filtering systems.

## Features
- **Insane Speed & Reliability :** In most tests, the tunnel speed has been really high, though of course it depends on the datacenter, server, ISP restrictions, routers, and filtering systems. Overall, the speed is seriously awesome and trustworthy.
- **Layer 3 Network Tunnel :** Provides a secure path for data transfer between local IPs on the client server and the remote server.
- **Multiple Tunnel Modes :** Supports GRE, IPIP, and SIT, so you can pick the mode that fits your needs.
- **No Default Port Forwarding :** The tunnel only provides a path between IPs and doesn’t include port forwarding but that doesn’t stop your creativity.
- **Composable & Flexible :** You can combine BackRoute with other tunneling tools and Port Forward setups to build a powerful and flexible system that goes beyond the limits of a simple Layer 3 tunnel.
- **Reliability & Persistence :** Sometimes combining BackRoute with other tools can literally bring something back to life !!. You have two local IPs to play with—so don’t be afraid to mix things up and unleash your creativity.

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

Now, do the same exact configuration file setup for the opposite server as well.

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

</details
