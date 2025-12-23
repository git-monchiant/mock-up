# Mockup Showcase

รวมรวม mockup screens และ requirement documents สำหรับระบบต่างๆ เพื่อใช้ในการนำเสนอ

## โครงสร้างโปรเจค

```
mockup-screens/
├── index.html                      # หน้าหลัก - เลือกระบบที่ต้องการดู
├── land-tax-system/                # ระบบภาษีที่ดินและสิ่งปลูกสร้าง
│   ├── 01-dashboard.html          # Dashboard ภาพรวม
│   ├── 02-unit-management.html    # จัดการข้อมูล Unit
│   ├── 03-tax-notice-upload.html  # Upload ใบแจ้งภาษี
│   ├── 04-matching-review.html    # ตรวจสอบ Matching
│   ├── 05-reconciliation.html     # เปรียบเทียบภาษี
│   └── REQUIREMENT-land-tax-system.md  # เอกสาร Requirement
├── booking-transfer-tracking/      # ระบบติดตามการจองถึงโอน
│   ├── 01-dashboard.html          # Dashboard และ KPI
│   ├── 02-tracking-list.html      # รายการ Tracking
│   ├── 03-detail-timeline.html    # Timeline รายละเอียด
│   ├── 04-bank-analysis.html      # วิเคราะห์ธนาคาร
│   └── REQUIREMENT-booking-transfer.md  # เอกสาร Requirement
└── README.md                       # ไฟล์นี้
```

## วิธีใช้งาน

### 1. เปิด Local Server

```bash
cd mockup-screens
python3 -m http.server 8080
```

### 2. เข้าชมผ่าน Browser

เปิด browser แล้วไปที่: **http://localhost:8080**

## ระบบที่มีใน Mockup

### 1. ระบบภาษีที่ดินและสิ่งปลูกสร้าง
- **จำนวนหน้าจอ**: 5 หน้า
- **เทคโนโลยี**: HTML + TailwindCSS
- **คุณสมบัติ**:
  - Dashboard ภาพรวมสถานะ
  - จัดการข้อมูล Unit พร้อม Modal
  - Upload ไฟล์ใบแจ้งภาษี + OCR
  - ตรวจสอบ AI Matching
  - Reconciliation เปรียบเทียบภาษี

### 2. ระบบ Booking to Transfer Tracking
- **จำนวนหน้าจอ**: 4 หน้า
- **เทคโนโลยี**: HTML + TailwindCSS + Chart.js
- **คุณสมบัติ**:
  - Dashboard พร้อม KPI Cards และกราฟวิเคราะห์
  - เป้า vs Actual รายเดือน
  - Tracking List พร้อมการกรองและ Timeline
  - รายละเอียดแต่ละ Case พร้อม Timeline ครบ 7 ขั้นตอน
  - วิเคราะห์ธนาคาร (Market Share, Trend, Ranking)

## การเพิ่มระบบใหม่

1. สร้าง folder ใหม่ เช่น `new-system/`
2. ใส่ไฟล์ mockup HTML และ requirement.md
3. แก้ไข `index.html` เพื่อเพิ่มการ์ดระบบใหม่

## เทคโนโลยีที่ใช้

- **HTML5**
- **TailwindCSS** (via CDN)
- **Chart.js** - สำหรับกราฟและ Data Visualization
- **Google Fonts** - Sarabun

## หมายเหตุ

- ทุกหน้า mockup เป็น static HTML ไม่มี backend
- ใช้ TailwindCSS CDN เพื่อความรวดเร็วในการพัฒนา
- รองรับ responsive design
