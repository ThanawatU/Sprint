*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser And Login
Suite Teardown    Close Browser

*** Variables ***
# ${FRONT_URL}    http://localhost:3001
${FRONT_URL}    http://cs-softeng-sec1-g4.cpkku.com 
${BROWSER}      Chrome
${USERNAME}     admin123
${PASSWORD}     123456789

*** Keywords ***
Open Browser And Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary    credentials_enable_service=${False}    profile.password_manager_enabled=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --incognito

    Open Browser    ${FRONT_URL}/login    Chrome    options=${options}
    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s

Admin Login
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Contains    Dashboard    10s

Go To Report Management
    Go To    ${FRONT_URL}/admin/reports-dashboard
    Wait Until Location Contains    /admin/reports-dashboard    15s

Check Page Title
    Page Should Contain Element    xpath=//h1[text()='Report Management']

Check Dashboard Stats
    Page Should Contain    Report ทั้งหมด
    Page Should Contain    Report วันนี้
    Page Should Contain    ปิด Case วันนี้

Check Status Distribution
    Page Should Contain Element    xpath=//h3[text()='สถานะ Report']
    Page Should Contain    Filed
    Page Should Contain    Under Review
    Page Should Contain    Investigating
    Page Should Contain    Resolved
    Page Should Contain    Rejected
    Page Should Contain    Closed

Check Reports Table Headers
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    15s
    Wait Until Element Is Visible    xpath=//table    15s

    Page Should Contain    ID
    Page Should Contain    Reporter
    Page Should Contain    Driver
    Page Should Contain    หมวดหมู่
    Page Should Contain    รายละเอียด
    Page Should Contain    สถานะ
    Page Should Contain    สร้างเมื่อ
    Page Should Contain    การกระทำ

Check Empty State
    Page Should Contain    ไม่มีข้อมูล Report

Click First View Report Button
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    15s
    Wait Until Element Is Visible    xpath=(//button[@aria-label='ดูรายละเอียด'])[1]    10s

    Scroll Element Into View    xpath=(//button[@aria-label='ดูรายละเอียด'])[1]
    Click Element    xpath=(//button[@aria-label='ดูรายละเอียด'])[1]

Verify Redirected To Report Detail Page
    Wait Until Location Contains    /admin/reports-dashboard/    10s
    ${url}=    Get Location
    Log To Console    Current URL: ${url}

Wait Until Reports Table Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s
    Wait Until Element Is Visible    xpath=//table    20s

Wait Until Report Detail Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s
    Wait Until Element Is Visible    xpath=//h1[text()='รายละเอียดการรายงาน']    20s

Go To Report Detail By Id
    [Arguments]    ${report_id}
    Go To    ${FRONT_URL}/admin/reports-dashboard/${report_id}
    Wait Until Location Contains    /admin/reports-dashboard/${report_id}    10s

*** Test Cases ***
Admin Can View Report Dashboard
    Go To Report Management
    Check Page Title
    Check Dashboard Stats
    Check Status Distribution
    Check Reports Table Headers

Admin Can Open First Report Detail
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded

Admin Can Issue Yellow Card
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded

    # รอ element ปรากฏก่อน
    Wait Until Element Is Visible    xpath=//button[normalize-space()='จัดการ']    15s

    # Scroll ลงไปก่อน
    Scroll Element Into View    xpath=//button[normalize-space()='จัดการ']

    Click Element    xpath=//button[normalize-space()='จัดการ']
    Wait Until Page Contains    จัดการเคส    10s

    # เลือก checkbox คนแรก (driver)
    Wait Until Element Is Visible    xpath=(//input[@type='checkbox'])[1]    10s
    Click Element    xpath=(//input[@type='checkbox'])[1]

    # กรอกเหตุผล
    Input Text    xpath=//textarea    ทดสอบมอบใบเหลืองโดย automation

    # เลือก preset
    Select From List By Value
    ...    xpath=//select
    ...    WARNING_ISSUED

    # กดปุ่มมอบใบเหลือง
    Click Button    xpath=//button[contains(.,'มอบใบเหลือง')]

    # ตรวจสอบ toast
    Wait Until Page Contains    มอบใบเหลืองเรียบร้อย    10s

Admin Can See Evidence In Report Detail
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button

    # รอจนเข้า detail จริง
    Wait Until Location Contains    /admin/reports-dashboard/    15s

    # รอ loading หาย
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s

    # รอ header detail โผล่
    Wait Until Element Is Visible
    ...    xpath=//h1[normalize-space()='รายละเอียดการรายงาน']
    ...    15s

    # scroll ลงล่างก่อน
    Execute Javascript    window.scrollTo(0, document.body.scrollHeight)

    # เช็คไฟล์แนบ
    Page Should Contain Element
    ...    xpath=//p[normalize-space()='ไฟล์แนบ:'] | //p[contains(text(),'ไม่มีไฟล์แนบ')]

User Cannot Access Admin Report Detail
    Go To    ${FRONT_URL}/logout

    Go To    ${FRONT_URL}/login
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    mark___
    Input Text    id=password      Mark1234
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    10s

    Go To    ${FRONT_URL}/admin/reports-dashboard

    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    /admin/reports-dashboard