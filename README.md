<p align="center">
  <a href="#persian-language">ترجمه فارسی</a>
</p>

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
> `mtu` → maximum packet size that can pass through this tunnel. Make sure it’s ≤ the physical interface MTU. <br>
> `dontfragment` → prevents packets larger than MTU from being split; oversized packets will be dropped instead of fragmented.

> ⚠️ BackRoute works best on `Ubuntu 22`. Other versions are not recommended.

## Installing the initial Prerequisites
First of all, before anything else and before selecting your desired method, install the prerequisites on both servers using the command below.
```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install netplan.io -y
sudo apt-get install iproute2 -y
sudo mkdir -p /root/backroute
echo -e '\e[32mPackages & Prerequisites Installed\e[0m'
```
## Configuration of both Servers
### Select your preferred Method :

<br>

### IPV4 :
<details dir="ltr">
<summary>GRE Method</summary> <br>
  
Install the initial prerequisites for GRE mode :

Execute the following command on both servers to remove potential system limitations and prepare them for deploying the GRE method.
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
Note: After entering the server and client IP addresses in the configuration file, press `Ctrl` + `X` and then `Y` to save the file.
<pre><code>network:
  version: 2 
  tunnels:
    BackRoute:
      mtu: 1500
      mode: gre
      dontfragment: true
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
      mtu: 1500
      mode: gre
      dontfragment: true
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
Execute the following command on both servers to remove potential system limitations and prepare them for deploying the IPIP method.
<pre><code>sudo modprobe ipip
lsmod | grep ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
echo -e '\e[32mIPIP Successfully Activated\e[0m'
</code></pre>

First, we create the configuration file on the (Server) :

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
</code></pre>

Place these values inside the file and customize them : <br>
Note: After entering the server and client IP addresses in the configuration file, press `Ctrl` + `X` and then `Y` to save the file.
<pre><code>network:
  version: 2 
  tunnels:
    BackRoute:
      mtu: 1500
      mode: ipip
      dontfragment: true
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
      mtu: 1500
      mode: ipip
      dontfragment: true
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 10.10.10.2/30
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

<br>

⚠️ If IPIP on `Netplan` doesn’t work for you, an alternative is to create it directly using `IP Tunnel`.
I’ll put the details in a separate `README`. If you’re interested in this mode, you can try that method as well. <br>

<a align="left" href="https://github.com/TheLeaderDev/BackRoute/blob/main/IPTunnel.md">🔗 Click the link below</a>

</details

<br>
<br> 

### IPV6 :

<details dir="ltr">
<summary>SIT Method</summary> <br>

Install the initial prerequisites for SIT mode :
Execute the following command on both servers to remove potential system limitations and prepare them for deploying the SIT method.
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
Note: After entering the server and client IP addresses in the configuration file, press `Ctrl` + `X` and then `Y` to save the file.
<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: sit
      dontfragment: true
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
      mtu: 1500
      mode: sit
      dontfragment: true
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 23e7:dc8:9a0::2/64  
</code></pre>

To apply the changes on both servers, run the following command. After a reboot, the local IPs will be set :

<pre><code>sudo netplan apply
sudo reboot
</code></pre>

<br>

⚠️ Remember, for the SIT method to work, IPv6 must not be blocked by ISPs, routers, or the datacenter.

</details

<br> <br> 

## Creating a System (Mandatory)

#### On both servers, first run the following command to create the service file :

```
sudo nano /etc/systemd/system/backroute.service
```
First, place the following contents directly into the file without making any changes, then press `Ctrl` + `X` followed by `Y` to save :

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
Place the following contents into the file, then press `Ctrl` + `X` followed by `Y` to save :

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
sudo systemctl status backroute.service
echo -e '\e[32mService BackRoute Successfully Created\e[0m'
```

## Creating a Cron Job (Optional)

By running the following command, a 10-minute cron job will be automatically set up :

```
(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart backroute.service") | crontab -
echo -e '\e[32mCron job BackRoute Successfully Created\e[0m'
```

## Remove BackRoute

```
sudo systemctl stop backroute.service
sudo systemctl disable backroute.service
sudo rm -f /etc/systemd/system/backroute.service
sudo systemctl daemon-reload
sudo rm -f /etc/netplan/BackRoute.yaml
sudo rm -f /root/backroute/backroute-start.sh
crontab -l 2>/dev/null | grep -v 'backroute.service' | crontab -
sudo rm -rf /root/backroute
echo -e '\e[31mBackRoute Completely Removed\e[0m'
```
<br>

# Give a Star
If you liked it, supporting me is completely free — just give this project a Star ⭐

<div class="markdown-heading" dir="auto">
        <h2 class="heading-element" dir="auto">
            <a href="https://github.com/Amir-Hosein-Amiri">
                <img target="_blank" src="https://amir8218.ir/GitHub/SVG/Follow-Me.svg" alt="Follow Me :">
            </a>
        </h2>
        <a id="user-content--socials" class="anchor" aria-label="Permalink: 🌐 Socials:" href="https://github.com/Amir-Hosein-Amiri">
            <svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true">
                <path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 
                         .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 
                         1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83
                         l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042
                         Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018
                         .751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95
                         l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042
                         .751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0
                         l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z">
                </path>
            </svg>
        </a>
    </div>

<p dir="auto">
        <!-- <a href="https://wa.me/+98" rel="nofollow">
            <img src="https://img.shields.io/badge/WhatsApp-url?style=for-the-badge&logo=WhatsApp&logoColor=%2325D366&color=%23082032" alt="WhatsApp" style="max-width: 100%;">
        </a> -->
        <a target="_blank" href="https://www.instagram.com/TheLeaderDev" rel="nofollow">
            <img src="https://img.shields.io/badge/instagram-%23082032?style=for-the-badge&logo=instagram&logoColor=%23FD0AB6&color=%23082032" alt="Instagram" style="max-width: 100%;">
        </a>
        <a target="_blank" href="https://t.me/TheLeaderDev" rel="nofollow">
            <img src="https://img.shields.io/badge/telegram-url?style=for-the-badge&logo=telegram&logoColor=%232CA5E0&color=%23082032" alt="telegram" style="max-width: 100%;">
        </a>
        <a target="_blank" href="https://www.linkedin.com/in/TheLeaderDev" rel="nofollow">
            <img src="https://amir8218.ir/GitHub/Logo/Profiles/LINKEDIN%20.svg" alt="LinkedIn" style="max-width: 100%;">
        </a>
    </p>



-------------------------------------------------------------------------------------------------------------------------------------------------------------

<details dir="rtl" id="persian-language">
<summary>فارسی (کلیک برای باز کردن)</summary> <br>
<div dir="ltr">

<h1 dir="rtl">BackRoute</h1>

<p dir="rtl">
به پروژه <code>BackRoute</code> خوش آمدید!<br>
BackRoute یک راهکار سبک و قابل اعتماد برای ایجاد یک تونل بین دو سرور با استفاده از <code>IPv4</code> و <code>IPv6</code> است که از <code>GRE</code>، <code>IPIP</code> یا <code>SIT</code> پشتیبانی می‌کند.<br>
یک پیکربندی ساده، اتصال بین دو سرور را برقرار می‌کند. هدف آن فراهم کردن یک ارتباط امن و پایدار در میان شبکه‌های مختلف، عبور از محدودیت‌ها و حفظ سرعت و ثبات انتقال داده است.
</p>

<p dir="rtl">
BackRoute یک تونل لایه ۳ بین سرور <code>SERVER</code> و یک سرور <code>CLIENT</code> با استفاده از IPهای محلی ایجاد می‌کند. به‌صورت پیش‌فرض، این تونل از Port Forwarding پشتیبانی نمی‌کند و تنها یک مسیر امن برای انتقال داده فراهم می‌سازد.<br>
با این حال، با خلاقیت شما می‌توان آن را با ابزارهای پیشرفته تونل‌سازی و تنظیمات Port Forward ترکیب کرد تا یک سیستم منعطف و قدرتمند بسازید.
</p>

<h2 dir="rtl">ویژگی‌ها</h2>
<ul dir="rtl">
<li><strong>تونل مبتنی بر IP محلی</strong><br>
تونل از طریق IPهای محلی ایجاد می‌شود که فقط توسط دو سرور تعریف شده شناخته می‌شوند. هر سمت، IP واقعی پشت IP مجازی را می‌داند.</li>

<li><strong>حالت‌های متعدد تونل</strong><br>
پشتیبانی از <code>GRE</code>، <code>IPIP</code> و <code>SIT</code> و امکان انتخاب مناسب‌ترین روش بر اساس شرایط شبکه شما.</li>

<li><strong>پشتیبانی از IPv4 و IPv6</strong><br>
بسته به حالت انتخابی، می‌توانید از آدرس‌های محلی IPv4 یا IPv6 استفاده کنید.</li>

<li><strong>ارتباط امن محلی</strong><br>
اتصال بین سرورها با استفاده از IPهای محلی ایجاد شده، به صورت امن برقرار می‌شود.</li>

<li><strong>انعطاف‌پذیری وابسته به محیط</strong><br>
عملکرد ممکن است بسته به سیاست‌های دیتاسنتر، قوانین مسیریابی ISP، روترهای میانی و شرایط فیلترینگ متفاوت باشد. حالت‌های مختلف ممکن است در محیط‌های متفاوت عملکرد بهتری داشته باشند.</li>

<li><strong>قابلیت ترکیب با Port Forwarding</strong><br>
کاملاً با تنظیمات Port Forward سازگار است. با کمی خلاقیت می‌توان BackRoute را با روش‌های تونل‌سازی دیگر ترکیب کرد و راهکارهای قدرتمند ایجاد نمود.</li>
</ul>

<h2 dir="rtl">قبل از نصب</h2>
<p dir="rtl">
نصب این تونل کاملاً دستی است و هیچ اسکریپت آماده‌ای وجود ندارد.<br>
شما باید مراحل راه‌اندازی را خودتان انجام داده و هر دو سرور (<code>SERVER</code> و <code>CLIENT</code>) را طبق دستورالعمل پیکربندی کنید. نگران نباشید؛ فرآیند ساده‌تر از آن چیزی است که تصور می‌کنید.<br>
در این پروژه می‌توانید دو نوع آدرس IP ایجاد کنید: IPv4 و IPv6. نوع IP به روش انتخابی شما بستگی دارد.<br>
- <code>GRE</code> و <code>IPIP</code> فقط آدرس محلی IPv4 ایجاد می‌کنند.<br>
- <code>SIT</code> فقط آدرس محلی IPv6 ایجاد می‌کند.
</p>

<p dir="rtl">
مراحل نصب به دو بخش اصلی تقسیم شده‌اند: IPv4 و IPv6. هر بخش شامل مراحل خاص روش انتخابی است، بنابراین فقط باید مراحل روش انتخابی خود را دنبال کنید.<br>
هر روشی که انتخاب کنید، باید فایل‌های پیکربندی را روی هر دو سرور ایجاد کرده و مقادیر آن‌ها را پر کنید. مقادیر قابل تنظیم در ادامه توضیح داده شده‌اند:
</p>

<ul dir="rtl">
<li><code>mode</code> → برای انتخاب روش تونل استفاده می‌شود.</li>
<li><code>local</code> → آدرس IP سرور خودتان را اینجا وارد کنید.</li>
<li><code>remote</code> → آدرس IP سرور دور را اینجا وارد کنید.</li>
<li><code>addresses</code> → این همان IP محلی است که ایجاد می‌کنید. اگر با آن آشنا هستید می‌توانید تغییر دهید، در غیر این صورت تغییر ندهید.</li>
<li><code>mtu</code> → حداکثر اندازه بسته‌ای که از تونل عبور می‌کند. مطمئن شوید ≤ MTU اینترفیس فیزیکی باشد.</li>
<li><code>dontfragment</code> → مانع از تقسیم بسته‌های بزرگتر از MTU می‌شود؛ بسته‌های بزرگ حذف می‌شوند و تقسیم نمی‌شوند.</li>
</ul>

<p dir="rtl">
⚠️ BackRoute بهترین عملکرد را روی <code>Ubuntu 22</code> دارد. نسخه‌های دیگر توصیه نمی‌شوند.
</p>

<h2 dir="rtl">نصب پیش‌نیازهای اولیه</h2>
<p dir="rtl">
ابتدا، قبل از هر چیز و قبل از انتخاب روش موردنظر خود، پیش‌نیازها را روی هر دو سرور نصب کنید:
</p>

<pre><code>sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install netplan.io -y
sudo apt-get install iproute2 -y
sudo mkdir -p /root/backroute
echo -e '\e[32mPackages & Prerequisites Installed\e[0m'</code></pre>

<h2 dir="rtl">پیکربندی هر دو سرور</h2>
<h3 dir="rtl">انتخاب روش موردنظر:</h3>

<h3 dir="rtl">IPv4</h3>

<details dir="rtl">
<summary>روش GRE</summary>

<p dir="rtl">
نصب پیش‌نیازها برای حالت GRE: دستور زیر را روی هر دو سرور اجرا کنید تا محدودیت‌های احتمالی سیستم حذف شده و آماده اجرای GRE شوید:
</p>

<pre><code>sudo modprobe ip_gre
echo "ip_gre" | sudo tee /etc/modules-load.d/backroute-gre.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipv4.conf
sudo sysctl --system
echo -e '\e[32mGRE Successfully Activated\e[0m'</code></pre>

<p dir="rtl">
ابتدا فایل پیکربندی را روی سرور <code>SERVER</code> ایجاد کنید:
</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml</code></pre>

<p dir="rtl">
مقادیر زیر را داخل فایل قرار داده و در صورت نیاز تغییر دهید. بعد از وارد کردن آدرس‌ها، <code>Ctrl + X</code> و <code>Y</code> را فشار دهید تا ذخیره شود:
</p>

<pre><code>network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: gre
      dontfragment: true
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 10.10.10.1/30</code></pre>

<p dir="rtl">همین کار را روی سرور <code>CLIENT</code> انجام دهید:</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: gre
      dontfragment: true
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 10.10.10.2/30</code></pre>

<p dir="rtl">
برای اعمال تغییرات روی هر دو سرور:
</p>

<pre><code>sudo netplan apply
sudo reboot</code></pre>
</details>

<details dir="rtl">
<summary>روش IPIP</summary>

<p dir="rtl">
نصب پیش‌نیازها برای حالت IPIP: دستور زیر را روی هر دو سرور اجرا کنید تا آماده اجرای IPIP شوید:
</p>

<pre><code>sudo modprobe ipip
lsmod | grep ipip
echo "ipip" | sudo tee /etc/modules-load.d/backroute-ipip.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/backroute-ipip.conf
sudo sysctl --system
echo -e '\e[32mIPIP Successfully Activated\e[0m'</code></pre>

<p dir="rtl">
فایل پیکربندی روی سرور <code>SERVER</code> ایجاد شود:
</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: ipip
      dontfragment: true
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 10.10.10.1/30</code></pre>

<p dir="rtl">
روی سرور <code>CLIENT</code> همین کار را انجام دهید:
</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: ipip
      dontfragment: true
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 10.10.10.2/30</code></pre>

<p dir="rtl">
اعمال تغییرات:
</p>

<pre><code>sudo netplan apply
sudo reboot</code></pre>

<p dir="rtl">
⚠️ اگر IPIP روی Netplan کار نکرد، می‌توانید به طور مستقیم از IP Tunnel استفاده کنید. جزئیات در README جداگانه موجود است.
</p>

</details>

<h3 dir="rtl">IPv6</h3>

<details dir="rtl">
<summary>روش SIT</summary>

<p dir="rtl">
نصب پیش‌نیازها برای حالت SIT: دستور زیر را روی هر دو سرور اجرا کنید تا آماده اجرای SIT شوید:
</p>

<pre><code>sudo modprobe sit
echo "sit" | sudo tee /etc/modules-load.d/backroute-sit.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee /etc/sysctl.d/backroute-ipv6.conf
sudo sysctl --system
echo -e '\e[32mSIT Successfully Activated\e[0m'</code></pre>

<p dir="rtl">
ایجاد فایل پیکربندی روی سرور <code>SERVER</code>:
</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: sit
      dontfragment: true
      local: [SERVER]
      remote: [CLIENT]
      addresses:
        - 23e7:dc8:9a0::1/64</code></pre>

<p dir="rtl">
روی سرور <code>CLIENT</code> همین کار را انجام دهید:
</p>

<pre><code>sudo nano /etc/netplan/BackRoute.yaml
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: 1500
      mode: sit
      dontfragment: true
      local: [CLIENT]
      remote: [SERVER]
      addresses:
        - 23e7:dc8:9a0::2/64</code></pre>

<p dir="rtl">
اعمال تغییرات:
</p>

<pre><code>sudo netplan apply
sudo reboot</code></pre>

<p dir="rtl">
⚠️ برای روش SIT، مطمئن شوید IPv6 توسط ISP، روترها یا دیتاسنتر مسدود نشده باشد.
</p>

</details>

<h2 dir="rtl">ایجاد سرویس سیستم (اجباری)</h2>

<p dir="rtl">
روی هر دو سرور، ابتدا فایل سرویس را ایجاد کنید:
</p>

<pre><code>sudo nano /etc/systemd/system/backroute.service</code></pre>

<p dir="rtl">
محتوای زیر را در فایل قرار دهید و سپس <code>Ctrl + X</code> و <code>Y</code> را فشار دهید:
</p>

<pre><code>[Unit]
Description=BackRoute GRE Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backroute/backroute-start.sh
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target</code></pre>

<p dir="rtl">
فایل شروع BackRoute را ایجاد کنید:
</p>

<pre><code>sudo nano /root/backroute/backroute-start.sh
#!/bin/bash
sudo netplan apply</code></pre>

<p dir="rtl">
دسترسی‌های لازم را به فایل بدهید:
</p>

<pre><code>sudo chmod +x /root/backroute/backroute-start.sh</code></pre>

<p dir="rtl">
سرویس را فعال کنید:
</p>

<pre><code>sudo systemctl daemon-reload
sudo systemctl enable backroute.service
sudo systemctl start backroute.service
sudo systemctl status backroute.service
echo -e '\e[32mService BackRoute Successfully Created\e[0m'</code></pre>

<h2 dir="rtl">ایجاد کران جاب (اختیاری)</h2>

<p dir="rtl">
با دستور زیر، کران جاب هر ۱۰ دقیقه یکبار سرویس BackRoute را ریستارت می‌کند:
</p>

<pre><code>(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart backroute.service") | crontab -
echo -e '\e[32mCron job BackRoute Successfully Created\e[0m'</code></pre>

<h2 dir="rtl">حذف BackRoute</h2>

<pre><code>sudo systemctl stop backroute.service
sudo systemctl disable backroute.service
sudo rm -f /etc/systemd/system/backroute.service
sudo systemctl daemon-reload
sudo rm -f /etc/netplan/BackRoute.yaml
sudo rm -f /root/backroute/backroute-start.sh
crontab -l 2>/dev/null | grep -v 'backroute.service' | crontab -
sudo rm -rf /root/backroute
echo -e '\e[31mBackRoute Completely Removed\e[0m'</code></pre>

<h2 dir="rtl">حمایت از پروژه</h2>

<p dir="rtl">
اگر از این پروژه خوشتان آمد، حمایت از من کاملاً رایگان است — فقط یک ستاره ⭐ بدهید.
</p>


  <div class="markdown-heading" dir="auto">
        <h2 class="heading-element" dir="auto">
            <a href="https://github.com/Amir-Hosein-Amiri">
                <img target="_blank" src="https://amir8218.ir/GitHub/SVG/Follow-Me.svg" alt="Follow Me :">
            </a>
        </h2>
        <a id="user-content--socials" class="anchor" aria-label="Permalink: 🌐 Socials:" href="https://github.com/Amir-Hosein-Amiri">
            <svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true">
                <path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 
                         .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 
                         1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83
                         l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042
                         Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018
                         .751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95
                         l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042
                         .751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0
                         l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z">
                </path>
            </svg>
        </a>
    </div>

<p dir="auto">
        <!-- <a href="https://wa.me/+98" rel="nofollow">
            <img src="https://img.shields.io/badge/WhatsApp-url?style=for-the-badge&logo=WhatsApp&logoColor=%2325D366&color=%23082032" alt="WhatsApp" style="max-width: 100%;">
        </a> -->
        <a target="_blank" href="https://www.instagram.com/TheLeaderDev" rel="nofollow">
            <img src="https://img.shields.io/badge/instagram-%23082032?style=for-the-badge&logo=instagram&logoColor=%23FD0AB6&color=%23082032" alt="Instagram" style="max-width: 100%;">
        </a>
        <a target="_blank" href="https://t.me/TheLeaderDev" rel="nofollow">
            <img src="https://img.shields.io/badge/telegram-url?style=for-the-badge&logo=telegram&logoColor=%232CA5E0&color=%23082032" alt="telegram" style="max-width: 100%;">
        </a>
        <a target="_blank" href="https://www.linkedin.com/in/TheLeaderDev" rel="nofollow">
            <img src="https://amir8218.ir/GitHub/Logo/Profiles/LINKEDIN%20.svg" alt="LinkedIn" style="max-width: 100%;">
        </a>
    </p>


</div>
</details>
