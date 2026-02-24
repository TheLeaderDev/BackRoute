<p align="center">
  <a href="#persian-language">ترجمه فارسی</a>
</p>

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

# Configuration file setup on both Servers

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

<br>

<details>
<summary>Delete and Stop the Service</summary> <br>

If you experience any issues after applying the service, you can remove it using the command below :

```
sudo systemctl stop backroute-ipip.service
sudo systemctl disable backroute-ipip.service
sudo rm /etc/systemd/system/backroute-ipip.service
sudo systemctl daemon-reload
echo -e '\e[31mService BackRoute Completely Removed\e[0m'
```

</details

<br> <br>

# Creating a Cron Job (Optional)

By running the following command, a 10-minute cron job will be automatically set up :

```
(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart backroute-ipip.service") | crontab -
echo -e '\e[32mCron job BackRoute Successfully Created\e[0m'
```

<br>

<details>
<summary>Delete and Stop the Cron Job</summary> <br>

If you wish to remove the cron job, you can use the command below :

```
crontab -l | grep -v "systemctl restart backroute-ipip.service" | crontab -
echo -e '\e[31mCron job BackRoute Successfully Removed\e[0m'
```

</details

<br> <br>

# Remove All

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

-------------------------------------------------------------------------------------------------------------------------------------------------------------

<details dir="rtl" id="persian-language">
<summary>فارسی (کلیک برای باز کردن)</summary> <br>
<div dir="ltr">

<h1 dir="rtl">IPIP با استفاده از IP Tunnel</h1>

<p dir="rtl">
برای راه‌اندازی IPIP روی IP Tunnel، کار خیلی ساده تره  
فقط کافیه مراحل زیر رو دنبال کنید.
</p>

<h2 dir="rtl">نصب پیش‌نیازهای اولیه برای IPIP</h2>

<pre><code>sudo modprobe ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
sudo mkdir -p /root/backroute
echo -e '\e[32mIPIP Successfully Activated\e[0m'</code></pre>

<h2 dir="rtl">راه‌اندازی فایل پیکربندی روی هر دو سرور</h2>

<h3 dir="rtl">SERVER :</h3>
<p dir="rtl">
اسکریپت شروع تونل رو با این دستور بسازید:
</p>

<pre><code>sudo nano /root/backroute/backroute-ipip-start.sh</code></pre>

<p dir="rtl">
بعد کدهای زیر رو داخل فایل بذارید، در صورت نیاز مقادیر رو تغییر بدید و بعد <code>Ctrl + X</code> و <code>Y</code> بزنید:
</p>

<pre><code>sudo ip tunnel add BackRoute mode ipip local [SERVER_IP] remote [CLIENT_IP] ttl 255
sudo ip link set BackRoute up
sudo ip addr add 10.10.10.1/30 dev BackRoute</code></pre>

<h3 dir="rtl">CLIENT :</h3>

<pre><code>sudo nano /root/backroute/backroute-ipip-start.sh</code></pre>

<pre><code>sudo ip tunnel add BackRoute mode ipip local [CLIENT_IP] remote [SERVER_IP] ttl 255
sudo ip link set BackRoute up
sudo ip addr add 10.10.10.2/30 dev BackRoute</code></pre>

<h2 dir="rtl">ایجاد فایل سرویس</h2>

<p dir="rtl">
روی هر دو سرور اول فایل سرویس رو بسازید:
</p>

<pre><code>sudo nano /root/backroute/backroute-ipip-start.sh</code></pre>

<p dir="rtl">
این محتوا رو بدون تغییر داخل فایل بذارید و بعد <code>Ctrl + X</code> و <code>Y</code> بزنید:
</p>

<pre><code>[Unit]
Description=BackRoute IPIP Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backroute/backroute-ipip-start.sh
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target</code></pre>

<p dir="rtl">
حالا دسترسی‌های لازم رو به فایل بدید:
</p>

<pre><code>sudo chmod +x /root/backroute/backroute-ipip-start.sh</code></pre>

<p dir="rtl">
سرویس رو فعال کنید:
</p>

<pre><code>sudo systemctl daemon-reload
sudo systemctl enable backroute-ipip.service
sudo systemctl start backroute-ipip.service
echo -e '\e[32mService BackRoute Successfully Created\e[0m'</code></pre>

<br>

<details>
<summary dir="rtl">حذف و توقف سرویس</summary> <br>

اگه بعد از اعمال سرویس با مشکلی مواجه شدید، می‌تونید با استفاده از دستور زیر اون رو حذف کنید:

<pre><code>sudo systemctl stop backroute-ipip.service
sudo systemctl disable backroute-ipip.service
sudo rm /etc/systemd/system/backroute-ipip.service
sudo systemctl daemon-reload
echo -e '\e[31mService BackRoute Completely Removed\e[0m'</code></pre>

</details

<br> <br>

<h2 dir="rtl">ایجاد کران جاب (اختیاری)</h2>

<p dir="rtl">
با این دستور، کران جاب هر ۱۰ دقیقه یک‌بار سرویس BackRoute رو ریستارت می‌کنه:
</p>

<pre><code>(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart backroute-ipip.service") | crontab -
echo -e '\e[32mCron job BackRoute Successfully Created\e[0m'</code></pre>

<br>

<details>
<summary dir="rtl">حذف و توقف کرون‌جاب</summary> <br>

در صورت تمایل به حذف کرون‌جاب، می‌تونید از دستور زیر استفاده کنید:

<pre><code>crontab -l | grep -v "systemctl restart backroute-ipip.service" | crontab -
echo -e '\e[31mCron job BackRoute Successfully Removed\e[0m'</code></pre>

</details

<br> <br>

<h2 dir="rtl">حذف کامل</h2>

<pre><code>sudo systemctl stop backroute-ipip.service
sudo systemctl disable backroute-ipip.service
sudo rm /etc/systemd/system/backroute-ipip.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
sudo rm /root/backroute/backroute-ipip-start.sh
sudo ip link set BackRoute down
sudo ip tunnel del BackRoute
sudo rm -rf /root/backroute
echo -e '\e[31mCompletely Removed\e[0m'</code></pre>

</div>
</details>
