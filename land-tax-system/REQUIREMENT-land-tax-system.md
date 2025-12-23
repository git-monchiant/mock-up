# ระบบภาษีที่ดินและสิ่งปลูกสร้าง (Land & Building Tax System)

> **เอกสารนี้**: Requirement คร่าวๆ สำหรับใช้คุยกับทีม IT + Vendor
> **Version**: 1.0 Draft
> **วันที่**: ธันวาคม 2567

---

## 1. เป้าหมายของระบบ

| # | เป้าหมาย | รายละเอียด |
|---|----------|------------|
| 1 | รวมข้อมูลแปลงที่ดิน/ยูนิต | ดึงข้อมูลจาก REM มาเป็นฐานสำหรับคำนวณภาษี |
| 2 | ดึงราคาประเมินอัตโนมัติ | ใช้ AI + API กรมธนารักษ์ ดึง "ราคาประเมินทุนทรัพย์" |
| 3 | รองรับประเภทที่ดินหลากหลาย | อยู่อาศัย / เชิงพาณิชย์ / ว่างเปล่า / เกษตร (อัตราภาษีต่างกัน) |
| 4 | OCR ใบแจ้งภาษี | อัปโหลดหนังสือแจ้งประเมินจากเขต → AI ทำ OCR + Matching |
| 5 | ตรวจสอบความแตกต่าง | เปรียบเทียบ "ภาษีที่ควรจะเป็น" vs "ภาษีที่เขตเรียกเก็บจริง" |

---

## 2. ขอบเขตข้อมูลหลัก (Data Model)

### 2.1 ข้อมูล Unit / แปลงที่ดิน (ดึงจาก REM)

**ตาราง: `LandUnit`**

| Field | Type | Description |
|-------|------|-------------|
| `UnitId` | PK | รหัสภายใน |
| `ProjectCode` | String | รหัสโครงการ |
| `UnitCode` | String | เลขยูนิต/เลขที่บ้าน |
| `HouseNo` | String | เลขที่บ้าน (ถ้ามี) |
| `DeedNo` | String | เลขโฉนด |
| `ParcelNo` | String | เลขที่ดิน (ถ้ามี) |
| `Subdistrict` | String | แขวง/ตำบล |
| `District` | String | เขต/อำเภอ |
| `Province` | String | จังหวัด |
| `ZipCode` | String | รหัสไปรษณีย์ |
| `SellStatus` | Enum | สถานะขาย: `STOCK`, `BOOKED`, `TRANSFERRED` |
| `OwnerType` | Enum | เจ้าของ: `COMPANY`, `CUSTOMER`, `JOINT` |
| `AreaSqm` | Decimal | เนื้อที่ (ตร.ม.) |
| `AreaSqWa` | Decimal | เนื้อที่ (ตร.วา) |

---

### 2.2 ข้อมูลประเภทที่ดิน + อัตราภาษี

**ตาราง: `LandType`**

| Field | Type | Description |
|-------|------|-------------|
| `LandTypeId` | PK | รหัส |
| `Code` | String | `RES`, `COM`, `VACANT`, `AGRI` |
| `NameTh` | String | อยู่อาศัย, เชิงพาณิชย์, ว่างเปล่า, เกษตร |
| `Description` | String | คำอธิบาย |

**ตาราง: `TaxRateRule`**

| Field | Type | Description |
|-------|------|-------------|
| `RuleId` | PK | รหัส |
| `LandTypeId` | FK | ประเภทที่ดิน |
| `MinValue` | Decimal | ราคาประเมินขั้นต่ำ |
| `MaxValue` | Decimal | ราคาประเมินขั้นสูง |
| `TaxRate` | Decimal | อัตราภาษี (% ต่อปี) |
| `EffectiveDateFrom` | Date | วันที่เริ่มใช้ |
| `EffectiveDateTo` | Date | วันที่สิ้นสุด |
| `LawReference` | String | อ้างอิงมาตรา/ประกาศ |

---

### 2.3 ข้อมูลราคาประเมินจากกรมธนารักษ์

**ตาราง: `LandValuation`**

| Field | Type | Description |
|-------|------|-------------|
| `ValuationId` | PK | รหัส |
| `UnitId` | FK | รหัส Unit |
| `ValuationSource` | Enum | `TREASURY_API`, `MANUAL` |
| `LandValuePerSqm` | Decimal | ราคาประเมินต่อ ตร.ม. |
| `LandValuePerSqWa` | Decimal | ราคาประเมินต่อ ตร.วา |
| `TotalLandValue` | Decimal | ราคาประเมินรวม |
| `ValuationYear` | Integer | ปีราคาประเมิน |
| `LastUpdateFromAPI` | DateTime | วันที่ดึงล่าสุด |
| `ValuationStatus` | Enum | สถานะ (ดูด้านล่าง) |

**ValuationStatus:**
- `SUCCESS` - ดึงสำเร็จ
- `NOT_FOUND` - หาข้อมูลไม่เจอ
- `ERROR` - API error
- `NEED_MANUAL` - ให้พนักงานเติมเอง

---

### 2.4 ข้อมูลคำนวณภาษี

**ตาราง: `TaxCalculation`**

| Field | Type | Description |
|-------|------|-------------|
| `TaxCalcId` | PK | รหัส |
| `UnitId` | FK | รหัส Unit |
| `TaxYear` | Integer | ปีภาษี |
| `LandTypeId` | FK | ประเภทที่ดิน |
| `TotalLandValue` | Decimal | ราคาประเมินรวม |
| `AppliedTaxRate` | Decimal | อัตราภาษีที่ใช้ |
| `TaxAmountCalculated` | Decimal | ภาษีที่ระบบคำนวณ |
| `CalcStatus` | Enum | `NORMAL`, `ESTIMATED`, `INCOMPLETE` |
| `Remark` | String | หมายเหตุ |

---

### 2.5 ข้อมูลใบแจ้งภาษีจากสำนักงานเขต

**ตาราง: `TaxNoticeFile`** (ระดับไฟล์)

| Field | Type | Description |
|-------|------|-------------|
| `FileId` | PK | รหัส |
| `FileName` | String | ชื่อไฟล์ |
| `TaxYear` | Integer | ปีภาษี |
| `OfficeName` | String | ชื่อสำนักงานเขต |
| `UploadBy` | String | ผู้อัปโหลด |
| `UploadDate` | DateTime | วันที่อัปโหลด |
| `OCRStatus` | Enum | `PENDING`, `SUCCESS`, `FAILED` |

**ตาราง: `TaxNoticeItem`** (ระดับรายการแปลง หลัง OCR)

| Field | Type | Description |
|-------|------|-------------|
| `ItemId` | PK | รหัส |
| `FileId` | FK | รหัสไฟล์ |
| `RawParcelText` | String | ข้อความดิบจากเอกสาร |
| `ParcelNoFromNotice` | String | เลขที่ดินจากเอกสาร |
| `DeedNoFromNotice` | String | เลขโฉนดจากเอกสาร |
| `AddressFromNotice` | String | ที่อยู่จากเอกสาร |
| `LandTypeFromNotice` | String | ประเภทที่ดิน (ถ้ามี) |
| `TaxYear` | Integer | ปีภาษี |
| `TaxAmountNotice` | Decimal | จำนวนเงินที่เรียกเก็บ |
| `MatchStatus` | Enum | สถานะ Match (ดูด้านล่าง) |
| `MatchedUnitId` | FK (nullable) | Unit ที่จับคู่ได้ |
| `MatchScore` | Decimal | ค่าความมั่นใจ (0-1) |

**MatchStatus:**
- `AUTO_MATCHED` - AI จับคู่เรียบร้อย (confidence >= 90%)
- `MULTIPLE_CANDIDATES` - พบหลายตัวเลือก ต้องให้คนเลือก
- `NO_MATCH` - ไม่พบในระบบ

---

## 3. Integration & AI Component

### 3.1 Integration กับระบบ REM

```
┌─────────────┐         ┌──────────────────────┐
│    REM      │ ──────► │  Land Tax System     │
│   System    │  Sync   │                      │
└─────────────┘         └──────────────────────┘
```

**Requirements:**

| # | รายการ | รายละเอียด |
|---|--------|------------|
| 1 | วิธีการดึงข้อมูล | Database View/Replication หรือ REST API |
| 2 | Initial Sync | ดึงข้อมูลทุก Unit ที่เกี่ยวข้องกับภาษี |
| 3 | Incremental Sync | ดึงเฉพาะ Unit ที่มีการเปลี่ยนแปลง |
| 4 | Sync Log | บันทึกเวลาและจำนวนรายการที่ดึง |

---

### 3.2 Integration กับ API กรมธนารักษ์

```
┌──────────────────────┐         ┌─────────────────────┐
│  Land Tax System     │ ──────► │  กรมธนารักษ์ API     │
│                      │   API   │  (ราคาประเมิน)       │
└──────────────────────┘         └─────────────────────┘
```

**Requirements:**

| # | รายการ | รายละเอียด |
|---|--------|------------|
| 1 | Authentication | ใช้ key/credential ที่กรมกำหนด |
| 2 | Parameters | เขต/แขวง/จังหวัด, เลขที่ดิน/โฉนด, พิกัด (ถ้ามี) |
| 3 | Job | `SyncLandValuationJob(TaxYear)` วนเรียกทีละ Unit |
| 4 | Success Handling | บันทึกลง `LandValuation` + Status = `SUCCESS` |
| 5 | Error Handling | บันทึก error + Status = `NEED_MANUAL`/`ERROR` |
| 6 | Rate Limit | มี Retry Mechanism กันโดน block |
| 7 | Logging | Log Request/Response (summary + error code) |

---

### 3.3 AI สำหรับ OCR + Matching

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│ Upload PDF  │ ──► │  OCR Engine │ ──► │  AI Matching    │
│ /ภาพสแกน    │     │             │     │  กับ LandUnit   │
└─────────────┘     └─────────────┘     └─────────────────┘
```

**OCR Requirements:**
- รองรับ PDF และภาพสแกน
- ดึงข้อความ + Mapping เป็น `TaxNoticeItem`

**Matching Logic:**

| เกณฑ์ | พิจารณา |
|-------|---------|
| Primary | เลขโฉนด |
| Secondary | เลขที่ดิน / หน่วยที่ |
| Tertiary | ที่อยู่ (แขวง/เขต/จังหวัด) |
| Optional | ชื่อโครงการ |

**ผลลัพธ์:**

| MatchScore | Status | Action |
|------------|--------|--------|
| >= 0.9 | `AUTO_MATCHED` | ระบบจับคู่อัตโนมัติ |
| 0.6 - 0.89 | `MULTIPLE_CANDIDATES` | ให้พนักงานเลือก |
| < 0.6 | `NO_MATCH` | ให้พนักงาน Manual Match |

---

## 4. ฟังก์ชันหลักของระบบ

### 4.1 Dashboard ภาพรวม

**แสดงข้อมูล:**
- จำนวน Unit ทั้งหมดที่ต้องคำนวณภาษี (ตามปีภาษี)
- สถานะราคาประเมิน: สำเร็จ / ยังไม่ได้ / error
- สถานะคำนวณภาษี: เรียบร้อย / ยังไม่คำนวณ
- สถานะ Matching: Match แล้ว / ยังไม่ Match / ไม่ชัดเจน

**Filter:**
- ปีภาษี
- โครงการ
- ประเภทที่ดิน
- เขต/สำนักงานเขต

---

### 4.2 หน้าจอจัดการข้อมูล Unit

**แสดง:**
- รายการ Unit จาก REM
- สถานะราคาประเมิน
- LandType ที่ใช้คำนวณ
- ผลภาษีที่คำนวณแล้ว

**Actions:**
- แก้ไขประเภทที่ดิน (กรณี override)
- แก้ไขราคาประเมิน (กรณี manual)
- บันทึก Remark/Note

---

### 4.3 Tax Calculation Engine

**Process Flow:**

```
1. เลือกปีภาษี (TaxYear)
         │
         ▼
2. ดึง TotalLandValue จาก LandValuation
         │
         ▼
3. ดึง LandType (จาก LandUnit หรือ override)
         │
         ▼
4. ดึงกติกาอัตราภาษี จาก TaxRateRule
         │
         ▼
5. คำนวณ TaxAmountCalculated (ตามขั้นบันได)
         │
         ▼
6. บันทึกผลลง TaxCalculation
         │
         ▼
7. Flag รายการที่ไม่มีราคาประเมิน = INCOMPLETE
```

---

### 4.4 Upload และจัดการใบแจ้งภาษี

**Process Flow:**

```
1. User อัปโหลด PDF/สแกน
         │
         ▼
2. สร้าง TaxNoticeFile
         │
         ▼
3. เรียก OCR + AI แยกรายการ → TaxNoticeItem
         │
         ▼
4. รัน AI Matching กับ LandUnit
         │
         ▼
5. แสดงหน้าจอให้พนักงานตรวจสอบ/แก้ไข
         │
         ▼
6. เปรียบเทียบ TaxAmountNotice vs TaxAmountCalculated
         │
         ▼
7. Highlight ความต่าง (Over / Under / เท่ากัน)
```

---

## 5. Workflow ภาพรวม

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │ 1. IMPORT   │───►│ 2. SYNC ราคา    │───►│ 3. กำหนดประเภท  │             │
│  │ จาก REM     │    │ ประเมินจากกรม   │    │ + อัตราภาษี     │             │
│  └─────────────┘    └─────────────────┘    └────────┬────────┘             │
│                                                      │                      │
│                                                      ▼                      │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │ 6. RECON    │◄───│ 5. UPLOAD       │◄───│ 4. RUN TAX      │             │
│  │ CILIATION   │    │ ใบแจ้งภาษี      │    │ CALCULATION     │             │
│  └─────────────┘    └─────────────────┘    └─────────────────┘             │
│        │                                                                    │
│        ▼                                                                    │
│  ┌─────────────┐                                                           │
│  │ รายงาน/     │                                                           │
│  │ Export      │                                                           │
│  └─────────────┘                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Non-Functional Requirements

### 6.1 Security & Access Control

| Role | Permissions |
|------|-------------|
| Viewer | ดูข้อมูลได้อย่างเดียว |
| Editor | แก้ไขข้อมูล, Upload เอกสาร, Matching |
| Admin | จัดการ User, ตั้งค่าระบบ, ดู Audit Log |

### 6.2 Audit Trail

- เก็บประวัติการเปลี่ยนแปลงค่า (ก่อน–หลัง) สำหรับข้อมูลสำคัญ
- Log ทุกการแก้ไข: ราคาประเมิน, ประเภทที่ดิน, Matching

### 6.3 Performance

- รองรับจำนวน Unit ตามโครงการทั้งหมด (ระบุประมาณการภายหลัง)
- Batch/Job ต้อง idempotent (รันซ้ำได้)

### 6.4 Integration-friendly

- ออก API ให้ระบบอื่นดึงผล TaxCalculation (Finance, Accounting)
- รองรับ Export Excel/PDF

---

## 7. หน้าจอหลัก (Screen List)

| # | Screen | Description |
|---|--------|-------------|
| 1 | Dashboard | ภาพรวมสถานะทั้งหมด |
| 2 | Unit Management | จัดการข้อมูล Unit + ภาษี |
| 3 | Tax Notice Upload | อัปโหลด + OCR ใบแจ้งภาษี |
| 4 | Matching Review | ตรวจสอบ/แก้ไขการจับคู่ |
| 5 | Reconciliation | เปรียบเทียบภาษีคำนวณ vs เรียกเก็บ |
| 6 | Tax Rate Setup | ตั้งค่าอัตราภาษี |
| 7 | Reports | รายงานต่างๆ |

---

## 8. คำถามที่ต้องตกลงกับ Vendor/IT

1. **Integration กับ REM**: ใช้ Database View หรือ API?
2. **API กรมธนารักษ์**: มี credential อยู่แล้วหรือต้องสมัครใหม่?
3. **OCR Engine**: ใช้ in-house หรือ cloud service (Google Vision, Azure)?
4. **Hosting**: On-premise หรือ Cloud?
5. **จำนวน Unit โดยประมาณ**: เท่าไหร่?
6. **Timeline คร่าวๆ**: ต้องการใช้งานเมื่อไหร่?

---

*เอกสารนี้เป็น Draft สำหรับคุยกับทีม หากโอเคค่อยแตกรายละเอียดทีหลัง*
