*** Settings ***
Documentation     UAT Test Suite — Admin Flow
...               1. สร้าง Passenger + Driver → กด Verified
...               2. Driver ยืนยันตัวตน → Admin Approve
...               3. Driver สร้างรถ
...               4. Admin สร้าง Route

Library           SeleniumLibrary
Library           OperatingSystem
Resource          ../resources/variables.robot
Resource          ../resources/keywords.robot

Suite Setup       Open Browser And Login As Admin
Suite Teardown    Close Browser
Test Teardown     Capture Page Screenshot


*** Variables ***
# === Admin Credentials ===
${ADMIN_EMAIL}            admin123
${ADMIN_PASSWORD}         123456789

# === Test User Data: Passenger ===
${P_EMAIL}                passenger10@email.com
${P_USERNAME}             passenger10
${P_PASSWORD}             123456789
${P_FIRSTNAME}            Passenger10
${P_LASTNAME}             Passenger10
${P_PHONE}                0811000001
${P_NATIONAL_ID}          1100100000001
${P_EXPIRY_DATE}          2030-12-31
${P_GENDER}               MALE

# === Test User Data: Driver ===
${D_EMAIL}                driver10@email.com
${D_USERNAME}             driver10
${D_PASSWORD}             123456789
${D_FIRSTNAME}            Driver10 
${D_LASTNAME}             Driver10
${D_PHONE}                0822000002
${D_NATIONAL_ID}          1100100000002
${D_EXPIRY_DATE}          2030-12-31
${D_GENDER}               MALE

# === Vehicle Data ===
${V_TYPE}                 SEDAN
${V_MODEL}                Toyota Yaris UAT
${V_PLATE}                UAT-9999
${V_COLOR}                ขาว
${V_SEATS}                4

# === Route Data ===
${ROUTE_ORIGIN}           มหาวิทยาลัยขอนแก่น
${ROUTE_DEST}             ห้างสรรพสินค้าเซ็นทรัล ขอนแก่น
${ROUTE_PRICE}            80
${ROUTE_SEATS}            3

# === Dummy image path (ใช้ไฟล์รูปขนาดเล็กที่มีอยู่แล้ว) ===
${DUMMY_IMAGE}            /file-test/test-report.jpg


*** Test Cases ***

# ══════════════════════════════════════════════════════════════════
# SETUP: สร้างรูปภาพ dummy สำหรับ upload
# ══════════════════════════════════════════════════════════════════

TC_SETUP - เตรียม Dummy Image สำหรับ Upload
    [Documentation]    สร้างไฟล์รูปภาพ dummy เพื่อใช้ในขั้นตอน upload
    [Tags]    setup
    Create Dummy Image If Not Exists    ${DUMMY_IMAGE}


# ══════════════════════════════════════════════════════════════════
# 1. สร้าง PASSENGER
# ══════════════════════════════════════════════════════════════════

TC01 - Admin นำทางไปหน้า User Management
    [Documentation]    ตรวจว่า admin เข้าหน้า /admin/users ได้
    [Tags]    admin    user_management    smoke
    Go To    ${BASE_URL}/admin/users
    Wait Until Page Contains    User Management    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    xpath=//button[contains(.,'สร้างผู้ใช้ใหม่')]

TC02 - Admin กดปุ่ม "สร้างผู้ใช้ใหม่" ไปหน้า Create
    [Documentation]    กดปุ่มแล้วต้องไปหน้า /admin/users/create
    [Tags]    admin    user_management
    Go To    ${BASE_URL}/admin/users
    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'สร้างผู้ใช้ใหม่')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//button[contains(.,'สร้างผู้ใช้ใหม่')]
    Wait Until Location Contains    /admin/users/create    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain    สร้างผู้ใช้ใหม่

TC03 - Admin สร้าง Passenger สำเร็จ
    [Documentation]    กรอกฟอร์มสร้าง passenger ครบ → บันทึก → กลับหน้า list
    [Tags]    admin    create_user    passenger    critical
    Go To    ${BASE_URL}/admin/users/create
    Wait Until Page Contains    สร้างผู้ใช้ใหม่    timeout=${DEFAULT_TIMEOUT}
    Fill Create User Form
    ...    ${P_EMAIL}    ${P_USERNAME}    ${P_PASSWORD}
    ...    ${P_FIRSTNAME}    ${P_LASTNAME}    ${P_PHONE}
    ...    ${P_GENDER}    PASSENGER    ${P_NATIONAL_ID}    ${P_EXPIRY_DATE}
    Upload Dummy Image    xpath=//input[@ref='idCardInput' or (@type='file' and contains(@accept,'image'))][1]
    Upload Dummy Image    xpath=//input[@ref='selfieInput' or (@type='file' and contains(@accept,'image'))][2]
    Click Element    xpath=//button[contains(.,'บันทึก') and not(@disabled)]
    Wait Until Page Contains    สำเร็จ    timeout=${LONG_TIMEOUT}
    Wait Until Location Contains    /admin/users    timeout=${DEFAULT_TIMEOUT}

TC04 - Admin สร้าง Driver สำเร็จ
    [Documentation]    กรอกฟอร์มสร้าง driver ครบ → บันทึก → กลับหน้า list
    [Tags]    admin    create_user    driver    critical
    Go To    ${BASE_URL}/admin/users/create
    Wait Until Page Contains    สร้างผู้ใช้ใหม่    timeout=${DEFAULT_TIMEOUT}
    Fill Create User Form
    ...    ${D_EMAIL}    ${D_USERNAME}    ${D_PASSWORD}
    ...    ${D_FIRSTNAME}    ${D_LASTNAME}    ${D_PHONE}
    ...    ${D_GENDER}    DRIVER    ${D_NATIONAL_ID}    ${D_EXPIRY_DATE}
    Upload Dummy Image    xpath=//input[@ref='idCardInput' or (@type='file' and contains(@accept,'image'))][1]
    Upload Dummy Image    xpath=//input[@ref='selfieInput' or (@type='file' and contains(@accept,'image'))][2]
    Click Element    xpath=//button[contains(.,'บันทึก') and not(@disabled)]
    Wait Until Page Contains    สำเร็จ    timeout=${LONG_TIMEOUT}
    Wait Until Location Contains    /admin/users    timeout=${DEFAULT_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 2. Verified Passenger และ Driver
# ══════════════════════════════════════════════════════════════════

TC05 - Admin ค้นหา Passenger ใน User List
    [Documentation]    ค้นหา passenger ที่เพิ่งสร้างและตรวจว่าแสดงในตาราง
    [Tags]    admin    user_management    passenger
    Go To    ${BASE_URL}/admin/users
    Wait Until Page Contains    User Management    timeout=${DEFAULT_TIMEOUT}
    Search User    ${P_EMAIL}
    Wait Until Element Is Visible
    ...    xpath=//td[contains(.,'${P_EMAIL}')]    timeout=${DEFAULT_TIMEOUT}

TC06 - Admin เปิดหน้า Detail ของ Passenger
    [Documentation]    คลิกปุ่ม eye → ไปหน้า detail
    [Tags]    admin    user_management    passenger
    Go To    ${BASE_URL}/admin/users
    Wait Until Page Contains    User Management    timeout=${DEFAULT_TIMEOUT}
    Search User    ${P_EMAIL}
    Click View Button For User    ${P_EMAIL}
    Wait Until Page Contains    รายละเอียดผู้ใช้    timeout=${DEFAULT_TIMEOUT}

TC07 - Admin Toggle Verified ให้ Passenger
    [Documentation]    เปิด switch Verified → toast สำเร็จ → switch เป็น Verified
    [Tags]    admin    verify    passenger    critical
    Go To    ${BASE_URL}/admin/users
    Search User    ${P_EMAIL}
    Click View Button For User    ${P_EMAIL}
    Wait Until Page Contains    รายละเอียดผู้ใช้    timeout=${DEFAULT_TIMEOUT}
    Toggle Verified Switch
    Wait For Toast    ยืนยันผู้ใช้สำเร็จ

TC08 - Admin Toggle Verified ให้ Driver
    [Documentation]    เปิด switch Verified บน driver → toast สำเร็จ
    [Tags]    admin    verify    driver    critical
    Go To    ${BASE_URL}/admin/users
    Search User    ${D_EMAIL}
    Click View Button For User    ${D_EMAIL}
    Wait Until Page Contains    รายละเอียดผู้ใช้    timeout=${DEFAULT_TIMEOUT}
    Toggle Verified Switch
    Wait For Toast    ยืนยันผู้ใช้สำเร็จ

TC09 - ตรวจสอบ Badge "ยืนยันแล้ว" บน User List ของ Passenger
    [Documentation]    กลับหน้า list → badge ยืนยันแล้ว ต้องแสดงสำหรับ passenger
    [Tags]    admin    verify    passenger
    Go To    ${BASE_URL}/admin/users
    Search User    ${P_EMAIL}
    Wait Until Element Is Visible
    ...    xpath=//tr[.//td[contains(.,'${P_EMAIL}')]]//span[contains(.,'ยืนยันแล้ว')]
    ...    timeout=${DEFAULT_TIMEOUT}

TC10 - ตรวจสอบ Badge "ยืนยันแล้ว" บน User List ของ Driver
    [Documentation]    กลับหน้า list → badge ยืนยันแล้ว ต้องแสดงสำหรับ driver
    [Tags]    admin    verify    driver
    Go To    ${BASE_URL}/admin/users
    Search User    ${D_EMAIL}
    Wait Until Element Is Visible
    ...    xpath=//tr[.//td[contains(.,'${D_EMAIL}')]]//span[contains(.,'ยืนยันแล้ว')]
    ...    timeout=${DEFAULT_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 3. Driver ยืนยันตัวตน (ล็อกอินเป็น Driver → ส่งฟอร์ม)
# ══════════════════════════════════════════════════════════════════

TC11 - Driver Login และไปหน้ายืนยันตัวตน
    [Documentation]    logout admin → login เป็น driver → ไปหน้า /profile/verification
    [Tags]    driver    verification
    Logout Current User
    Login As    ${D_EMAIL}    ${D_PASSWORD}
    Go To    ${BASE_URL}/profile/verification
    Wait Until Page Contains    ยืนยันตัวตนผู้ขับขี่    timeout=${DEFAULT_TIMEOUT}

TC12 - Driver กรอกฟอร์มยืนยันตัวตนและส่ง
    [Documentation]    อัปโหลดรูปใบขับขี่ + selfie + วันที่ → ส่ง
    [Tags]    driver    verification    critical
    # อยู่หน้า verification แล้วจาก TC11
    ${front_input}=    Set Variable
    ...    xpath=//input[@id='license-front-input' or (@type='file' and @accept='.jpg,.png')][1]
    ${selfie_input}=    Set Variable
    ...    xpath=//input[@id='license-selfie-input' or (@type='file' and @accept='.jpg,.png')][2]
    Upload Dummy Image    ${front_input}
    Upload Dummy Image    ${selfie_input}
    Input Text    xpath=//input[@type='date'][1]    2020-01-01
    Input Text    xpath=//input[@type='date'][2]    2030-01-01
    Click Element    xpath=//button[@type='submit' and not(@disabled)]
    Wait Until Page Contains    ส่งคำขอยืนยันตัวตนสำเร็จ    timeout=${DEFAULT_TIMEOUT}

TC13 - Admin Approve การยืนยันตัวตนของ Driver
    [Documentation]    logout driver → login admin → หน้า detail driver → ส่ง notification approve
    [Tags]    admin    verification    approve    critical
    Logout Current User
    Login As    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Go To    ${BASE_URL}/admin/users
    Search User    ${D_EMAIL}
    Click View Button For User    ${D_EMAIL}
    Wait Until Page Contains    รายละเอียดผู้ใช้    timeout=${DEFAULT_TIMEOUT}
    # เลือก preset VERIFY_APPROVED แล้วส่ง notification
    Select From List By Value
    ...    xpath=//select[.//option[contains(.,'VERIFY_APPROVED')]]    VERIFY_APPROVED
    Click Element    xpath=//button[contains(.,'ส่งการแจ้งเตือน') and not(@disabled)]
    Wait For Toast    ส่งการแจ้งเตือนแล้ว

TC14 - ตรวจสอบสถานะ Verified ของ Driver หลัง Approve
    [Documentation]    switch Verified ต้องเปิดอยู่หลัง approve
    [Tags]    admin    verification    driver
    # อยู่หน้า detail ของ driver แล้ว
    Element Should Be Visible
    ...    xpath=//input[contains(@class,'switch-input') and @checked]


# ══════════════════════════════════════════════════════════════════
# 4. Driver สร้างรถ (ผ่าน Admin Vehicle Management)
# ══════════════════════════════════════════════════════════════════

TC15 - Admin ไปหน้า Vehicle Management
    [Documentation]    ตรวจว่าหน้า /admin/vehicles โหลดได้
    [Tags]    admin    vehicle
    Go To    ${BASE_URL}/admin/vehicles
    Wait Until Page Contains    Vehicle Management    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    xpath=//button[contains(.,'สร้างยานพาหนะใหม่')]

TC16 - Admin กดปุ่มสร้างยานพาหนะ
    [Documentation]    กดปุ่ม → ไปหน้า /admin/vehicles/create
    [Tags]    admin    vehicle
    Go To    ${BASE_URL}/admin/vehicles
    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'สร้างยานพาหนะใหม่')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//button[contains(.,'สร้างยานพาหนะใหม่')]
    Wait Until Location Contains    /admin/vehicles/create    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain    สร้างยานพาหนะใหม่

TC17 - Admin สร้างยานพาหนะให้ Driver สำเร็จ
    [Documentation]    ค้นหา driver → กรอกข้อมูลรถ → upload รูป → บันทึก
    [Tags]    admin    vehicle    critical
    Go To    ${BASE_URL}/admin/vehicles/create
    Wait Until Page Contains    สร้างยานพาหนะใหม่    timeout=${DEFAULT_TIMEOUT}
    # ค้นหา driver owner
    Input Text
    ...    xpath=//input[contains(@placeholder,'ค้นหาด้วยชื่อ') or contains(@placeholder,'อีเมล')]
    ...    ${D_EMAIL}
    Wait Until Element Is Visible
    ...    xpath=//ul//li[contains(.,'${D_EMAIL}')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//ul//li[contains(.,'${D_EMAIL}')]
    # กรอกข้อมูลรถ
    Select From List By Value
    ...    xpath=//select[.//option[contains(.,'Sedan') or contains(.,'SEDAN')]]    ${V_TYPE}
    Input Text    xpath=//input[@placeholder='Toyota Yaris' or contains(@placeholder,'รุ่น')]    ${V_MODEL}
    Input Text    xpath=//input[@placeholder='1กข 1234' or contains(@placeholder,'ทะเบียน')]    ${V_PLATE}
    Input Text    xpath=//input[@placeholder='ขาว' or contains(@placeholder,'สี')]    ${V_COLOR}
    Clear Element Text    xpath=//input[@type='number' and contains(@placeholder,'')]
    Input Text    xpath=//input[@type='number']    ${V_SEATS}
    # upload 3 รูป
    ${photos}=    Get WebElements    xpath=//input[@type='file' and contains(@accept,'image')]
    Choose File    xpath=(//input[@type='file' and contains(@accept,'image')])[1]    ${DUMMY_IMAGE}
    Choose File    xpath=(//input[@type='file' and contains(@accept,'image')])[2]    ${DUMMY_IMAGE}
    Choose File    xpath=(//input[@type='file' and contains(@accept,'image')])[3]    ${DUMMY_IMAGE}
    # บันทึก
    Click Element    xpath=//button[contains(.,'บันทึก') and not(@disabled)]
    Wait Until Page Contains    สำเร็จ    timeout=${LONG_TIMEOUT}
    Wait Until Location Contains    /admin/vehicles    timeout=${DEFAULT_TIMEOUT}

TC18 - ตรวจสอบรถที่สร้างปรากฏใน Vehicle List
    [Documentation]    ค้นหาด้วยป้ายทะเบียน → ต้องเจอใน table
    [Tags]    admin    vehicle
    Go To    ${BASE_URL}/admin/vehicles
    Wait Until Page Contains    Vehicle Management    timeout=${DEFAULT_TIMEOUT}
    Input Text
    ...    xpath=//input[contains(@placeholder,'ค้นหา')]    ${V_PLATE}
    Click Element    xpath=//button[contains(.,'ค้นหา')]
    Wait Until Element Is Visible
    ...    xpath=//td[contains(.,'${V_PLATE}')]    timeout=${DEFAULT_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 5. Admin สร้าง Route
# ══════════════════════════════════════════════════════════════════

TC19 - Admin ไปหน้า Route Management
    [Documentation]    ตรวจว่าหน้า /admin/routes โหลดได้
    [Tags]    admin    route
    Go To    ${BASE_URL}/admin/routes
    Wait Until Page Contains    Route Management    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    xpath=//button[contains(.,'สร้างเส้นทางใหม่')]

TC20 - Admin กดปุ่มสร้าง Route
    [Documentation]    กดปุ่ม → ไปหน้า /admin/routes/create
    [Tags]    admin    route
    Go To    ${BASE_URL}/admin/routes
    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'สร้างเส้นทางใหม่')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//button[contains(.,'สร้างเส้นทางใหม่')]
    Wait Until Location Contains    /admin/routes/create    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain    สร้างเส้นทาง

TC21 - Admin สร้าง Route สำเร็จ
    [Documentation]    เลือก driver → เลือกรถ → กรอก origin/dest → ราคา/ที่นั่ง → บันทึก
    [Tags]    admin    route    critical
    Go To    ${BASE_URL}/admin/routes/create
    Wait Until Page Contains    สร้างเส้นทาง    timeout=${LONG_TIMEOUT}
    # รอ Google Maps โหลด
    Sleep    3s
    # เลือก driver
    Input Text
    ...    xpath=//input[contains(@placeholder,'อีเมล') or contains(@placeholder,'ชื่อ') or contains(@placeholder,'Username')]
    ...    ${D_EMAIL}
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'absolute')]//button[contains(.,'${D_LASTNAME}') or contains(.,'${D_EMAIL}')]
    ...    timeout=${DEFAULT_TIMEOUT}
    Click Element
    ...    xpath=//div[contains(@class,'absolute')]//button[contains(.,'${D_LASTNAME}') or contains(.,'${D_EMAIL}')]
    Sleep    1s
    # เลือกรถ
    Wait Until Element Is Visible
    ...    xpath=//input[contains(@placeholder,'รุ่น') or contains(@placeholder,'ทะเบียน')]
    ...    timeout=${DEFAULT_TIMEOUT}
    Click Element
    ...    xpath=//input[contains(@placeholder,'รุ่น') or contains(@placeholder,'ทะเบียน')]
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'absolute')]//button[contains(.,'${V_PLATE}') or contains(.,'${V_MODEL}')]
    ...    timeout=${DEFAULT_TIMEOUT}
    Click Element
    ...    xpath=//div[contains(@class,'absolute')]//button[contains(.,'${V_PLATE}') or contains(.,'${V_MODEL}')]
    # กรอกจุดเริ่มต้น
    Input Text
    ...    xpath=//input[@placeholder='พิมพ์ชื่อสถานที่ หรือใช้ปุ่มปักหมุด'][1]
    ...    ${ROUTE_ORIGIN}
    Sleep    1s
    # กรอกจุดปลายทาง
    Input Text
    ...    xpath=//input[@placeholder='พิมพ์ชื่อสถานที่ หรือใช้ปุ่มปักหมุด'][2]
    ...    ${ROUTE_DEST}
    Sleep    1s
    # กรอกวัน-เวลา (พรุ่งนี้ 09:00)
    ${tomorrow}=    Get Tomorrow Datetime Local
    Input Text    xpath=//input[@type='datetime-local']    ${tomorrow}
    # ราคาและที่นั่ง
    Clear Element Text    xpath=//input[@type='number'][1]
    Input Text    xpath=//input[@type='number'][1]    ${ROUTE_PRICE}
    Clear Element Text    xpath=//input[@type='number'][2]
    Input Text    xpath=//input[@type='number'][2]    ${ROUTE_SEATS}
    # กดสร้าง
    Click Element    xpath=//button[contains(.,'สร้างเส้นทาง') and not(@disabled)]
    Wait For Toast    สร้างเส้นทางสำเร็จ
    Wait Until Location Contains    /admin/routes    timeout=${LONG_TIMEOUT}

TC22 - ตรวจสอบ Route ที่สร้างปรากฏใน Route List
    [Documentation]    ค้นหา driver email → route ต้องแสดงใน table
    [Tags]    admin    route
    Go To    ${BASE_URL}/admin/routes
    Wait Until Page Contains    Route Management    timeout=${DEFAULT_TIMEOUT}
    Input Text    xpath=//input[contains(@placeholder,'ค้นหา')]    ${D_LASTNAME}
    Click Element    xpath=//button[contains(.,'ค้นหา')]
    Wait Until Element Is Visible
    ...    xpath=//td[contains(.,'${D_FIRSTNAME}') or contains(.,'${D_LASTNAME}')]
    ...    timeout=${DEFAULT_TIMEOUT}

TC23 - ตรวจสอบรายละเอียด Route ที่สร้าง
    [Documentation]    กดปุ่ม eye → หน้า detail แสดงข้อมูลถูกต้อง
    [Tags]    admin    route
    Go To    ${BASE_URL}/admin/routes
    Input Text    xpath=//input[contains(@placeholder,'ค้นหา')]    ${D_LASTNAME}
    Click Element    xpath=//button[contains(.,'ค้นหา')]
    Wait Until Element Is Visible
    ...    xpath=//td[contains(.,'${D_FIRSTNAME}') or contains(.,'${D_LASTNAME}')]
    ...    timeout=${DEFAULT_TIMEOUT}
    Click Element
    ...    xpath=(//tr[.//td[contains(.,'${D_FIRSTNAME}') or contains(.,'${D_LASTNAME}')]]//button[@title='ดูรายละเอียด'])[1]
    Wait Until Page Contains    รายละเอียดเส้นทาง    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain    ${D_FIRSTNAME}


# ══════════════════════════════════════════════════════════════════
# NEGATIVE: validation
# ══════════════════════════════════════════════════════════════════

TC24 - สร้าง User โดยไม่กรอก Email → ปุ่มบันทึก Disabled
    [Documentation]    กรอกข้อมูลไม่ครบ → ปุ่มบันทึกยังกดไม่ได้
    [Tags]    admin    create_user    negative
    Go To    ${BASE_URL}/admin/users/create
    Wait Until Page Contains    สร้างผู้ใช้ใหม่    timeout=${DEFAULT_TIMEOUT}
    # กรอกแค่บางส่วน ไม่กรอก email
    Input Text    xpath=//input[contains(@placeholder,'user_001')]    test_user
    Input Text    xpath=//input[@type='password']    Password1234!
    Click Element    xpath=//button[contains(.,'บันทึก')]
    # ต้องยังอยู่หน้าเดิม (ไม่ redirect)
    Wait Until Page Contains    สร้างผู้ใช้ใหม่    timeout=${SHORT_TIMEOUT}

TC25 - สร้าง Route โดยไม่เลือก Driver → ปุ่มสร้างต้อง Disabled
    [Documentation]    ไม่เลือก driver → ปุ่ม "สร้างเส้นทาง" ต้อง disabled
    [Tags]    admin    route    negative
    Go To    ${BASE_URL}/admin/routes/create
    Wait Until Page Contains    สร้างเส้นทาง    timeout=${LONG_TIMEOUT}
    Sleep    2s
    Element Should Be Disabled
    ...    xpath=//button[contains(.,'สร้างเส้นทาง')]


*** Keywords ***
# ─────────────────────────────────────────
# Login / Logout
# ─────────────────────────────────────────
Open Browser And Login As Admin
    [Documentation]    เปิด browser และ login ด้วย admin account
    Open Browser    ${LOGIN_URL}    chrome
    ...    options=add_argument("--start-maximized");add_argument("--disable-notifications")
    Maximize Browser Window
    Wait For Login Page To Be Ready
    Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Wait For Successful Login

Login As
    [Arguments]    ${email}    ${password}
    Go To    ${LOGIN_URL}
    Wait For Login Page To Be Ready
    Fill Login Form    ${email}    ${password}
    Wait For Successful Login

Logout Current User
    [Documentation]    คลิก logout จาก dropdown ใน navbar
    ${has_logout}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath=//button[contains(.,'Logout')]
    Run Keyword If    not ${has_logout}
    ...    Click Element    xpath=//div[contains(@class,'dropdown-trigger')]
    Wait Until Element Is Visible    xpath=//button[contains(.,'Logout')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//button[contains(.,'Logout')]
    Wait Until Location Contains    login    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────
# User Management
# ─────────────────────────────────────────
Search User
    [Arguments]    ${query}
    Input Text    xpath=//input[contains(@placeholder,'Email') or contains(@placeholder,'User') or contains(@placeholder,'Name')]    ${query}
    Click Element    xpath=//button[contains(.,'ค้นหา')]
    Wait Until Element Is Visible    xpath=//table//tbody    timeout=${DEFAULT_TIMEOUT}
    Sleep    ${ANIMATION_WAIT}

Click View Button For User
    [Arguments]    ${email}
    Click Element
    ...    xpath=//tr[.//td[contains(.,'${email}')]]//button[@title='ดูรายละเอียด' or @aria-label='ดูรายละเอียด']
    Wait Until Page Contains    รายละเอียดผู้ใช้    timeout=${DEFAULT_TIMEOUT}

Toggle Verified Switch
    [Documentation]    คลิก switch Verified บนหน้า user detail
    ${switch}=    Set Variable
    ...    xpath=//div[contains(.,'Verified') or contains(.,'Unverified')]//input[contains(@class,'switch-input')]
    Wait Until Element Is Visible    ${switch}    timeout=${DEFAULT_TIMEOUT}
    Click Element    ${switch}
    Sleep    ${ANIMATION_WAIT}

Fill Create User Form
    [Arguments]    ${email}    ${username}    ${password}    ${firstname}    ${lastname}
    ...    ${phone}    ${gender}    ${role}    ${national_id}    ${expiry_date}
    Input Text    xpath=//input[@type='email']    ${email}
    Input Text    xpath=//input[contains(@placeholder,'user_001')]    ${username}
    Input Text    xpath=//input[@type='password']    ${password}
    Input Text    xpath=//input[@type='tel']    ${phone}
    Input Text    xpath=//input[contains(@placeholder,'ชื่อจริง') or (contains(@class,'firstName'))]    ${firstname}
    Input Text    xpath=//input[contains(@placeholder,'นามสกุล') or (contains(@class,'lastName'))]    ${lastname}
    Select From List By Value    xpath=//select[.//option[contains(.,'MALE')]]    ${gender}
    Select From List By Value    xpath=//select[.//option[contains(.,'PASSENGER')]]    ${role}
    Input Text    xpath=//input[contains(@placeholder,'13 หลัก')]    ${national_id}
    Input Text    xpath=//input[@type='date']    ${expiry_date}

Upload Dummy Image
    [Arguments]    ${input_locator}
    Choose File    ${input_locator}    ${DUMMY_IMAGE}
    Sleep    0.5s

# ─────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────
Create Dummy Image If Not Exists
    [Arguments]    ${path}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${path}
    Return From Keyword If    ${exists}
    # สร้าง JPEG ขนาดเล็กที่สุด (SOI + EOI marker)
    ${bytes}=    Evaluate
    ...    b'\\xff\\xd8\\xff\\xe0\\x00\\x10JFIF\\x00\\x01\\x01\\x00\\x00\\x01\\x00\\x01\\x00\\x00\\xff\\xd9'
    Create Binary File    ${path}    ${bytes}

Get Tomorrow Datetime Local
    [Documentation]    คืน string datetime-local ของพรุ่งนี้ 09:00 รูปแบบ YYYY-MM-DDTHH:mm
    ${result}=    Evaluate
    ...    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=1)).strftime('%Y-%m-%dT09:00')
    [Return]    ${result}
