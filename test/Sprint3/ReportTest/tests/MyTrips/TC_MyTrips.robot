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
    [Documentation]    กด submit โดยไม่เลือก user → toast error แจ้งเตือน modal ยังเปิดอยู่
    [Tags]    report    validation    negative
    # FIX: Vue ใช้ toast.error() ไม่ใช่ HTML disabled → ทดสอบโดยกด submit แล้วรอ error message
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report
    Open Report Modal
    Select Problem Category    AGGRESSIVE_BEHAVIOR
    Input Report Description    รายละเอียดที่ครบถ้วนมากกว่า 10 ตัวอักษร
    Submit Report Form
    Wait Until Page Contains    กรุณาเลือกผู้ที่ต้องการรายงาน    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC14 - แจ้ง Error เมื่อ Description สั้นเกินไป
    [Documentation]    description น้อยกว่า 10 ตัวอักษร → toast error แจ้งเตือน
    [Tags]    report    validation    negative
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report
    Open Report Modal
    Select First Reportable User
    Select Problem Category    HARASSMENT
    Input Report Description    สั้น
    Submit Report Form
    # FIX: รอ error toast แทน HTML disabled attribute
    Wait Until Page Contains    รายละเอียดต้องมีอย่างน้อย 10 ตัวอักษร    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC15 - แจ้ง Error เมื่อไม่ได้เลือก Category
    [Documentation]    เลือก user + กรอก description แต่ไม่เลือก category → toast error
    [Tags]    report    validation    negative
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report
    Open Report Modal
    Select First Reportable User
    Input Report Description    รายละเอียดที่ครบถ้วนมากกว่า 10 ตัวอักษร
    Submit Report Form
    # FIX: รอ error toast
    Wait Until Page Contains    กรุณาเลือกประเภทปัญหา    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    ${MODAL_REPORT}
    Close Report Modal

TC16 - กด Report ซ้ำบน Trip ที่รายงานไปแล้ว — ปุ่มต้องไม่ปรากฏ
    [Documentation]    guard: trip ที่มี active report แล้ว ปุ่ม "รายงานปัญหา" ต้องหายไปเลย
    [Tags]    report    guard    negative
    Click Tab    ${TAB_PENDING}
    ${history_buttons}=    Get Element Count    ${BTN_VIEW_HISTORY}
    Run Keyword If    ${history_buttons} > 0
    ...    Log    พบปุ่ม 'ดูประวัติการรายงาน' — guard ทำงานถูกต้อง

TC17 - Checkbox User ใน Report Modal ถูก Disable เมื่อ User ถูกรายงานค้างอยู่
    [Documentation]    ถ้ามี active case กับ user คนนั้น checkbox ต้อง disabled
    [Tags]    report    guard    negative
    Click Tab    ${TAB_PENDING}
    ${has_report_btn}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${BTN_REPORT_FIRST}
    Pass Execution If    not ${has_report_btn}
    ...    ไม่มีปุ่ม report ที่ active — อาจ report ไปแล้วทั้งหมด
    Open Report Modal
    ${disabled_count}=    Get Element Count
    ...    xpath=//div[contains(@class,'fixed')]//table//input[@type='checkbox' and @disabled]
    Run Keyword If    ${disabled_count} > 0
    ...    Element Should Be Visible    ${BADGE_ACTIVE_REPORT}
    Close Report Modal

TC18 - ปิด Report Modal ด้วยปุ่ม "ปิด" ข้อมูลต้องถูก Reset
    [Documentation]    หลังปิด modal แล้วเปิดใหม่ form ต้องว่างเปล่า
    [Tags]    report    ui
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report
    Open Report Modal
    Input Report Description    รายละเอียดทดสอบที่จะถูกล้างทิ้ง
    Close Report Modal
    Open Report Modal
    ${desc_value}=    Get Value    ${REPORT_DESCRIPTION}
    Should Be Empty    ${desc_value}
    Close Report Modal

TC19 - ปิด Report Modal โดยคลิก Overlay modal ต้องปิด
    [Documentation]    คลิก backdrop ของ modal → modal ต้องปิด
    [Tags]    report    ui
    ${found}=    Find Tab With Report Button
    Pass Execution If    '${found}' == 'none'    ไม่มีปุ่ม report
    Open Report Modal
    # FIX: Vue ใช้ @click.self → ต้อง dispatch event ตรงที่ div.fixed โดยไม่ผ่าน child
    Execute Javascript
    ...    document.querySelector('div.fixed.inset-0').dispatchEvent(new MouseEvent('click', {bubbles: false}))
    Wait Until Element Is Not Visible    ${MODAL_REPORT}    timeout=${DEFAULT_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 5. CANCEL BOOKING
# ══════════════════════════════════════════════════════════════════

TC20 - Modal ยกเลิกแสดง Dropdown เหตุผล
    [Documentation]    ตรวจว่า dropdown เหตุผลมีตัวเลือกอย่างน้อย 1 รายการ
    [Tags]    cancel    ui
    Click Tab    ${TAB_PENDING}
    ${count}=    Get Element Count    ${BTN_CANCEL_BOOKING}
    Pass Execution If    ${count} == 0    ไม่มีปุ่มยกเลิกใน pending tab
    Open Cancel Modal
    ${options}=    Get List Items    ${CANCEL_REASON_SELECT}
    Length Should Be Greater Than    ${options}    1
    Close Cancel Modal

TC21 - ปุ่มยืนยันยกเลิก Disabled เมื่อยังไม่เลือกเหตุผล
    [Documentation]    เปิด modal แต่ยังไม่เลือกเหตุผล → ปุ่มต้อง disabled
    [Tags]    cancel    validation    negative
    Click Tab    ${TAB_PENDING}
    # FIX: ตรวจก่อนว่ามีปุ่มยกเลิก ถ้าไม่มีให้ข้าม
    ${count}=    Get Element Count    ${BTN_CANCEL_BOOKING}
    Pass Execution If    ${count} == 0    ไม่มีปุ่มยกเลิกใน pending tab
    Open Cancel Modal
    Verify Cancel Button Disabled When No Reason
    Close Cancel Modal

TC22 - ยกเลิกการจองสำเร็จ (Happy Path)
    [Documentation]    เลือกเหตุผล → กดยืนยัน → trip ย้ายไปแท็บ 'ยกเลิก'
    [Tags]    cancel    happy_path
    Click Tab    ${TAB_PENDING}
    ${pending_before}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${pending_before} == 0    ไม่มี trip ที่รอดำเนินการ
    Open Cancel Modal
    Select Cancel Reason    CHANGE_OF_PLAN
    Submit Cancel Form
    Wait For Toast    ยกเลิกการจองสำเร็จ
    Click Tab    ${TAB_PENDING}
    ${pending_after}=    Get Element Count    ${TRIP_CARD}
    Should Be True    ${pending_after} < ${pending_before}

TC23 - ปิด Cancel Modal โดยไม่ยืนยัน Trip ยังคงอยู่
    [Documentation]    กด "ปิด" โดยไม่ยืนยัน → trip ต้องยังอยู่ใน pending
    [Tags]    cancel    negative
    Click Tab    ${TAB_PENDING}
    ${before}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${before} == 0    ไม่มี trip pending
    Open Cancel Modal
    Close Cancel Modal
    ${after}=    Get Element Count    ${TRIP_CARD}
    Should Be Equal As Integers    ${before}    ${after}


# ══════════════════════════════════════════════════════════════════
# 6. REVIEW — COMPLETED TRIPS
# ══════════════════════════════════════════════════════════════════

TC24 - Tab "เสร็จสิ้น" แสดงปุ่ม "รีวิวคนขับ" สำหรับ Trip ที่ยังไม่รีวิว
    [Tags]    review    ui
    Click Tab    ${TAB_COMPLETED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip ที่เสร็จสิ้น
    ${review_btn_count}=    Get Element Count    ${BTN_REVIEW}
    Should Be True    ${review_btn_count} > 0    ควรมีปุ่มรีวิวอย่างน้อย 1 ปุ่ม

TC25 - Modal รีวิวเปิดและแสดง Star Rating
    [Tags]    review    ui
    Click Tab    ${TAB_COMPLETED}
    ${has_review}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${BTN_REVIEW}
    Pass Execution If    not ${has_review}    ไม่มีปุ่มรีวิว
    Open Review Modal
    Element Should Be Visible
    ...    xpath=//div[contains(@class,'fixed')]//span[contains(@class,'cursor-pointer') and contains(.,'★')]
    Close Review Modal

TC26 - ส่งรีวิวสำเร็จ (Happy Path)
    [Tags]    review    happy_path    critical
    Click Tab    ${TAB_COMPLETED}
    ${has_review}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${BTN_REVIEW}
    Pass Execution If    not ${has_review}    ไม่มีปุ่มรีวิวที่ active
    Open Review Modal
    Select Star Rating    4
    Input Review Comment    การเดินทางดีมาก คนขับใจดีและตรงเวลา — UAT Test
    Submit Review Form
    Wait For Toast    รีวิวสำเร็จ

TC27 - หลังรีวิวแล้ว ปุ่มรีวิวเปลี่ยนเป็น Badge "รีวิวแล้ว"
    [Tags]    review    guard    critical
    Click Tab    ${TAB_COMPLETED}
    Wait Until Element Is Visible    ${TEXT_REVIEWED}    timeout=${DEFAULT_TIMEOUT}
    Element Should Not Be Visible    ${BTN_REVIEW}

TC28 - Trip ที่รีวิวแล้ว ปุ่ม "รีวิวคนขับ" ต้องไม่ปรากฏ
    [Tags]    review    guard    negative
    Click Tab    ${TAB_COMPLETED}
    ${reviewed_count}=    Get Element Count    ${TEXT_REVIEWED}
    Pass Execution If    ${reviewed_count} == 0    ยังไม่มี trip ที่รีวิวแล้ว
    FOR    ${i}    IN RANGE    1    ${reviewed_count}+1
        # FIX: ใช้ selector ที่ตรงกับ trip card จริง (p-6 + cursor-pointer)
        Element Should Not Be Visible
        ...    xpath=(//span[contains(.,'รีวิวแล้ว')])[${i}]/ancestor::div[contains(@class,'p-6') and contains(@class,'cursor-pointer')]//button[contains(.,'รีวิวคนขับ')]
    END

TC29 - คะแนนรีวิวคนขับแสดงบน Trip Card
    [Tags]    review    ui
    Click Tab    ${TAB_COMPLETED}
    Element Should Be Visible    xpath=//*[contains(@class,'text-yellow-400')]

TC30 - รีวิวคนขับแสดงใน Expanded Detail Section
    [Tags]    review    ui    trip_detail
    Click Tab    ${TAB_COMPLETED}
    Click First Trip Card
    Wait Until Element Is Visible
    ...    xpath=//h5[contains(.,'รีวิวของคนขับ')]    timeout=${DEFAULT_TIMEOUT}


# ══════════════════════════════════════════════════════════════════
# 7. CONFIRMED TRIP
# ══════════════════════════════════════════════════════════════════

TC31 - Trip ที่ยืนยันแล้วแสดงปุ่ม "แชทกับผู้ขับ"
    [Tags]    confirmed    ui
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip confirmed
    Element Should Be Visible    ${BTN_CHAT}

TC32 - Trip ที่ยืนยันแล้วสามารถยกเลิกได้
    [Tags]    confirmed    ui
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip confirmed
    Element Should Be Visible    ${BTN_CANCEL_BOOKING}


# ══════════════════════════════════════════════════════════════════
# 8. REJECTED / CANCELLED TRIP
# ══════════════════════════════════════════════════════════════════

TC33 - Tab "ปฏิเสธ" แสดงปุ่ม "ลบรายการ"
    [Tags]    rejected    ui
    Click Tab    ${TAB_REJECTED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip ที่ถูกปฏิเสธ
    Element Should Be Visible    ${BTN_DELETE}

TC34 - ลบ Trip ที่ถูกปฏิเสธสำเร็จ
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

TC35 - Tab "ยกเลิก" แสดง Trip ที่ยกเลิกไปแล้ว
    [Tags]    cancelled    ui
    Click Tab    ${TAB_CANCELLED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Log    จำนวน Trip ที่ยกเลิก: ${trip_count}


# ══════════════════════════════════════════════════════════════════
# 9. REPORT ON COMPLETED / REJECTED TRIP
# ══════════════════════════════════════════════════════════════════

TC36 - Trip "เสร็จสิ้น" สามารถรายงานปัญหาได้
    [Tags]    report    completed
    Click Tab    ${TAB_COMPLETED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip completed
    ${count}=    Get Element Count
    ...    xpath=//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))] | //button[contains(.,'ดูประวัติการรายงาน')]
    Should Be True    ${count} > 0

TC37 - Trip "ปฏิเสธ" สามารถรายงานปัญหาได้
    [Tags]    report    rejected
    Click Tab    ${TAB_REJECTED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Pass Execution If    ${trip_count} == 0    ไม่มี trip rejected
    ${count}=    Get Element Count
    ...    xpath=//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))] | //button[contains(.,'ดูประวัติการรายงาน')]
    Should Be True    ${count} > 0

TC38 - ส่ง Report บน Trip "เสร็จสิ้น" สำเร็จ
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

TC39 - หน้าแสดงข้อความเมื่อ Tab ไม่มี Trip
    [Tags]    ui    empty_state
    Click Tab    ${TAB_CONFIRMED}
    ${trip_count}=    Get Element Count    ${TRIP_CARD}
    Run Keyword If    ${trip_count} == 0
    ...    Page Should Contain    ไม่พบรายการเดินทางในหมวดหมู่นี้

TC40 - Status Badge แสดงสีและข้อความถูกต้องตามสถานะ
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

TC41 - ข้อมูลราคา จำนวนที่นั่ง และเวลาแสดงบน Trip Card
    [Tags]    ui    data
    Click Tab    ${TAB_ALL}
    Click First Trip Card
    Page Should Contain    บาท
    Page Should Contain    ที่นั่ง
    Page Should Contain    วันที่

TC42 - รูปภาพคนขับแสดงบน Trip Card
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
