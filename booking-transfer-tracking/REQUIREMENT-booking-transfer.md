# ระบบ Tracking Booking to Transfer

> **เอกสารนี้**: Requirement คร่าวๆ สำหรับระบบติดตามสถานะจากจองจนถึงโอน
> **Version**: 1.0 Draft
> **วันที่**: ธันวาคม 2567

---

## 1. เป้าหมายของระบบ

| # | เป้าหมาย | รายละเอียด |
|---|----------|------------|
| 1 | ติดตามกระบวนการ | ติดตามสถานะตั้งแต่จอง → สินเชื่อ → ตรวจห้อง → โอน |
| 2 | รวมข้อมูลทุกฝ่าย | Sale, CO (Credit Officer), CS (Customer Service), Finance |
| 3 | แจ้งเตือนอัตโนมัติ | Alert งานที่ล่าช้า, ครบกำหนด |
| 4 | วิเคราะห์ KPI | Aging, Conversion Rate, Bottleneck |
| 5 | รองรับ Livnex | ติดตาม case ที่ผ่าน Livnex Able |

---

## 2. ขอบเขตข้อมูลหลัก

### 2.1 ข้อมูลการจอง (Booking)

| Field | Description |
|-------|-------------|
| รหัสโครงการ | Project Code |
| โครงการ | Project Name |
| No. | เลขที่บ้าน/ห้อง |
| เลขที่ห้อง | Room/Unit Number |
| ทะเบียนบ้าน | House Registration |
| วันที่จอง | Booking Date |
| วันที่ทำสัญญา | Contract Date |
| ชื่อลูกค้า | Customer Name |
| TEL | Phone Number |
| ราคาขายสุทธิ | Net Selling Price |
| สถานะสินค้า | Product Status (ขายใหม่, Stock, etc.) |
| ประเภทการขาย | Sales Type |

### 2.2 ข้อมูลสินเชื่อ (Credit)

| Field | Description |
|-------|-------------|
| สถานะสินเชื่อ | Credit Status |
| ประเภทขอสินเชื่อ | Loan Type |
| ธนาคารที่ยื่นเอกสาร | Applied Bank |
| วันที่ยื่นเอกสาร | Document Submit Date |
| เอกสารครบ Bank | Bank Doc Complete |
| เอกสารครบ JD | JD Complete |
| วันที่ได้ผลบูโร | Bureau Result Date |
| ผลบูโร | Bureau Result |
| วันที่ได้ผลอนุมัติ | Approval Date |
| ผลการอนุมัติ | Approval Result |
| LTV | Loan to Value |
| CO. | Credit Officer |

### 2.3 ข้อมูลการตรวจห้อง (Inspection)

| Field | Description |
|-------|-------------|
| สถานะนัดตรวจ | Inspection Appointment Status |
| วิธีการตรวจห้อง | Inspection Method |
| วันที่ห้องพร้อมตรวจ | Unit Ready Date |
| วันที่นัดลูกค้าเข้าตรวจ | Customer Appointment Date |
| วันที่ลูกค้าเข้าตรวจจริง | Actual Inspection Date |
| วันที่รับห้อง | Unit Handover Date |
| ผลการตรวจ | Inspection Result |
| CS | Customer Service Officer |

### 2.4 ข้อมูลการโอน (Transfer)

| Field | Description |
|-------|-------------|
| วันที่ทำสัญญาธนาคาร | Bank Contract Date |
| วันที่ส่งชุดโอน | Transfer Document Submit Date |
| วันที่ปลอดโฉนด | Title Deed Clear Date |
| เป้าโอน | Target Transfer Date |
| นัดโอนจริง | Actual Transfer Appointment |
| วันที่เป้าโอน (CO.กำหนด) | CO Target Transfer Date |

### 2.5 ข้อมูล Livnex

| Field | Description |
|-------|-------------|
| Livnex Able | Livnex Eligible Status |
| วันที่จอง ถึง จบ Livnex Able | Booking to Livnex Duration |
| วันที่นัดทำสัญญา Livnex | Livnex Contract Appointment |
| วันที่ทำสัญญาจริง | Actual Livnex Contract Date |
| เหตุผล Livnex Able | Livnex Reason |

---

## 3. สถานะหลักในระบบ

### 3.1 สถานะสินค้า
- **ขายใหม่** - จองใหม่
- **รอสินเชื่อ** - รอผลอนุมัติ
- **รอตรวจห้อง** - อนุมัติแล้ว รอนัดตรวจ
- **รอโอน** - ตรวจห้องแล้ว รอโอน
- **โอนแล้ว** - Transferred
- **ยกเลิก** - Cancelled

### 3.2 สถานะสินเชื่อ
- **ยื่นเอกสาร** - เอกสารถูกยื่นแล้ว
- **เอกสารครบ** - เอกสารครบถ้วน
- **ผ่านบูโร** - ผลบูโรปกติ
- **อนุมัติเบื้องต้น** - Pre-Approved
- **อนุมัติจริง** - Fully Approved
- **ไม่อนุมัติ** - Rejected

### 3.3 สถานะการตรวจห้อง
- **รอนัด** - Waiting for Appointment
- **นัดแล้ว** - Appointed
- **เข้าตรวจแล้ว** - Inspected
- **ผ่าน** - Pass
- **ไม่ผ่าน** - Fail (ต้องแก้ไข)
- **รับห้องแล้ว** - Handed Over

---

## 4. KPI & Metrics

### 4.1 Aging
- **จอง → อนุมัติเบื้องต้น**: Target ไม่เกิน 30 วัน
- **จอง → Bank อนุมัติจริง**: Target ไม่เกิน 45 วัน
- **Livnex Able → โอน**: Target ไม่เกิน XX วัน
- **โทรแจ้งลูกค้า**: ภายใน 2 วัน หลังได้ผลบูโรปกติ
- **ลูกค้าเข้าตรวจ**: ภายใน 15 วัน หลังได้ผลบูโรปกติ

### 4.2 Conversion Rate
- % การอนุมัติสินเชื่อ
- % การยกเลิก
- % การโอนสำเร็จ

### 4.3 Backlog
- จำนวน case ที่ค้างในแต่ละสถานะ
- Grade Backlog (A/B/C/D)

---

## 5. ผู้ใช้งานหลัก

| Role | หน้าที่ | สิทธิ์ |
|------|---------|--------|
| **Sale** | ติดตามสถานะลูกค้า, อัปเดตข้อมูล | View, Edit (เฉพาะ case ของตัวเอง) |
| **CO (Credit Officer)** | ติดตามสินเชื่อ, อนุมัติ | View All, Edit Credit Status |
| **CS (Customer Service)** | นัดตรวจห้อง, ติดตามลูกค้า | View All, Edit Inspection |
| **Finance** | ติดตามการโอน | View All, Edit Transfer |
| **Manager** | ดู Dashboard, รายงาน | View All, Export |

---

## 6. ฟังก์ชันหลัก

### 6.1 Dashboard
- สรุป KPI แยกตามสถานะ
- Aging Chart
- Backlog by Grade
- ห้อง/บ้านที่เป็นเป้าโอนเดือนนี้

### 6.2 Tracking List
- แสดงรายการทั้งหมด พร้อม Filter
- Export Excel
- Bulk Update
- Color Coding ตาม Aging

### 6.3 Detail View
- Timeline ตั้งแต่จอง → โอน
- ประวัติการติดตาม
- แนบเอกสาร
- บันทึกหมายเหตุ

### 6.4 Alert & Notification
- แจ้งเตือนงานที่ล่าช้า
- แจ้งเตือนงานที่ใกล้ครบกำหนด
- แจ้งเตือน Case ที่ต้องติดตาม

### 6.5 Reports
- รายงาน Aging
- รายงาน Conversion Rate
- รายงานเป้าโอนรายเดือน
- รายงาน Backlog

---

## 7. Integration Points

### 7.1 ระบบ REM
- ดึงข้อมูลโครงการ, ห้อง/บ้าน
- ดึงข้อมูลการจอง
- อัปเดตสถานะสินค้า

### 7.2 Line Notify / Email
- ส่งการแจ้งเตือน
- รายงานประจำวัน/สัปดาห์

---

## 8. หน้าจอหลัก

| # | Screen | Description |
|---|--------|-------------|
| 1 | Dashboard | ภาพรวม KPI, Aging, Backlog |
| 2 | Tracking List | รายการทั้งหมด + Filter |
| 3 | Detail + Timeline | รายละเอียด case + timeline |
| 4 | Credit Management | จัดการข้อมูลสินเชื่อ |
| 5 | Inspection Management | จัดการการนัดตรวจห้อง |
| 6 | Reports | รายงานต่างๆ |

---

## 9. คำถามที่ต้องตกลงกับทีม

1. **Aging Calculation**: นับตาม working days หรือ calendar days?
2. **Alert Rules**: กำหนดเงื่อนไขการแจ้งเตือนอย่างไร?
3. **สิทธิ์การแก้ไข**: ใครบ้างที่แก้ไขข้อมูลข้ามฝ่ายได้?
4. **Integration**: มี API จาก REM พร้อมหรือยัง?
5. **Livnex**: ระบบ Livnex มี API ให้เชื่อมต่อหรือไม่?

---

*เอกสารนี้เป็น Draft สำหรับคุยกับทีม*
