-- =====================================================
-- IT Service Desk V2 - Database Schema
-- ITIL-Based IT Support System
-- Version: 2.0
-- Created: January 2025
-- =====================================================

-- Drop existing tables (for fresh install)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS ticket_attachments;
DROP TABLE IF EXISTS ticket_activities;
DROP TABLE IF EXISTS ticket_related;
DROP TABLE IF EXISTS ticket_sla_logs;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS service_catalog_items;
DROP TABLE IF EXISTS service_categories;
DROP TABLE IF EXISTS kb_article_views;
DROP TABLE IF EXISTS kb_article_feedback;
DROP TABLE IF EXISTS kb_articles;
DROP TABLE IF EXISTS kb_categories;
DROP TABLE IF EXISTS sla_policies;
DROP TABLE IF EXISTS sla_escalation_rules;
DROP TABLE IF EXISTS notification_settings;
DROP TABLE IF EXISTS notification_logs;
DROP TABLE IF EXISTS team_members;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS ticket_categories;
DROP TABLE IF EXISTS ticket_priorities;
DROP TABLE IF EXISTS ticket_statuses;
DROP TABLE IF EXISTS ticket_types;
DROP TABLE IF EXISTS source_channels;
DROP TABLE IF EXISTS system_settings;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS asset_maintenance_logs;
DROP TABLE IF EXISTS asset_software;
DROP TABLE IF EXISTS asset_assignments;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS asset_models;
DROP TABLE IF EXISTS asset_manufacturers;
DROP TABLE IF EXISTS asset_categories;
DROP TABLE IF EXISTS asset_locations;
DROP TABLE IF EXISTS software_licenses;
DROP TABLE IF EXISTS software_products;
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- MASTER DATA TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: departments (แผนก)
-- -----------------------------------------------------
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_th VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    parent_id INT NULL,
    manager_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: users (ผู้ใช้งาน - ทั้ง IT Staff และ End User)
-- -----------------------------------------------------
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(20) UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    first_name_th VARCHAR(100),
    last_name_th VARCHAR(100),
    first_name_en VARCHAR(100),
    last_name_en VARCHAR(100),
    display_name VARCHAR(100),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    line_id VARCHAR(50),
    avatar_url VARCHAR(500),
    department_id INT,
    position VARCHAR(100),
    role ENUM('admin', 'manager', 'agent', 'user') DEFAULT 'user',
    is_it_staff BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    INDEX idx_email (email),
    INDEX idx_employee_id (employee_id),
    INDEX idx_role (role),
    INDEX idx_is_it_staff (is_it_staff)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update departments manager reference
ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL;

-- -----------------------------------------------------
-- Table: teams (ทีม IT)
-- -----------------------------------------------------
CREATE TABLE teams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: team_members (สมาชิกทีม)
-- -----------------------------------------------------
CREATE TABLE team_members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('leader', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_team_member (team_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: source_channels (ช่องทางการแจ้ง)
-- -----------------------------------------------------
CREATE TABLE source_channels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default channels
INSERT INTO source_channels (code, name, icon, color, sort_order) VALUES
('PHONE', 'โทรศัพท์', 'phone', 'blue', 1),
('EMAIL', 'อีเมล', 'mail', 'green', 2),
('LINE', 'LINE', 'message-circle', 'emerald', 3),
('WALKIN', 'Walk-in', 'user', 'purple', 4),
('PORTAL', 'Self-Service Portal', 'globe', 'indigo', 5);

-- -----------------------------------------------------
-- Table: ticket_types (ประเภท Ticket - ITIL)
-- -----------------------------------------------------
CREATE TABLE ticket_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_th VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert ITIL ticket types
INSERT INTO ticket_types (code, name_th, name_en, icon, color, sort_order) VALUES
('INCIDENT', 'Incident', 'Incident', 'alert-triangle', 'red', 1),
('REQUEST', 'Service Request', 'Service Request', 'file-text', 'blue', 2),
('PROBLEM', 'Problem', 'Problem', 'help-circle', 'orange', 3),
('CHANGE', 'Change Request', 'Change Request', 'refresh-cw', 'purple', 4);

-- -----------------------------------------------------
-- Table: ticket_statuses (สถานะ Ticket - ITIL Flow)
-- -----------------------------------------------------
CREATE TABLE ticket_statuses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_th VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    description TEXT,
    color VARCHAR(20),
    bg_color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_open BOOLEAN DEFAULT TRUE,      -- TRUE = ยังเปิดอยู่, FALSE = ปิดแล้ว
    is_default BOOLEAN DEFAULT FALSE,   -- สถานะเริ่มต้น
    is_resolved BOOLEAN DEFAULT FALSE,  -- ถือว่าแก้ไขเสร็จ
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert ITIL statuses
INSERT INTO ticket_statuses (code, name_th, name_en, color, bg_color, sort_order, is_open, is_default, is_resolved) VALUES
('NEW', 'ใหม่', 'New', 'slate', 'bg-slate-100', 1, TRUE, TRUE, FALSE),
('OPEN', 'เปิด', 'Open', 'blue', 'bg-blue-100', 2, TRUE, FALSE, FALSE),
('IN_PROGRESS', 'กำลังดำเนินการ', 'In Progress', 'yellow', 'bg-yellow-100', 3, TRUE, FALSE, FALSE),
('PENDING', 'รอข้อมูล', 'Pending', 'orange', 'bg-orange-100', 4, TRUE, FALSE, FALSE),
('RESOLVED', 'แก้ไขแล้ว', 'Resolved', 'green', 'bg-green-100', 5, TRUE, FALSE, TRUE),
('CLOSED', 'ปิด', 'Closed', 'gray', 'bg-gray-100', 6, FALSE, FALSE, TRUE),
('CANCELLED', 'ยกเลิก', 'Cancelled', 'red', 'bg-red-100', 7, FALSE, FALSE, FALSE);

-- -----------------------------------------------------
-- Table: ticket_priorities (ระดับความสำคัญ)
-- -----------------------------------------------------
CREATE TABLE ticket_priorities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_th VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    description TEXT,
    color VARCHAR(20),
    bg_color VARCHAR(20),
    icon VARCHAR(50),
    response_hours INT,        -- SLA Response time (ชม.)
    resolution_hours INT,      -- SLA Resolution time (ชม.)
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert priorities with default SLA
INSERT INTO ticket_priorities (code, name_th, name_en, color, bg_color, icon, response_hours, resolution_hours, sort_order) VALUES
('CRITICAL', 'วิกฤต', 'Critical', 'red', 'bg-red-100', 'alert-octagon', 1, 4, 1),
('HIGH', 'สูง', 'High', 'orange', 'bg-orange-100', 'arrow-up', 2, 8, 2),
('MEDIUM', 'ปานกลาง', 'Medium', 'yellow', 'bg-yellow-100', 'minus', 4, 24, 3),
('LOW', 'ต่ำ', 'Low', 'green', 'bg-green-100', 'arrow-down', 8, 48, 4);

-- -----------------------------------------------------
-- Table: ticket_categories (หมวดหมู่ Ticket)
-- -----------------------------------------------------
CREATE TABLE ticket_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name_th VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    parent_id INT NULL,
    description TEXT,
    icon VARCHAR(50),
    default_team_id INT,
    default_priority_id INT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES ticket_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (default_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    FOREIGN KEY (default_priority_id) REFERENCES ticket_priorities(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default categories
INSERT INTO ticket_categories (code, name_th, name_en, icon, sort_order) VALUES
('HARDWARE', 'Hardware', 'Hardware', 'cpu', 1),
('SOFTWARE', 'Software', 'Software', 'package', 2),
('NETWORK', 'Network', 'Network', 'wifi', 3),
('EMAIL', 'Email & Communication', 'Email & Communication', 'mail', 4),
('ACCESS', 'Access & Permission', 'Access & Permission', 'key', 5),
('SECURITY', 'Security', 'Security', 'shield', 6),
('PRINTING', 'Printing & Scanning', 'Printing & Scanning', 'printer', 7),
('OTHER', 'อื่นๆ', 'Others', 'more-horizontal', 99);

-- =====================================================
-- SERVICE CATALOG TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: service_categories (หมวดหมู่บริการ)
-- -----------------------------------------------------
CREATE TABLE service_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name_th VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert service categories
INSERT INTO service_categories (code, name_th, name_en, icon, color, sort_order) VALUES
('EQUIPMENT', 'อุปกรณ์ IT', 'IT Equipment', 'laptop', 'blue', 1),
('SOFTWARE', 'ซอฟต์แวร์', 'Software', 'package', 'green', 2),
('ACCESS', 'สิทธิ์การเข้าถึง', 'Access & Permissions', 'key', 'purple', 3),
('ONBOARDING', 'พนักงานใหม่', 'New Employee', 'user-plus', 'teal', 4),
('SECURITY', 'ความปลอดภัย', 'Security', 'shield', 'red', 5);

-- -----------------------------------------------------
-- Table: service_catalog_items (รายการบริการ)
-- -----------------------------------------------------
CREATE TABLE service_catalog_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    name_th VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    short_description TEXT,
    full_description TEXT,
    icon VARCHAR(50),
    image_url VARCHAR(500),

    -- SLA Settings
    default_priority_id INT,
    sla_response_hours INT,
    sla_resolution_hours INT,

    -- Workflow
    requires_approval BOOLEAN DEFAULT FALSE,
    approval_levels INT DEFAULT 0,
    default_team_id INT,

    -- Form Configuration (JSON)
    form_fields JSON,

    -- Display
    is_featured BOOLEAN DEFAULT FALSE,
    is_popular BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    request_count INT DEFAULT 0,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES service_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (default_priority_id) REFERENCES ticket_priorities(id) ON DELETE SET NULL,
    FOREIGN KEY (default_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_is_featured (is_featured),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample services
INSERT INTO service_catalog_items (code, category_id, name_th, name_en, short_description, sla_response_hours, sla_resolution_hours, is_featured, sort_order) VALUES
('SVC-LAPTOP', 1, 'ขอเครื่องคอมพิวเตอร์ใหม่', 'New Laptop Request', 'ขอเครื่อง Laptop หรือ Desktop ใหม่สำหรับการทำงาน', 4, 120, TRUE, 1),
('SVC-SOFTWARE', 2, 'ติดตั้งซอฟต์แวร์', 'Software Installation', 'ขอติดตั้งโปรแกรมที่จำเป็นสำหรับการทำงาน', 2, 8, TRUE, 2),
('SVC-PASSWORD', 3, 'รีเซ็ตรหัสผ่าน', 'Password Reset', 'ขอรีเซ็ตรหัสผ่าน AD/Email/VPN', 1, 2, TRUE, 3),
('SVC-VPN', 3, 'ขอสิทธิ์ VPN', 'VPN Access Request', 'ขอสิทธิ์เชื่อมต่อ VPN จากภายนอก', 2, 24, FALSE, 4),
('SVC-ONBOARD', 4, 'IT Onboarding', 'IT Onboarding', 'เตรียมอุปกรณ์และสิทธิ์สำหรับพนักงานใหม่', 4, 48, TRUE, 5),
('SVC-EMAIL-DL', 3, 'สร้าง Email Distribution List', 'Email Distribution List', 'ขอสร้างหรือแก้ไข Email Group', 2, 8, FALSE, 6),
('SVC-PRINTER', 1, 'ติดตั้งเครื่องพิมพ์', 'Printer Setup', 'ขอติดตั้งหรือแก้ไขปัญหาเครื่องพิมพ์', 2, 8, FALSE, 7),
('SVC-FOLDER', 3, 'ขอสิทธิ์ Shared Folder', 'Shared Folder Access', 'ขอสิทธิ์เข้าถึง Shared Folder', 2, 8, FALSE, 8),
('SVC-SECURITY', 5, 'แจ้งเหตุด้านความปลอดภัย', 'Security Incident', 'แจ้งเหตุการณ์ด้านความปลอดภัย IT', 1, 4, FALSE, 9);

-- =====================================================
-- SLA CONFIGURATION TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: sla_policies (นโยบาย SLA)
-- -----------------------------------------------------
CREATE TABLE sla_policies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Conditions (when to apply this SLA)
    applies_to_type_id INT,
    applies_to_priority_id INT,
    applies_to_category_id INT,
    applies_to_service_id INT,
    applies_to_vip BOOLEAN DEFAULT FALSE,

    -- SLA Times (in minutes)
    response_time_minutes INT NOT NULL,
    resolution_time_minutes INT NOT NULL,

    -- Business Hours
    use_business_hours BOOLEAN DEFAULT TRUE,
    business_hours_start TIME DEFAULT '08:30:00',
    business_hours_end TIME DEFAULT '17:30:00',
    exclude_weekends BOOLEAN DEFAULT TRUE,
    exclude_holidays BOOLEAN DEFAULT TRUE,

    -- Escalation
    escalate_on_breach BOOLEAN DEFAULT TRUE,

    priority INT DEFAULT 0,  -- Higher = more specific, checked first
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (applies_to_type_id) REFERENCES ticket_types(id) ON DELETE SET NULL,
    FOREIGN KEY (applies_to_priority_id) REFERENCES ticket_priorities(id) ON DELETE SET NULL,
    FOREIGN KEY (applies_to_category_id) REFERENCES ticket_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (applies_to_service_id) REFERENCES service_catalog_items(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default SLA policies
INSERT INTO sla_policies (code, name, applies_to_priority_id, response_time_minutes, resolution_time_minutes, priority) VALUES
('SLA-CRITICAL', 'Critical Priority SLA', 1, 60, 240, 100),
('SLA-HIGH', 'High Priority SLA', 2, 120, 480, 90),
('SLA-MEDIUM', 'Medium Priority SLA', 3, 240, 1440, 80),
('SLA-LOW', 'Low Priority SLA', 4, 480, 2880, 70);

-- -----------------------------------------------------
-- Table: sla_escalation_rules (กฎการ Escalate)
-- -----------------------------------------------------
CREATE TABLE sla_escalation_rules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sla_policy_id INT NOT NULL,
    level INT NOT NULL,  -- 1, 2, 3...

    -- Trigger conditions
    trigger_type ENUM('response_breach', 'resolution_breach', 'percentage') NOT NULL,
    trigger_percentage INT,  -- e.g., 80% of SLA time

    -- Actions
    notify_assignee BOOLEAN DEFAULT TRUE,
    notify_team_leader BOOLEAN DEFAULT FALSE,
    notify_manager BOOLEAN DEFAULT FALSE,
    notify_user_ids JSON,  -- Additional users to notify

    -- Auto-actions
    auto_increase_priority BOOLEAN DEFAULT FALSE,
    auto_reassign_to_team_id INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sla_policy_id) REFERENCES sla_policies(id) ON DELETE CASCADE,
    FOREIGN KEY (auto_reassign_to_team_id) REFERENCES teams(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TICKET TABLES (หัวใจหลัก)
-- =====================================================

-- -----------------------------------------------------
-- Table: tickets (Ticket หลัก)
-- -----------------------------------------------------
CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(20) NOT NULL UNIQUE,  -- e.g., INC-2025-00001

    -- Classification
    type_id INT NOT NULL,
    status_id INT NOT NULL,
    priority_id INT NOT NULL,
    category_id INT,
    service_id INT,                    -- ถ้ามาจาก Service Catalog

    -- Source
    source_channel_id INT,

    -- Content
    subject VARCHAR(500) NOT NULL,
    description TEXT,

    -- Requester (ผู้แจ้ง)
    requester_id INT,
    requester_name VARCHAR(200),       -- กรณีไม่มีใน user
    requester_email VARCHAR(100),
    requester_phone VARCHAR(50),
    requester_department_id INT,
    is_vip BOOLEAN DEFAULT FALSE,

    -- Assignment
    assigned_team_id INT,
    assigned_to_id INT,

    -- SLA Tracking
    sla_policy_id INT,
    sla_response_due_at TIMESTAMP NULL,
    sla_resolution_due_at TIMESTAMP NULL,
    first_response_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    sla_response_breached BOOLEAN DEFAULT FALSE,
    sla_resolution_breached BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_id INT,
    updated_by_id INT,

    -- Related
    parent_ticket_id INT,              -- สำหรับ Child tickets

    -- Satisfaction
    satisfaction_rating INT,           -- 1-5 stars
    satisfaction_comment TEXT,
    satisfaction_submitted_at TIMESTAMP NULL,

    -- Additional Data (JSON for flexibility)
    custom_fields JSON,
    tags JSON,

    FOREIGN KEY (type_id) REFERENCES ticket_types(id),
    FOREIGN KEY (status_id) REFERENCES ticket_statuses(id),
    FOREIGN KEY (priority_id) REFERENCES ticket_priorities(id),
    FOREIGN KEY (category_id) REFERENCES ticket_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (service_id) REFERENCES service_catalog_items(id) ON DELETE SET NULL,
    FOREIGN KEY (source_channel_id) REFERENCES source_channels(id) ON DELETE SET NULL,
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (requester_department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (sla_policy_id) REFERENCES sla_policies(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_ticket_id) REFERENCES tickets(id) ON DELETE SET NULL,

    INDEX idx_ticket_number (ticket_number),
    INDEX idx_status (status_id),
    INDEX idx_priority (priority_id),
    INDEX idx_type (type_id),
    INDEX idx_category (category_id),
    INDEX idx_requester (requester_id),
    INDEX idx_assigned_to (assigned_to_id),
    INDEX idx_assigned_team (assigned_team_id),
    INDEX idx_created_at (created_at),
    INDEX idx_sla_response_due (sla_response_due_at),
    INDEX idx_sla_resolution_due (sla_resolution_due_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: ticket_activities (กิจกรรม/Timeline)
-- -----------------------------------------------------
CREATE TABLE ticket_activities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,

    activity_type ENUM(
        'created',           -- สร้าง Ticket
        'status_changed',    -- เปลี่ยนสถานะ
        'priority_changed',  -- เปลี่ยน Priority
        'assigned',          -- มอบหมาย
        'reassigned',        -- โอนงาน
        'comment_added',     -- เพิ่ม Comment
        'comment_internal',  -- Internal Note
        'attachment_added',  -- แนบไฟล์
        'sla_warning',       -- เตือน SLA
        'sla_breached',      -- SLA Breached
        'escalated',         -- Escalate
        'merged',            -- รวม Ticket
        'linked',            -- เชื่อมโยง
        'resolved',          -- แก้ไขแล้ว
        'reopened',          -- เปิดใหม่
        'closed',            -- ปิด
        'satisfaction',      -- ประเมินความพึงพอใจ
        'field_updated'      -- แก้ไขข้อมูล
    ) NOT NULL,

    -- Content
    content TEXT,
    old_value VARCHAR(500),
    new_value VARCHAR(500),

    -- Visibility
    is_public BOOLEAN DEFAULT TRUE,    -- FALSE = Internal only

    -- Actor
    created_by_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_ticket (ticket_id),
    INDEX idx_created_at (created_at),
    INDEX idx_activity_type (activity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: ticket_attachments (ไฟล์แนบ)
-- -----------------------------------------------------
CREATE TABLE ticket_attachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    activity_id INT,

    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,                     -- bytes
    file_type VARCHAR(100),
    mime_type VARCHAR(100),

    uploaded_by_id INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES ticket_activities(id) ON DELETE SET NULL,
    FOREIGN KEY (uploaded_by_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: ticket_related (Ticket ที่เกี่ยวข้อง)
-- -----------------------------------------------------
CREATE TABLE ticket_related (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    related_ticket_id INT NOT NULL,
    relation_type ENUM('related', 'duplicate', 'parent', 'child', 'blocks', 'blocked_by') DEFAULT 'related',
    created_by_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (related_ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_relation (ticket_id, related_ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: ticket_sla_logs (ประวัติ SLA)
-- -----------------------------------------------------
CREATE TABLE ticket_sla_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,

    event_type ENUM('started', 'paused', 'resumed', 'response_met', 'response_breached', 'resolution_met', 'resolution_breached') NOT NULL,

    sla_policy_id INT,
    response_due_at TIMESTAMP NULL,
    resolution_due_at TIMESTAMP NULL,
    response_time_minutes INT,        -- เวลาที่ใช้ตอบ
    resolution_time_minutes INT,      -- เวลาที่ใช้แก้ไข

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (sla_policy_id) REFERENCES sla_policies(id) ON DELETE SET NULL,
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- KNOWLEDGE BASE TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: kb_categories (หมวดหมู่ Knowledge Base)
-- -----------------------------------------------------
CREATE TABLE kb_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name_th VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    parent_id INT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (parent_id) REFERENCES kb_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert KB categories
INSERT INTO kb_categories (code, name_th, name_en, icon, color, sort_order) VALUES
('GETTING-STARTED', 'เริ่มต้นใช้งาน', 'Getting Started', 'play', 'blue', 1),
('EMAIL', 'อีเมลและการสื่อสาร', 'Email & Communication', 'mail', 'green', 2),
('NETWORK', 'เครือข่ายและ VPN', 'Network & VPN', 'wifi', 'purple', 3),
('SECURITY', 'ความปลอดภัย', 'Security', 'shield', 'red', 4),
('SOFTWARE', 'ซอฟต์แวร์', 'Software', 'package', 'teal', 5),
('HARDWARE', 'อุปกรณ์', 'Hardware', 'cpu', 'orange', 6),
('FAQ', 'คำถามที่พบบ่อย', 'FAQ', 'help-circle', 'indigo', 7);

-- -----------------------------------------------------
-- Table: kb_articles (บทความ Knowledge Base)
-- -----------------------------------------------------
CREATE TABLE kb_articles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,

    title_th VARCHAR(500) NOT NULL,
    title_en VARCHAR(500),
    slug VARCHAR(200) UNIQUE,

    content_th LONGTEXT,
    content_en LONGTEXT,
    excerpt TEXT,

    -- Metadata
    author_id INT,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',

    -- SEO & Search
    keywords TEXT,
    meta_description TEXT,

    -- Stats
    view_count INT DEFAULT 0,
    helpful_count INT DEFAULT 0,
    not_helpful_count INT DEFAULT 0,

    -- Display
    is_featured BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,

    -- Related
    related_articles JSON,      -- Array of article IDs
    related_services JSON,      -- Array of service IDs

    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES kb_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_is_featured (is_featured),
    FULLTEXT INDEX ft_search (title_th, title_en, content_th, content_en, keywords)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: kb_article_views (สถิติการเข้าชม)
-- -----------------------------------------------------
CREATE TABLE kb_article_views (
    id INT PRIMARY KEY AUTO_INCREMENT,
    article_id INT NOT NULL,
    user_id INT,
    session_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (article_id) REFERENCES kb_articles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_article (article_id),
    INDEX idx_viewed_at (viewed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: kb_article_feedback (Feedback บทความ)
-- -----------------------------------------------------
CREATE TABLE kb_article_feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    article_id INT NOT NULL,
    user_id INT,
    is_helpful BOOLEAN NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (article_id) REFERENCES kb_articles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- NOTIFICATION TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: notification_settings (การตั้งค่า Notification)
-- -----------------------------------------------------
CREATE TABLE notification_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,

    -- Email Notifications
    email_ticket_assigned BOOLEAN DEFAULT TRUE,
    email_ticket_updated BOOLEAN DEFAULT TRUE,
    email_ticket_resolved BOOLEAN DEFAULT TRUE,
    email_sla_warning BOOLEAN DEFAULT TRUE,
    email_sla_breached BOOLEAN DEFAULT TRUE,
    email_daily_digest BOOLEAN DEFAULT FALSE,

    -- In-App Notifications
    app_ticket_assigned BOOLEAN DEFAULT TRUE,
    app_ticket_updated BOOLEAN DEFAULT TRUE,
    app_ticket_resolved BOOLEAN DEFAULT TRUE,
    app_sla_warning BOOLEAN DEFAULT TRUE,
    app_new_comment BOOLEAN DEFAULT TRUE,

    -- LINE Notifications (if integrated)
    line_enabled BOOLEAN DEFAULT FALSE,
    line_urgent_only BOOLEAN DEFAULT TRUE,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table: notification_logs (ประวัติ Notification)
-- -----------------------------------------------------
CREATE TABLE notification_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,

    type ENUM('email', 'app', 'line', 'sms') NOT NULL,
    category VARCHAR(50),              -- ticket_assigned, sla_warning, etc.

    title VARCHAR(500),
    content TEXT,

    -- Reference
    reference_type VARCHAR(50),        -- ticket, article, etc.
    reference_id INT,

    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SYSTEM TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: system_settings (ตั้งค่าระบบ)
-- -----------------------------------------------------
CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    category VARCHAR(50),
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_by_id INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (updated_by_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description) VALUES
('ticket_number_prefix', 'TKT', 'string', 'tickets', 'Ticket number prefix'),
('ticket_number_format', '{PREFIX}-{YEAR}-{SEQ:5}', 'string', 'tickets', 'Ticket number format'),
('incident_prefix', 'INC', 'string', 'tickets', 'Incident ticket prefix'),
('request_prefix', 'REQ', 'string', 'tickets', 'Service Request prefix'),
('problem_prefix', 'PRB', 'string', 'tickets', 'Problem ticket prefix'),
('change_prefix', 'CHG', 'string', 'tickets', 'Change Request prefix'),
('business_hours_start', '08:30', 'string', 'sla', 'Business hours start'),
('business_hours_end', '17:30', 'string', 'sla', 'Business hours end'),
('working_days', '[1,2,3,4,5]', 'json', 'sla', 'Working days (0=Sun, 6=Sat)'),
('auto_close_resolved_days', '7', 'number', 'tickets', 'Days to auto-close resolved tickets'),
('satisfaction_survey_enabled', 'true', 'boolean', 'survey', 'Enable satisfaction survey'),
('company_name', 'SENA Development', 'string', 'general', 'Company name'),
('company_logo_url', '/images/logo.png', 'string', 'general', 'Company logo URL'),
('system_email', 'itservice@sena.co.th', 'string', 'email', 'System email address'),
('email_from_name', 'IT Service Desk', 'string', 'email', 'Email sender name');

-- -----------------------------------------------------
-- Table: audit_logs (Audit Trail)
-- -----------------------------------------------------
CREATE TABLE audit_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Who
    user_id INT,
    user_email VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- What
    action VARCHAR(50) NOT NULL,       -- create, update, delete, login, logout, etc.
    entity_type VARCHAR(50) NOT NULL,  -- ticket, user, setting, etc.
    entity_id INT,

    -- Details
    old_values JSON,
    new_values JSON,
    description TEXT,

    -- When
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user (user_id),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at),
    INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- View: Active Tickets Summary
CREATE OR REPLACE VIEW vw_active_tickets AS
SELECT
    t.id,
    t.ticket_number,
    t.subject,
    tt.name_en as type_name,
    ts.name_th as status_name,
    tp.name_th as priority_name,
    tp.color as priority_color,
    tc.name_th as category_name,
    sc.name as source_channel,
    CONCAT(u.first_name_th, ' ', u.last_name_th) as requester_name,
    d.name_th as requester_department,
    CONCAT(a.first_name_th, ' ', a.last_name_th) as assigned_to_name,
    tm.name as assigned_team_name,
    t.sla_response_due_at,
    t.sla_resolution_due_at,
    t.sla_response_breached,
    t.sla_resolution_breached,
    t.created_at,
    t.updated_at,
    TIMESTAMPDIFF(HOUR, t.created_at, NOW()) as age_hours
FROM tickets t
LEFT JOIN ticket_types tt ON t.type_id = tt.id
LEFT JOIN ticket_statuses ts ON t.status_id = ts.id
LEFT JOIN ticket_priorities tp ON t.priority_id = tp.id
LEFT JOIN ticket_categories tc ON t.category_id = tc.id
LEFT JOIN source_channels sc ON t.source_channel_id = sc.id
LEFT JOIN users u ON t.requester_id = u.id
LEFT JOIN departments d ON t.requester_department_id = d.id
LEFT JOIN users a ON t.assigned_to_id = a.id
LEFT JOIN teams tm ON t.assigned_team_id = tm.id
WHERE ts.is_open = TRUE;

-- View: Agent Workload
CREATE OR REPLACE VIEW vw_agent_workload AS
SELECT
    u.id as agent_id,
    u.employee_id,
    CONCAT(u.first_name_th, ' ', u.last_name_th) as agent_name,
    u.avatar_url,
    tm.name as team_name,
    COUNT(t.id) as total_open_tickets,
    SUM(CASE WHEN tp.code = 'CRITICAL' THEN 1 ELSE 0 END) as critical_count,
    SUM(CASE WHEN tp.code = 'HIGH' THEN 1 ELSE 0 END) as high_count,
    SUM(CASE WHEN tp.code = 'MEDIUM' THEN 1 ELSE 0 END) as medium_count,
    SUM(CASE WHEN tp.code = 'LOW' THEN 1 ELSE 0 END) as low_count,
    SUM(CASE WHEN t.sla_response_breached = TRUE OR t.sla_resolution_breached = TRUE THEN 1 ELSE 0 END) as breached_count
FROM users u
INNER JOIN team_members tmm ON u.id = tmm.user_id
INNER JOIN teams tm ON tmm.team_id = tm.id
LEFT JOIN tickets t ON t.assigned_to_id = u.id
LEFT JOIN ticket_statuses ts ON t.status_id = ts.id AND ts.is_open = TRUE
LEFT JOIN ticket_priorities tp ON t.priority_id = tp.id
WHERE u.is_it_staff = TRUE AND u.is_active = TRUE
GROUP BY u.id, u.employee_id, u.first_name_th, u.last_name_th, u.avatar_url, tm.name;

-- View: SLA Performance
CREATE OR REPLACE VIEW vw_sla_performance AS
SELECT
    DATE(t.created_at) as date,
    tt.name_en as ticket_type,
    COUNT(*) as total_tickets,
    SUM(CASE WHEN t.sla_response_breached = FALSE AND t.first_response_at IS NOT NULL THEN 1 ELSE 0 END) as response_met,
    SUM(CASE WHEN t.sla_response_breached = TRUE THEN 1 ELSE 0 END) as response_breached,
    SUM(CASE WHEN t.sla_resolution_breached = FALSE AND ts.is_resolved = TRUE THEN 1 ELSE 0 END) as resolution_met,
    SUM(CASE WHEN t.sla_resolution_breached = TRUE THEN 1 ELSE 0 END) as resolution_breached,
    ROUND(
        SUM(CASE WHEN t.sla_response_breached = FALSE AND t.first_response_at IS NOT NULL THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN t.first_response_at IS NOT NULL THEN 1 ELSE 0 END), 0),
        2
    ) as response_sla_percent,
    ROUND(
        SUM(CASE WHEN t.sla_resolution_breached = FALSE AND ts.is_resolved = TRUE THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN ts.is_resolved = TRUE THEN 1 ELSE 0 END), 0),
        2
    ) as resolution_sla_percent
FROM tickets t
LEFT JOIN ticket_types tt ON t.type_id = tt.id
LEFT JOIN ticket_statuses ts ON t.status_id = ts.id
GROUP BY DATE(t.created_at), tt.name_en;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure: Generate Ticket Number
CREATE PROCEDURE sp_generate_ticket_number(
    IN p_type_code VARCHAR(20),
    OUT p_ticket_number VARCHAR(20)
)
BEGIN
    DECLARE v_prefix VARCHAR(10);
    DECLARE v_year CHAR(4);
    DECLARE v_seq INT;

    -- Get prefix based on type
    CASE p_type_code
        WHEN 'INCIDENT' THEN SET v_prefix = 'INC';
        WHEN 'REQUEST' THEN SET v_prefix = 'REQ';
        WHEN 'PROBLEM' THEN SET v_prefix = 'PRB';
        WHEN 'CHANGE' THEN SET v_prefix = 'CHG';
        ELSE SET v_prefix = 'TKT';
    END CASE;

    SET v_year = YEAR(CURDATE());

    -- Get next sequence
    SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number, -5) AS UNSIGNED)), 0) + 1 INTO v_seq
    FROM tickets
    WHERE ticket_number LIKE CONCAT(v_prefix, '-', v_year, '-%');

    SET p_ticket_number = CONCAT(v_prefix, '-', v_year, '-', LPAD(v_seq, 5, '0'));
END //

-- Procedure: Calculate SLA Due Dates
CREATE PROCEDURE sp_calculate_sla_dates(
    IN p_ticket_id INT,
    IN p_priority_id INT,
    IN p_created_at TIMESTAMP
)
BEGIN
    DECLARE v_response_hours INT;
    DECLARE v_resolution_hours INT;

    -- Get SLA hours from priority
    SELECT response_hours, resolution_hours
    INTO v_response_hours, v_resolution_hours
    FROM ticket_priorities
    WHERE id = p_priority_id;

    -- Calculate due dates (simplified - not considering business hours)
    UPDATE tickets
    SET
        sla_response_due_at = DATE_ADD(p_created_at, INTERVAL v_response_hours HOUR),
        sla_resolution_due_at = DATE_ADD(p_created_at, INTERVAL v_resolution_hours HOUR)
    WHERE id = p_ticket_id;
END //

-- Procedure: Get Dashboard Stats
CREATE PROCEDURE sp_get_dashboard_stats(
    IN p_user_id INT,
    IN p_is_manager BOOLEAN
)
BEGIN
    -- Total Open Tickets
    SELECT
        COUNT(*) as total_open,
        SUM(CASE WHEN ts.code = 'NEW' THEN 1 ELSE 0 END) as new_count,
        SUM(CASE WHEN ts.code = 'IN_PROGRESS' THEN 1 ELSE 0 END) as in_progress_count,
        SUM(CASE WHEN ts.code = 'PENDING' THEN 1 ELSE 0 END) as pending_count,
        SUM(CASE WHEN t.sla_response_breached = TRUE OR t.sla_resolution_breached = TRUE THEN 1 ELSE 0 END) as breached_count,
        SUM(CASE WHEN tp.code = 'CRITICAL' THEN 1 ELSE 0 END) as critical_count,
        SUM(CASE WHEN tp.code = 'HIGH' THEN 1 ELSE 0 END) as high_count
    FROM tickets t
    INNER JOIN ticket_statuses ts ON t.status_id = ts.id
    INNER JOIN ticket_priorities tp ON t.priority_id = tp.id
    WHERE ts.is_open = TRUE
    AND (p_is_manager = TRUE OR t.assigned_to_id = p_user_id);

    -- Tickets by Status
    SELECT
        ts.name_th as status_name,
        ts.color,
        COUNT(*) as count
    FROM tickets t
    INNER JOIN ticket_statuses ts ON t.status_id = ts.id
    WHERE ts.is_open = TRUE
    GROUP BY ts.id, ts.name_th, ts.color
    ORDER BY ts.sort_order;

    -- Today's Activity
    SELECT
        COUNT(*) as tickets_today,
        SUM(CASE WHEN ts.is_resolved = TRUE AND DATE(t.resolved_at) = CURDATE() THEN 1 ELSE 0 END) as resolved_today
    FROM tickets t
    INNER JOIN ticket_statuses ts ON t.status_id = ts.id
    WHERE DATE(t.created_at) = CURDATE();
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger: After Ticket Insert - Log Creation
CREATE TRIGGER trg_ticket_after_insert
AFTER INSERT ON tickets
FOR EACH ROW
BEGIN
    INSERT INTO ticket_activities (
        ticket_id,
        activity_type,
        content,
        created_by_id,
        is_public
    ) VALUES (
        NEW.id,
        'created',
        CONCAT('Ticket created: ', NEW.subject),
        NEW.created_by_id,
        TRUE
    );

    -- Log SLA start
    INSERT INTO ticket_sla_logs (
        ticket_id,
        event_type,
        sla_policy_id,
        response_due_at,
        resolution_due_at
    ) VALUES (
        NEW.id,
        'started',
        NEW.sla_policy_id,
        NEW.sla_response_due_at,
        NEW.sla_resolution_due_at
    );
END //

-- Trigger: After Ticket Update - Log Changes
CREATE TRIGGER trg_ticket_after_update
AFTER UPDATE ON tickets
FOR EACH ROW
BEGIN
    -- Status Change
    IF OLD.status_id != NEW.status_id THEN
        INSERT INTO ticket_activities (
            ticket_id,
            activity_type,
            old_value,
            new_value,
            created_by_id
        )
        SELECT
            NEW.id,
            'status_changed',
            os.name_th,
            ns.name_th,
            NEW.updated_by_id
        FROM ticket_statuses os, ticket_statuses ns
        WHERE os.id = OLD.status_id AND ns.id = NEW.status_id;
    END IF;

    -- Priority Change
    IF OLD.priority_id != NEW.priority_id THEN
        INSERT INTO ticket_activities (
            ticket_id,
            activity_type,
            old_value,
            new_value,
            created_by_id
        )
        SELECT
            NEW.id,
            'priority_changed',
            op.name_th,
            np.name_th,
            NEW.updated_by_id
        FROM ticket_priorities op, ticket_priorities np
        WHERE op.id = OLD.priority_id AND np.id = NEW.priority_id;
    END IF;

    -- Assignment Change
    IF OLD.assigned_to_id IS DISTINCT FROM NEW.assigned_to_id THEN
        INSERT INTO ticket_activities (
            ticket_id,
            activity_type,
            old_value,
            new_value,
            created_by_id
        )
        SELECT
            NEW.id,
            CASE WHEN OLD.assigned_to_id IS NULL THEN 'assigned' ELSE 'reassigned' END,
            CONCAT(ou.first_name_th, ' ', ou.last_name_th),
            CONCAT(nu.first_name_th, ' ', nu.last_name_th),
            NEW.updated_by_id
        FROM (SELECT 1) dummy
        LEFT JOIN users ou ON ou.id = OLD.assigned_to_id
        LEFT JOIN users nu ON nu.id = NEW.assigned_to_id;
    END IF;

    -- Check SLA Breach
    IF NEW.sla_response_breached = TRUE AND OLD.sla_response_breached = FALSE THEN
        INSERT INTO ticket_activities (
            ticket_id,
            activity_type,
            content,
            is_public
        ) VALUES (
            NEW.id,
            'sla_breached',
            'SLA Response time breached',
            FALSE
        );

        INSERT INTO ticket_sla_logs (ticket_id, event_type)
        VALUES (NEW.id, 'response_breached');
    END IF;

    IF NEW.sla_resolution_breached = TRUE AND OLD.sla_resolution_breached = FALSE THEN
        INSERT INTO ticket_activities (
            ticket_id,
            activity_type,
            content,
            is_public
        ) VALUES (
            NEW.id,
            'sla_breached',
            'SLA Resolution time breached',
            FALSE
        );

        INSERT INTO ticket_sla_logs (ticket_id, event_type)
        VALUES (NEW.id, 'resolution_breached');
    END IF;
END //

-- Trigger: Update KB Article View Count
CREATE TRIGGER trg_kb_article_view_after_insert
AFTER INSERT ON kb_article_views
FOR EACH ROW
BEGIN
    UPDATE kb_articles
    SET view_count = view_count + 1
    WHERE id = NEW.article_id;
END //

-- Trigger: Update KB Article Feedback Count
CREATE TRIGGER trg_kb_feedback_after_insert
AFTER INSERT ON kb_article_feedback
FOR EACH ROW
BEGIN
    IF NEW.is_helpful = TRUE THEN
        UPDATE kb_articles
        SET helpful_count = helpful_count + 1
        WHERE id = NEW.article_id;
    ELSE
        UPDATE kb_articles
        SET not_helpful_count = not_helpful_count + 1
        WHERE id = NEW.article_id;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample departments
INSERT INTO departments (code, name_th, name_en) VALUES
('IT', 'ฝ่ายเทคโนโลยีสารสนเทศ', 'Information Technology'),
('HR', 'ฝ่ายทรัพยากรบุคคล', 'Human Resources'),
('FIN', 'ฝ่ายการเงิน', 'Finance'),
('MKT', 'ฝ่ายการตลาด', 'Marketing'),
('SALES', 'ฝ่ายขาย', 'Sales'),
('OPS', 'ฝ่ายปฏิบัติการ', 'Operations');

-- Insert sample IT team
INSERT INTO teams (code, name, description) VALUES
('IT-HELPDESK', 'IT Helpdesk', 'First-line support team'),
('IT-INFRA', 'IT Infrastructure', 'Network and Server team'),
('IT-APP', 'IT Application', 'Application support team'),
('IT-SECURITY', 'IT Security', 'Information Security team');

-- Insert sample admin user
INSERT INTO users (employee_id, email, first_name_th, last_name_th, first_name_en, last_name_en, display_name, department_id, role, is_it_staff) VALUES
('IT001', 'admin@sena.co.th', 'ผู้ดูแล', 'ระบบ', 'System', 'Admin', 'System Admin', 1, 'admin', TRUE),
('IT002', 'support1@sena.co.th', 'สมชาย', 'ใจดี', 'Somchai', 'Jaidee', 'สมชาย ใจดี', 1, 'agent', TRUE),
('IT003', 'support2@sena.co.th', 'สมหญิง', 'รักงาน', 'Somying', 'Rukngarn', 'สมหญิง รักงาน', 1, 'agent', TRUE),
('IT004', 'manager@sena.co.th', 'วิชัย', 'ผู้จัดการ', 'Wichai', 'Manager', 'วิชัย ผู้จัดการ', 1, 'manager', TRUE);

-- Add team members
INSERT INTO team_members (team_id, user_id, role) VALUES
(1, 1, 'leader'),
(1, 2, 'member'),
(1, 3, 'member'),
(2, 4, 'leader');

-- Insert sample KB articles
INSERT INTO kb_articles (category_id, title_th, title_en, slug, excerpt, status, is_featured, author_id) VALUES
(1, 'วิธีการเชื่อมต่อ WiFi ในออฟฟิศ', 'How to Connect to Office WiFi', 'connect-office-wifi', 'ขั้นตอนการเชื่อมต่อ WiFi สำหรับพนักงานใหม่', 'published', TRUE, 1),
(2, 'การตั้งค่า Email บน iPhone', 'Setup Email on iPhone', 'setup-email-iphone', 'วิธีการตั้งค่า Corporate Email บน iPhone', 'published', TRUE, 1),
(3, 'การเชื่อมต่อ VPN จากที่บ้าน', 'Connect VPN from Home', 'connect-vpn-home', 'ขั้นตอนการเชื่อมต่อ VPN เพื่อทำงานจากที่บ้าน', 'published', TRUE, 1),
(4, 'วิธีการเปลี่ยนรหัสผ่าน', 'How to Change Password', 'change-password', 'ขั้นตอนการเปลี่ยนรหัสผ่าน AD และ Email', 'published', FALSE, 1),
(7, 'ติดต่อ IT Helpdesk ได้อย่างไร', 'How to Contact IT Helpdesk', 'contact-it-helpdesk', 'ช่องทางการติดต่อ IT Helpdesk', 'published', FALSE, 1);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Additional composite indexes for common queries
CREATE INDEX idx_tickets_status_priority ON tickets(status_id, priority_id);
CREATE INDEX idx_tickets_assigned_status ON tickets(assigned_to_id, status_id);
CREATE INDEX idx_tickets_team_status ON tickets(assigned_team_id, status_id);
CREATE INDEX idx_tickets_requester_status ON tickets(requester_id, status_id);
CREATE INDEX idx_tickets_created_status ON tickets(created_at, status_id);
CREATE INDEX idx_activities_ticket_type ON ticket_activities(ticket_id, activity_type);

-- =====================================================
-- GRANT PERMISSIONS (adjust as needed)
-- =====================================================
-- GRANT SELECT, INSERT, UPDATE, DELETE ON it_service_desk.* TO 'app_user'@'localhost';
-- GRANT EXECUTE ON PROCEDURE it_service_desk.sp_generate_ticket_number TO 'app_user'@'localhost';
-- GRANT EXECUTE ON PROCEDURE it_service_desk.sp_calculate_sla_dates TO 'app_user'@'localhost';
-- GRANT EXECUTE ON PROCEDURE it_service_desk.sp_get_dashboard_stats TO 'app_user'@'localhost';

-- =====================================================
-- END OF SCHEMA
-- =====================================================
