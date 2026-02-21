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
> If I had to recommend one mode, I would definitely suggest GRE.
