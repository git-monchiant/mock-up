# IT Asset Management System - Requirement Document

## Executive Summary

ระบบบันทึกและติดตามทรัพย์สิน IT ขององค์กร สำหรับฝ่าย IT ในการจัดการ Inventory, ติดตามสถานะ, และวางแผนซ่อมบำรุง

---

## 1. ประเภท Asset ที่บันทึก

### Hardware
| ประเภท | ตัวอย่าง |
|--------|---------|
| Computer | Desktop, Laptop, Workstation |
| Server | Physical Server, NAS |
| Network | Router, Switch, Access Point, Firewall |
| Peripheral | Monitor, Printer, Scanner, UPS |
| Mobile | Tablet, Smartphone |

### Software
| ประเภท | ตัวอย่าง |
|--------|---------|
| License | Microsoft 365, Adobe CC, Antivirus |
| Subscription | Cloud Services, SaaS |

---

## 2. โครงสร้างข้อมูล Asset

### ข้อมูลหลัก
| Field | Description | Required |
|-------|-------------|----------|
| Asset ID | รหัสทรัพย์สิน (Auto-generate) | Yes |
| Asset Name | ชื่อทรัพย์สิน | Yes |
| Category | หมวดหมู่ (Computer/Server/Network/etc.) | Yes |
| Brand/Model | ยี่ห้อ/รุ่น | Yes |
| Serial Number | หมายเลขเครื่อง | No |
| Purchase Date | วันที่ซื้อ | Yes |
| Purchase Price | ราคาซื้อ (บาท) | Yes |
| Warranty Expiry | วันหมดประกัน | No |
| Status | สถานะ (Active/Maintenance/Retired) | Yes |

### ข้อมูลการใช้งาน
| Field | Description |
|-------|-------------|
| Assigned To | ผู้ใช้งานปัจจุบัน |
| Department | แผนก/ฝ่าย |
| Location | สถานที่ตั้ง (อาคาร/ชั้น/ห้อง) |
| IP Address | (สำหรับ Network Device) |
| MAC Address | (สำหรับ Network Device) |

### ข้อมูลค่าเสื่อมราคา
| Field | Description |
|-------|-------------|
| Useful Life | อายุการใช้งาน (ปี) |
| Salvage Value | มูลค่าซาก |
| Depreciation Method | วิธีคิดค่าเสื่อม (Straight-line) |
| Current Book Value | มูลค่าตามบัญชีปัจจุบัน |

---

## 3. Screen Specifications

### Screen 1: Dashboard
**File:** `01-asset-dashboard.html`

แสดง:
- สรุปจำนวน Asset ทั้งหมด (แยกตามประเภท)
- มูลค่า Asset รวม vs ค่าเสื่อมราคาสะสม
- Asset ใกล้หมดประกัน (30/60/90 วัน)
- Asset ที่ต้องซ่อมบำรุง
- Asset แยกตามสถานะ (Active/Maintenance/Retired)
- Quick Actions (เพิ่ม Asset, รายงาน)

**ตอบคำถาม:** "Asset รวมมีกี่ชิ้น มูลค่าเท่าไหร่ ต้องทำอะไรบ้าง"

---

### Screen 2: Asset List
**File:** `02-asset-list.html`

แสดง:
- ตาราง Asset ทั้งหมด
- Filter: ประเภท, สถานะ, แผนก, สถานที่
- Search: Asset ID, ชื่อ, Serial Number
- Sort: วันที่ซื้อ, มูลค่า, สถานะ
- Actions: View, Edit, Delete

**ตอบคำถาม:** "หา Asset ที่ต้องการ และดูรายละเอียด"

---

### Screen 3: Asset Detail
**File:** `03-asset-detail.html`

แสดง:
- ข้อมูลครบทุก Field
- ประวัติการเปลี่ยนผู้ใช้งาน
- ประวัติการซ่อมบำรุง
- เอกสารแนบ (ใบเสร็จ, ใบรับประกัน)
- Timeline การเปลี่ยนแปลง

**ตอบคำถาม:** "Asset ชิ้นนี้มีประวัติอะไรบ้าง ใครใช้อยู่"

---

### Screen 4: Add/Edit Asset
**File:** `04-asset-form.html`

แสดง:
- Form บันทึกข้อมูล Asset
- Validation ตาม Required fields
- Upload เอกสาร
- Auto-generate Asset ID

**ตอบคำถาม:** "บันทึก Asset ใหม่ หรือแก้ไขข้อมูลเดิม"

---

## 4. Status Definitions

| Status | Description | Color |
|--------|-------------|-------|
| Active | ใช้งานปกติ | Green |
| Maintenance | กำลังซ่อมบำรุง | Yellow |
| Retired | ปลดระวาง/จำหน่าย | Gray |
| Lost | สูญหาย | Red |

---

## 5. Key Metrics (Dashboard)

| Metric | Formula |
|--------|---------|
| Total Assets | นับจำนวน Asset ทั้งหมด |
| Total Value | รวมราคาซื้อทั้งหมด |
| Net Book Value | Total Value - Accumulated Depreciation |
| Utilization Rate | Active Assets / Total Assets × 100 |
| Warranty Alert | Assets หมดประกันใน 30 วัน |

---

## 6. Technical Stack

- **Framework:** Static HTML with Tailwind CSS (CDN)
- **Font:** Sarabun (Thai) via Google Fonts
- **Icons:** Heroicons (inline SVG)
- **Layout:** Sidebar navigation with main content area
- **Responsive:** Desktop-first design

---

## 7. Navigation Flow

```
Dashboard (Overview)
├── Asset List (Table)
│   ├── [Click Row] → Asset Detail
│   └── [+ Add] → Asset Form (New)
├── Asset Detail
│   └── [Edit] → Asset Form (Edit)
└── Reports (Future)
```

---

## 8. User Permissions (Future)

| Role | View | Add | Edit | Delete |
|------|------|-----|------|--------|
| IT Admin | ✓ | ✓ | ✓ | ✓ |
| IT Staff | ✓ | ✓ | ✓ | - |
| User | Own Only | - | - | - |
