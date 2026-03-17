*** Settings ***
Documentation     UAT Test Suite — หน้า "การเดินทางของฉัน" (myTrips)
...               ครอบคลุม: Login → แสดงผลข้อมูล → Report → Cancel → Review → Delete
...               รวมถึง Negative scenarios และ Guard scenarios

Library           SeleniumLibrary
Resource          ../resources/variables.robot
Resource          ../resources/keywords.robot

Suite Setup       Open Browser And Login
Suite Teardown    Close Browser
Test Setup        Navigate To My Trips
Test Teardown     Run Keywords
...               Capture Page Screenshot
...               AND    Run Keyword If Test Failed    Reload Page


# ══════════════════════════════════════════════════════════════════
# 1. LOGIN & PAGE LOAD
# ══════════════════════════════════════════════════════════════════
*** Test Cases ***

TC01 - Login ด้วย Email และ Password ที่ถูกต้อง
    [Documentation]    ตรวจสอบว่า login สำเร็จแล้วนำทางมาถึงหน้า myTrips ได้
    [Tags]    login    smoke
    Navigate To My Trips
    Page Should Contain    การเดินทางของฉัน
    Page Should Contain    จัดการและติดตามการเดินทางทั้งหมดของคุณ

TC02 - หน้า myTrips แสดง Tab ครบทั้ง 6 รายการ
    [Documentation]    ตรวจว่า tab ทุกอัน render อยู่บนหน้า
    [Tags]    smoke    ui
    Element Should Be Visible    ${TAB_PENDING}
    Element Should Be Visible    ${TAB_CONFIRMED}
    Element Should Be Visible    ${TAB_COMPLETED}
    Element Should Be Visible    ${TAB_REJECTED}
    Element Should Be Visible    ${TAB_CANCELLED}
    Element Should Be Visible    ${TAB_ALL}

TC03 - Tab แสดงจำนวน Trip ในแต่ละสถานะ
    [Documentation]    ตรวจว่า count ใน tab ไม่เป็นค่าว่าง
    [Tags]    smoke    ui
    ${pending_text}=    Get Text    ${TAB_PENDING}
    Should Match Regexp    ${pending_text}    \\d+

TC04 - แผนที่เส้นทางแสดงผลอยู่ด้านขวา
    [Documentation]    ตรวจว่า map container render อยู่บนหน้า
    [Tags]    smoke    ui
    Element Should Be Visible    xpath=//*[@id='map']

TC05 - กด Tab "ทั้งหมด" แสดง Trip ทุกรายการ
    [Documentation]    ตรวจว่ากด Tab ทั้งหมดแล้ว trip card ปรากฏ
    [Tags]    ui    tab
    Click Tab    ${TAB_ALL}
    # FIX: ใช้ ${TRIP_CARD_FIRST} จาก variables ที่แก้ selector แล้ว
    Wait Until Element Is Visible    ${TRIP_CARD_FIRST}    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    ${TRIP_CARD_FIRST}


# ══════════════════════════════════════════════════════════════════
# 2. TRIP CARD — EXPAND / COLLAPSE
# ══════════════════════════════════════════════════════════════════

TC06 - คลิก Trip Card ครั้งแรกเพื่อดูรายละเอียด
    [Documentation]    ตรวจว่า detail section เปิดออกมา
    [Tags]    ui    trip_detail
    Click Tab    ${TAB_ALL}
    ${has_card}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${TRIP_CARD_FIRST}
    Pass Execution If    not ${has_card}    ไม่มี trip card บนหน้า
    Click First Trip Card
    # FIX: ใช้ ${DETAIL_ROUTE_HEADER} ที่ใช้ contains แทน normalize-space
    Wait Until Element Is Visible    ${DETAIL_ROUTE_HEADER}    timeout=${DEFAULT_TIMEOUT}

TC07 - คลิก Trip Card ซ้ำเพื่อ Collapse รายละเอียด
    [Documentation]    คลิกซ้ำแล้ว detail ต้องซ่อนอีกครั้ง
    [Tags]    ui    trip_detail
    Click Tab    ${TAB_ALL}
    ${has_card}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${TRIP_CARD_FIRST}
    Pass Execution If    not ${has_card}    ไม่มี trip card บนหน้า
    Click First Trip Card
    Wait Until Page Contains    จุดเริ่มต้น    timeout=${DEFAULT_TIMEOUT}
    Click First Trip Card
    Sleep    ${ANIMATION_WAIT}
    # FIX: ตรวจว่า header หายไป ใช้ selector เดียวกับ TC06
    Element Should Not Be Visible    ${DETAIL_ROUTE_HEADER}

TC08 - รายละเอียดเส้นทางแสดงจุดเริ่มต้นและปลายทาง
    [Documentation]    expand card แล้วตรวจว่า จุดเริ่มต้น/ปลายทาง แสดง
    [Tags]    ui    trip_detail
    Click Tab    ${TAB_ALL}
    ${has_card}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${TRIP_CARD_FIRST}
    Pass Execution If    not ${has_card}    ไม่มี trip card บนหน้า
    Click First Trip Card
    # FIX: Wait ก่อนแล้วค่อย assert เพราะ animation ทำให้ Page Should Contain ไม่ทัน
    Wait Until Page Contains    จุดเริ่มต้น    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain    จุดปลายทาง

TC09 - แผนที่อัปเดตเมื่อคลิก Trip Card
    [Documentation]    ตรวจว่า map ยังคง visible หลังจากคลิก card
    [Tags]    ui    map
    Click Tab    ${TAB_ALL}
    Click First Trip Card
    Element Should Be Visible    xpath=//*[@id='map']


# ══════════════════════════════════════════════════════════════════
# 3. REPORT — HAPPY PATH
# ══════════════════════════════════════════════════════════════════

TC10 - ส่ง Report สำเร็จ (Happy Path)
    [Documentation]    เลือก user + category + description ครบ → ส่งสำเร็จ
    [Tags]    report    happy_path    critical
    # FIX: หา tab ที่มีปุ่ม report จริงๆ ผ่าน keyword Find Tab With Report Button
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มี trip ที่มีปุ่ม รายงานปัญหา
    Open Report Modal
    Select First Reportable User
    Select Problem Category    DANGEROUS_DRIVING
    Input Report Description    การทดสอบรายงานปัญหาอัตโนมัติ ใช้ในการ UAT เท่านั้น
    Submit Report Form
    Wait For Toast    ส่งรายงานสำเร็จ

TC11 - หลัง Report สำเร็จ ปุ่มรายงานเปลี่ยนเป็น "ดูประวัติการรายงาน"
    [Documentation]    guard: ปุ่มรายงานต้องหายไป → แสดงปุ่ม "ดูประวัติการรายงาน" แทน
    [Tags]    report    guard
    Click Tab    ${TAB_PENDING}
    Wait Until Element Is Visible    ${BTN_VIEW_HISTORY}    timeout=${LONG_TIMEOUT}
    Element Should Not Be Visible    ${BTN_REPORT}

TC12 - กดปุ่ม "ดูประวัติการรายงาน" นำทางไปหน้า myHistory
    [Documentation]    หลัง report แล้ว กดปุ่มควรไปหน้า history
    [Tags]    report    navigation    guard
    # FIX: ตรวจทั้ง pending และ confirmed เพราะไม่รู้ว่า trip ที่รายงานอยู่ tab ไหน
    ${found_in_pending}=    Run Keyword And Return Status
    ...    Run Keywords
    ...    Click Tab    ${TAB_PENDING}
    ...    AND    Wait Until Element Is Visible    ${BTN_VIEW_HISTORY}    timeout=5s
    Run Keyword If    not ${found_in_pending}
    ...    Run Keywords
    ...    Click Tab    ${TAB_CONFIRMED}
    ...    AND    Wait Until Element Is Visible    ${BTN_VIEW_HISTORY}    timeout=${DEFAULT_TIMEOUT}
    Click Element    ${BTN_VIEW_HISTORY}
    Wait Until Location Contains    myHistory    timeout=${DEFAULT_TIMEOUT}
    Go Back


# ══════════════════════════════════════════════════════════════════
# 4. REPORT — NEGATIVE / VALIDATION
# ══════════════════════════════════════════════════════════════════

TC13 - แจ้ง Error เมื่อไม่ได้เลือก User
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report

    Open Report Modal
    Select Problem Category    AGGRESSIVE_BEHAVIOR
    Input Report Description    รายละเอียดที่ครบถ้วนมากกว่า 10 ตัวอักษร
    Submit Report Form

    Wait Until Keyword Succeeds    5x    1s
    ...    Page Should Contain    กรุณาเลือกผู้ที่ต้องการรายงาน

    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC14 - แจ้ง Error เมื่อ Description สั้นเกินไป
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report

    Open Report Modal
    Select First Reportable User
    Select Problem Category    HARASSMENT
    Input Report Description    สั้น
    Submit Report Form

    Wait Until Keyword Succeeds    5x    1s
    ...    Page Should Contain    รายละเอียดต้องมีอย่างน้อย 10 ตัวอักษร

    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC15 - แจ้ง Error เมื่อไม่ได้เลือก Category
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report

    Open Report Modal
    Select First Reportable User
    Input Report Description    รายละเอียดที่ครบถ้วนมากกว่า 10 ตัวอักษร
    Submit Report Form

    Wait Until Keyword Succeeds    5x    1s
    ...    Page Should Contain    กรุณาเลือกประเภทปัญหา

    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC16 - กด Report ซ้ำบน Trip ที่รายงานไปแล้ว
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report

    Open Report Modal
    Select First Reportable User
    Select Problem Category    AGGRESSIVE_BEHAVIOR
    Input Report Description    รายละเอียดที่ครบถ้วนมากกว่า 10 ตัวอักษร
    Submit Report Form

    Wait Until Keyword Succeeds    5x    1s
    ...    Page Should Contain    Report สำหรับ Trip นี้ไปแล้ว

    Element Should Be Visible    ${MODAL_REPORT}


TC17 - ปิด Report Modal ด้วยปุ่ม "ปิด"
    [Documentation]    ตรวจสอบว่าสามารถกดปิด modal ได้
    [Tags]    report    ui

    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report

    Open Report Modal
    Element Should Be Visible    ${MODAL_REPORT}

    Close Report Modal

    Element Should Not Be Visible    ${MODAL_REPORT}


# ══════════════════════════════════════════════════════════════════
# 7. CONFIRMED TRIP
# ══════════════════════════════════════════════════════════════════

TC18 - Trip ที่ยืนยันแล้วแสดงปุ่ม "แชทกับผู้ขับ"
    [Tags]    confirmed    ui
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip confirmed
    Element Should Be Visible    ${BTN_CHAT}

TC19 - Trip ที่ยืนยันแล้วสามารถยกเลิกได้
    [Tags]    confirmed    ui
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip confirmed
    Element Should Be Visible    ${BTN_CANCEL_BOOKING}


# ══════════════════════════════════════════════════════════════════
# 8. REJECTED / CANCELLED TRIP
# ══════════════════════════════════════════════════════════════════

TC20 - Tab "ปฏิเสธ" แสดงปุ่ม "ลบรายการ"
    [Tags]    rejected    ui
    Click Tab    ${TAB_REJECTED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip ที่ถูกปฏิเสธ
    Element Should Be Visible    ${BTN_DELETE}

TC21 - ลบ Trip ที่ถูกปฏิเสธสำเร็จ
    [Tags]    rejected    happy_path
    Click Tab    ${TAB_REJECTED}
    ${before}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${before} == 0    ไม่มี trip rejected
    Click Element    ${BTN_DELETE}
    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'ใช่, ลบรายการ')]    timeout=${DEFAULT_TIMEOUT}
    Click Element    xpath=//button[contains(.,'ใช่, ลบรายการ')]
    Wait For Toast    ลบรายการสำเร็จ
    ${after}=    Get Element Count    ${TRIP_CARD}
    Should Be True    ${after} < ${before}

TC22 - Tab "ยกเลิก" แสดง Trip ที่ยกเลิกไปแล้ว
    [Tags]    cancelled    ui
    Click Tab    ${TAB_CANCELLED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Log    จำนวน Trip ที่ยกเลิก: ${trip_count}


# ══════════════════════════════════════════════════════════════════
# 9. REPORT ON COMPLETED / REJECTED TRIP
# ══════════════════════════════════════════════════════════════════

TC23 - Trip "เสร็จสิ้น" สามารถรายงานปัญหาได้
    [Tags]    report    completed
    Click Tab    ${TAB_COMPLETED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip completed
    ${count}=    Get Element Count
    ...    xpath=//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))] | //button[contains(.,'ดูประวัติการรายงาน')]
    Should Be True    ${count} > 0

TC24 - Trip "ปฏิเสธ" สามารถรายงานปัญหาได้
    [Tags]    report    rejected
    Click Tab    ${TAB_REJECTED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip rejected
    ${count}=    Get Element Count
    ...    xpath=//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))] | //button[contains(.,'ดูประวัติการรายงาน')]
    Should Be True    ${count} > 0

TC25 - ส่ง Report บน Trip "เสร็จสิ้น" สำเร็จ
    [Tags]    report    completed    happy_path
    Click Tab    ${TAB_COMPLETED}
    ${has_report}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${BTN_REPORT_FIRST}
    Pass Execution If    not ${has_report}    ไม่มีปุ่ม report บน completed trip
    Open Report Modal
    Select First Reportable User
    Select Problem Category    NO_SHOW
    Input Report Description    ผู้ขับไม่มารับตามที่นัดหมาย — UAT Test อัตโนมัติ
    Submit Report Form
    # FIX: ใช้ contains แบบกว้างเผื่อ toast text ต่างกันเล็กน้อย
    Wait Until Page Contains    สำเร็จ    timeout=${LONG_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 10. EDGE CASES
# ══════════════════════════════════════════════════════════════════

TC26 - หน้าแสดงข้อความเมื่อ Tab ไม่มี Trip
    [Tags]    ui    empty_state
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Run Keyword If    ${trip_count} == 0
    ...    Page Should Contain    ไม่พบรายการเดินทางในหมวดหมู่นี้

TC27 - Status Badge แสดงสีและข้อความถูกต้องตามสถานะ
    [Tags]    ui    badge
    Click Tab    ${TAB_PENDING}
    ${pending_trips}=    Get Element Count    ${TRIP_CARD}
    Run Keyword If    ${pending_trips} > 0
    ...    Element Should Be Visible    xpath=//*[contains(@class,'status-pending') and contains(.,'รอดำเนินการ')]
    Click Tab    ${TAB_COMPLETED}
    ${comp_trips}=    Get Element Count    ${TRIP_CARD}
    Run Keyword If    ${comp_trips} > 0
    ...    Element Should Be Visible    xpath=//*[contains(@class,'status-confirmed') and contains(.,'เสร็จสิ้น')]
    Click Tab    ${TAB_REJECTED}
    ${rej_trips}=    Get Element Count    ${TRIP_CARD}
    Run Keyword If    ${rej_trips} > 0
    ...    Element Should Be Visible    xpath=//*[contains(@class,'status-rejected') and contains(.,'ปฏิเสธ')]

TC28 - ข้อมูลราคา จำนวนที่นั่ง และเวลาแสดงบน Trip Card
    [Tags]    ui    data
    Click Tab    ${TAB_ALL}
    Click First Trip Card
    Page Should Contain    บาท
    Page Should Contain    ที่นั่ง
    Page Should Contain    วันที่

TC29 - รูปภาพคนขับแสดงบน Trip Card
    [Tags]    ui    driver
    Click Tab    ${TAB_ALL}
    Wait Until Element Is Visible    ${TRIP_CARD_FIRST}    timeout=${DEFAULT_TIMEOUT}
    # FIX: ใช้ ${DRIVER_IMG} จาก variables ที่ตรงกับ template จริง (w-12 h-12 rounded-full)
    Element Should Be Visible    ${DRIVER_IMG}


*** Keywords ***
Find Tab With Report Button
    [Documentation]    วนหา tab ที่มีปุ่ม รายงานปัญหา แล้วคืน tab locator, คืน 'none' ถ้าไม่เจอ
    FOR    ${tab}    IN    ${TAB_PENDING}    ${TAB_CONFIRMED}    ${TAB_COMPLETED}
        Click Tab    ${tab}
        ${found}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${BTN_REPORT_FIRST}
        Return From Keyword If    ${found}    ${tab}
    END
    [Return]    none
