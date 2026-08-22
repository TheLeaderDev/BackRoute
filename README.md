<p align="center">
  <a href="#persian-language">ترجمه فارسی</a>
</p>

# BackRoute

Welcome to the `BackRoute` project!

BackRoute is a lightweight and reliable solution for creating a `Tunnel` between two servers using `IPv4` or `IPv6`, supporting `GRE`, `IPIP`, and `SIT`.

The project is designed to provide a simple, stable, and flexible connection between different networks.

## Features

- **Multiple Tunnel Modes** <br>
  Supports `GRE`, `IPIP`, and `SIT`.

- **IPv4 & IPv6 Support** <br>
  `GRE` and `IPIP` use IPv4, while `SIT` uses IPv6.

- **Automatic Configuration** <br>
  The installer automatically configures Netplan, required kernel modules, systemd, firewall rules, and other required settings.

- **Smart Watchdog** <br>
  Automatically monitors the tunnel and attempts to reconnect it if the connection goes down.

- **Management Panel** <br>
  Configure, edit, monitor, restart, or completely remove BackRoute from an interactive panel.

- **MTU Configuration** <br>
  MTU can be configured during setup and changed later from the panel.

## Before You Install

> BackRoute is designed to make the entire installation and configuration process automatic.
>
> You only need to run the installer on both servers and follow the instructions shown in the panel.
>
> You will need two servers:
> - `CLIENT` → Your local server
> - `SERVER` → Your remote server
>
> ⚠️ BackRoute works best on `Ubuntu 22`. Other versions are not recommended.
>
> ⚠️ Tunnel performance depends on your ISP, datacenter, routing, routers, and filtering conditions. Make sure the required tunnel traffic is not blocked.

## Installation

Run the following command on both servers:

```bash
curl -Ls https://raw.githubusercontent.com/TheLeaderDev/BackRoute/main/install.sh | sed 's/\r$//' | bash
```

After installation, the BackRoute panel will open automatically.

From the panel you can configure your tunnel, edit its settings, check its status, or remove BackRoute completely.

To open the panel again, simply run:

```bash
BackRoute
```

## Management Panel

The BackRoute panel provides the following options:

```text
[1] Configure BackRoute
[2] Edit Tunnel Config
[3] Status & Monitor
[4] Remove BackRoute
[0] Exit
```

### Configure BackRoute

Choose the server role, tunnel method, IP addresses, tunnel address, and MTU.

BackRoute will automatically create the required configuration and start the tunnel.

### Edit Tunnel Config

Modify your existing tunnel configuration without configuring everything again.

### Status & Monitor

Check the BackRoute service and tunnel status.

### Remove BackRoute

Completely remove BackRoute, including its configuration, service, watchdog, and related files.

## Give a Star

If you liked it, supporting me is completely free — just give this project a Star ⭐ <br>
And if you support me, I’ll add even more methods! ❤️

<div class="markdown-heading" dir="auto">
        <h2 class="heading-element" dir="auto">
            <a href="https://github.com/TheLeaderDev">
                <img target="_blank" src="https://amir8218.ir/GitHub/SVG/Follow-Me.svg" alt="Follow Me :">
            </a>
        </h2>
        <a id="user-content--socials" class="anchor" aria-label="Permalink: 🌐 Socials:" href="https://github.com/TheLeaderDev">
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
    <a target="_blank" href="https://www.instagram.com/TheLeaderDev" rel="nofollow">
        <img src="https://img.shields.io/badge/instagram-%23082032?style=for-the-badge&logo=instagram&logoColor=%23FD0AB6&color=%23082032" alt="Instagram" style="max-width: 100%;">
    </a>
    <a target="_blank" href="https://t.me//LeaderDevOfficial" rel="nofollow">
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
سلام! به پروژه <code>BackRoute</code> خوش اومدید<br>
BackRoute یه راهکار سبک و راحت برای ساختن یه <code>تونل</code> بین دو سروره که از <code>IPv4</code> و <code>IPv6</code> پشتیبانی می‌کنه و می‌تونه روش‌های <code>GRE</code>، <code>IPIP</code> و <code>SIT</code> رو راه‌اندازی کنه.<br>

</p>

<p dir="rtl">
BackRoute یه تونل لایه ۳ بین سرور <code>SERVER</code> و <code>CLIENT</code> ایجاد می‌کنه و برای ایجاد یه اتصال ساده، پایدار و انعطاف‌پذیر بین دو شبکه طراحی شده.
</p>

<h2 dir="rtl">ویژگی‌ها</h2>

<ul dir="rtl">
<li><strong>چند حالت تونل</strong><br>
از <code>GRE</code>، <code>IPIP</code> و <code>SIT</code> پشتیبانی می‌کنه.
</li>

<li><strong>پشتیبانی IPv4 و IPv6</strong><br>
روش‌های <code>GRE</code> و <code>IPIP</code> از IPv4 و روش <code>SIT</code> از IPv6 استفاده می‌کنه.
</li>

<li><strong>پیکربندی خودکار</strong><br>
Netplan، ماژول‌های موردنیاز، systemd، قوانین Firewall و تنظیمات لازم به‌صورت خودکار انجام می‌شن.
</li>

<li><strong>Watchdog هوشمند</strong><br>
وضعیت تونل رو بررسی می‌کنه و اگه ارتباط قطع بشه، برای اتصال مجدد تلاش می‌کنه.
</li>

<li><strong>پنل مدیریت</strong><br>
می‌تونید تونل رو بسازید، تنظیماتش رو تغییر بدید، وضعیتش رو بررسی کنید یا به‌صورت کامل حذفش کنید.
</li>

<li><strong>تنظیم MTU</strong><br>
MTU هنگام ساخت تونل قابل تنظیمه و بعداً هم می‌تونید از داخل پنل تغییرش بدید.
</li>
</ul>

<h2 dir="rtl">قبل از نصب</h2>

<blockquote>

<p dir="rtl">
BackRoute طوری طراحی شده که کل مراحل نصب و پیکربندی رو به‌صورت خودکار انجام بده.<br>
فقط کافیه اسکریپت رو روی هر دو سرور اجرا کنید و مراحل داخل پنل رو دنبال کنید.
</p>

<p dir="rtl">
شما به دو سرور نیاز دارید:
</p>

<ul dir="rtl">
<li><code>CLIENT</code> ← سرور محلی</li>
<li><code>SERVER</code> ← سرور ریموت</li>
</ul>

<p dir="rtl">
⚠️ BackRoute بهترین عملکرد رو روی <code>Ubuntu 22</code> داره. نسخه‌های دیگه توصیه نمی‌شن.
</p>

<p dir="rtl">
⚠️ عملکرد تونل به ISP، دیتاسنتر، مسیر شبکه، روترها و شرایط فیلترینگ بستگی داره. مطمئن بشید ترافیک موردنیاز تونل مسدود نشده باشه.
</p>

</blockquote>

<h2 dir="rtl">نصب</h2>

<p dir="rtl">
این دستور رو روی هر دو سرور اجرا کنید:
</p>

<pre><code>curl -Ls https://raw.githubusercontent.com/TheLeaderDev/BackRoute/main/install.sh | sed 's/\r$//' | bash</code></pre>

<p dir="rtl">
بعد از نصب برای باز کردن پنل BackRoute کافیه دستور زیر رو اجرا کنید:
</p>

<pre><code>BackRoute</code></pre>

<h2 dir="rtl">پنل مدیریت</h2>

<p dir="rtl">
پنل BackRoute این گزینه‌ها رو در اختیار شما قرار می‌ده:
</p>

<pre><code>[1] Configure BackRoute
[2] Edit Tunnel Config
[3] Status & Monitor
[4] Remove BackRoute
[0] Exit</code></pre>

<h3 dir="rtl">Configure BackRoute</h3>

<p dir="rtl">
نقش سرور، روش تونل، IPها، آدرس تونل و MTU رو انتخاب می‌کنید و BackRoute بقیه تنظیمات رو به‌صورت خودکار انجام می‌ده.
</p>

<h3 dir="rtl">Edit Tunnel Config</h3>

<p dir="rtl">
تنظیمات تونل موجود رو بدون نیاز به نصب مجدد تغییر بدید.
</p>

<h3 dir="rtl">Status & Monitor</h3>

<p dir="rtl">
وضعیت سرویس و تونل BackRoute رو بررسی کنید.
</p>

<h3 dir="rtl">Remove BackRoute</h3>

<p dir="rtl">
BackRoute به‌همراه تنظیمات، سرویس، Watchdog و فایل‌های مربوطه به‌صورت کامل حذف می‌شه.
</p>

<h2 dir="rtl">حمایت از پروژه</h2>

<p dir="rtl">
اگه این پروژه رو دوست داشتید، حمایت‌تون کاملاً رایگانه — فقط به این پروژه یه ستاره ⭐ بدید<br>
درصورتی که از این پروژه خوشتون اومد و حمایت کردید، روش‌های بیشتر و آپدیت‌های بیشتری هم اضافه می‌کنم بهش! ❤️
</p>

<div class="markdown-heading" dir="auto">
    <h2 class="heading-element" dir="auto">
        <a href="https://github.com/TheLeaderDev">
            <img target="_blank" src="https://amir8218.ir/GitHub/SVG/Follow-Me.svg" alt="Follow Me :">
        </a>
    </h2>
    <a id="user-content--socials" class="anchor" aria-label="Permalink: 🌐 Socials:" href="https://github.com/TheLeaderDev">
        <svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true">
            <path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0
                     .751.751 0 0 1 .018-1.042.751.751 0 0 1-1.042-.018
                     1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83
                     l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042
                     Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 0 .018 1.042
                     .751.751 0 0 0 .018-1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95
                     l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042
                     .751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0
                     l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z">
            </path>
        </svg>
    </a>
</div>

<p dir="auto">
    <a target="_blank" href="https://www.instagram.com/TheLeaderDev" rel="nofollow">
        <img src="https://img.shields.io/badge/instagram-%23082032?style=for-the-badge&logo=instagram&logoColor=%23FD0AB6&color=%23082032" alt="Instagram" style="max-width: 100%;">
    </a>
    <a target="_blank" href="https://t.me//LeaderDevOfficial" rel="nofollow">
        <img src="https://img.shields.io/badge/telegram-url?style=for-the-badge&logo=telegram&logoColor=%232CA5E0&color=%23082032" alt="telegram" style="max-width: 100%;">
    </a>
    <a target="_blank" href="https://www.linkedin.com/in/TheLeaderDev" rel="nofollow">
        <img src="https://amir8218.ir/GitHub/Logo/Profiles/LINKEDIN%20.svg" alt="LinkedIn" style="max-width: 100%;">
    </a>
</p>

</div>

</details>
