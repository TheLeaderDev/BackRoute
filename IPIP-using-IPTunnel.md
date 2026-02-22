# IPIP using IP Tunnel

To set up IPIP on an IP Tunnel,
the steps are simpler.

Just follow the instructions below 

Install the initial prerequisites for IPIP :

<pre><code>sudo modprobe ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
echo -e '\e[32mIPIP Successfully Activated\e[0m'
</code></pre>
