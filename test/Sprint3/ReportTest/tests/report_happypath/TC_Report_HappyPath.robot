*** Settings ***
Documentation     Suite แยกสำหรับ Report Happy Path
...               ใช้ fresh user ที่ไม่เคย report ใครมาก่อน
...               เพื่อให้ปุ่ม "รายงานปัญหา" ยังอยู่ครบทุกรอบที่รัน
...
...               ข้อกำหนดก่อนรัน:
...               1. สร้าง fresh_report_1@test.com และ fresh_report_2@test.com ใน test environment
...               2. แต่ละ account ต้องมี booking ที่มีสถานะ pending/confirmed อย่างน้อย 1 รายการ
...               3. account เหล่านี้ต้องไม่เคย report trip ใด ๆ มาก่อน

Library           SeleniumLibrary
Resource          ../resources/variables.robot
Resource          ../resources/keywords.robot

Suite Teardown    Close Browser
Test Teardown     Capture Page Screenshot


*** Test Cases ***

TC_REPORT_01 - Fresh User 1: ส่ง Report สำเร็จบน Pending Trip
    [Documentation]    Login ด้วย fresh user 1 → ส่ง report → ต้องสำเร็จ
    [Tags]    report    happy_path    critical    fresh
    Open Browser And Login As Fresh User    ${FRESH_EMAIL_1}    ${FRESH_PASSWORD_1}
    Go To    ${MY_TRIPS_URL}
    Wait Until Page Contains Element
    ...    xpath=//button[contains(@class,'tab-button')]    timeout=${LONG_TIMEOUT}
    # หา tab ที่มีปุ่ม report
    ${found}=    Find Tab With Report Button
    Run Keyword If    '${found}' == 'none'
    ...    Fail    fresh_report_1 ไม่มีปุ่ม report — ตรวจสอบ seed data
    Open Report Modal
    Select First Reportable User
    Select Problem Category    DANGEROUS_DRIVING
    Input Report Description    Fresh User 1 ทดสอบรายงาน — UAT Report Happy Path Suite
    Submit Report Form
    Wait For Toast    ส่งรายงานสำเร็จ

TC_REPORT_02 - Fresh User 1: หลัง Report แล้ว ปุ่มเปลี่ยนเป็น "ดูประวัติการรายงาน"
    [Documentation]    guard หลัง TC_REPORT_01 — ปุ่ม report ต้องหายไป
    [Tags]    report    guard    fresh
    # ยังอยู่ใน session เดิมของ Fresh User 1
    Go To    ${MY_TRIPS_URL}
    Wait Until Page Contains Element
    ...    xpath=//button[contains(@class,'tab-button')]    timeout=${LONG_TIMEOUT}
    Click Tab    ${TAB_PENDING}
    Wait Until Element Is Visible    ${BTN_VIEW_HISTORY}    timeout=${LONG_TIMEOUT}
    Element Should Not Be Visible    ${BTN_REPORT}

TC_REPORT_03 - Fresh User 2: ส่ง Report สำเร็จบน Completed Trip
    [Documentation]    Login ด้วย fresh user 2 → report บน completed trip → ต้องสำเร็จ
    [Tags]    report    happy_path    critical    fresh
    # เปิด browser ใหม่ด้วย fresh user 2
    Close Browser
    Open Browser And Login As Fresh User    ${FRESH_EMAIL_2}    ${FRESH_PASSWORD_2}
    Go To    ${MY_TRIPS_URL}
    Wait Until Page Contains Element
    ...    xpath=//button[contains(@class,'tab-button')]    timeout=${LONG_TIMEOUT}
    Click Tab    ${TAB_COMPLETED}
    ${has_report}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${BTN_REPORT_FIRST}
    Run Keyword If    not ${has_report}
    ...    Fail    fresh_report_2 ไม่มีปุ่ม report บน completed trip — ตรวจสอบ seed data
    Open Report Modal
    Select First Reportable User
    Select Problem Category    NO_SHOW
    Input Report Description    Fresh User 2 ทดสอบรายงานบน Completed Trip — UAT Suite
    Submit Report Form
    Wait Until Page Contains    สำเร็จ    timeout=${LONG_TIMEOUT}

TC_REPORT_04 - Fresh User 2: หลัง Report แล้ว ปุ่มเปลี่ยนบน Completed Trip
    [Documentation]    guard หลัง TC_REPORT_03 — ปุ่ม report ต้องหายไปบน completed trip
    [Tags]    report    guard    fresh
    Go To    ${MY_TRIPS_URL}
    Wait Until Page Contains Element
    ...    xpath=//button[contains(@class,'tab-button')]    timeout=${LONG_TIMEOUT}
    Click Tab    ${TAB_COMPLETED}
    # ปุ่ม report ต้องไม่มีแล้ว หรือมีปุ่ม ดูประวัติ แทน
    ${report_count}=    Get Element Count    ${BTN_REPORT}
    ${history_count}=    Get Element Count    ${BTN_VIEW_HISTORY}
    Should Be True    ${history_count} > 0 or ${report_count} == 0


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
