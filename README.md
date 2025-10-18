# مجموعه صفحات پیش‌فرض وب‌سرور

![GitHub stars](https://img.shields.io/github/stars/javadalmasi/web-server-defaults?style=social)
![GitHub forks](https://img.shields.io/github/forks/javadalmasi/web-server-defaults?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/javadalmasi/web-server-defaults?style=social)

مجموعه کاملی از صفحات خطا و پیش‌فرض برای وب‌سرورها با پشتیبانی از زبان فارسی و چیدمان راست‌چین.

## ویژگی‌ها

- کاملاً به زبان فارسی
- پشتیبانی از چیدمان راست‌چین (RTL)
- طراحی واکنش‌گرا برای تمام دستگاه‌ها
- انیمیشن‌های جذاب با GSAP
- رنگ‌های متفاوت برای هر نوع خطا
- آیکون‌های مناسب برای هر نوع وضعیت
- بدون نیاز به اینترنت (کلیه کتابخانه‌ها به صورت محلی)

## صفحات موجود

- 404.html - صفحه یافت نشد
- 403.html - دسترسی غیرمجاز
- 500.html - خطای سرور داخلی
- 502.html - دروازه نامعتبر
- 503.html - سرویس در دسترس نیست
- 410.html - منسوخ شده
- 429.html - تعداد درخواست‌های زیاد
- default.html - صفحه پیش‌فرض
- stop.html - سایت متوقف شده
- unbound-domain.html - دامنه متصل نیست
- index.html - صفحه اصلی معرفی

## استفاده

برای استفاده از این صفحات در وب‌سرور خود:

1. تمام فایل‌ها را در شاخه مربوط به صفحات خطا در وب‌سرور خود قرار دهید
2. تنظیمات وب‌سرور را مطابق با نوع سرور (Apache، Nginx و غیره) برای نمایش این صفحات در مواقع خطا انجام دهید

## ساختار فایل‌ها

```
.
├── index.html              # صفحه اصلی معرفی
├── 404.html                # صفحه خطای 404
├── 403.html                # صفحه خطای 403
├── 500.html                # صفحه خطای 500
├── 502.html                # صفحه خطای 502
├── 503.html                # صفحه خطای 503
├── 410.html                # صفحه خطای 410
├── 429.html                # صفحه خطای 429
├── default.html            # صفحه پیش‌فرض
├── stop.html               # صفحه توقف سایت
├── unbound-domain.html     # صفحه دامنه متصل نشده
├── https://cdn.jsdelivr.net/gh/javadalmasi/web-server-defaults@master/assets/
│   ├── css/
│   │   ├── fonts.css       # تعریف فونت‌ها
│   │   └── local-fonts.css # استایل فونت‌های محلی
│   └── js/
│       └── gsap.min.js     # کتابخانه GSAP
├── LICENSE
└── README.md
```

## نصب خودکار

برای نصب خودکار این صفحات خطا روی سرورهای مختلف، یک اسکریپت نصب ارائه شده است که از سیستم‌های زیر پشتیبانی می‌کند:
- cPanel
- DirectAdmin
- Nginx
- Apache
- aaPanel

برای استفاده از اسکریپت نصب:

```bash
# دانلود اسکریپت
wget https://github.com/javadalmasi/web-server-defaults/archive/main.zip
unzip main.zip
cd web-server-defaults-main

# اعطای مجوز اجرا
chmod +x install.sh

# نصب صفحات خطا
sudo ./install.sh install
```

برای جزئیات بیشتر در مورد نحوه استفاده از اسکریپت نصب، فایل [INSTALLATION.md](INSTALLATION.md) را مشاهده کنید.

## مجوز

این پروژه تحت مجوز Creative Commons Attribution 4.0 International قرار دارد. برای جزئیات بیشتر، فایل [LICENSE](LICENSE) را ببینید.

## مشارکت

مشارکت‌های شما در بهبود این مجموعه صفحات استقبال می‌شود. لطفاً از طریق ایجاد یک Issue یا Pull Request مشارکت کنید.