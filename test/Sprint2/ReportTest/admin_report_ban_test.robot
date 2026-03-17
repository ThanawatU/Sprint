*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser And Login
Suite Teardown    Close Browser

*** Variables ***
${FRONT_URL}    http://cs-softeng-sec1-g4.cpkku.com
${BROWSER}      Chrome
${USERNAME}     admin123
${PASSWORD}     123456789

${NORMAL_USER}      mark___
${NORMAL_PASS}      Mark1234


*** Keywords ***
Open Browser And Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary    credentials_enable_service=${False}    profile.password_manager_enabled=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --incognito

    Open Browser    ${FRONT_URL}/login    ${BROWSER}    options=${options}
    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s


Go To Report Management
    Go To    ${FRONT_URL}/admin/reports-dashboard
    Wait Until Location Contains    /admin/reports-dashboard    15s


Wait Until Reports Table Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s
    Wait Until Element Is Visible    xpath=//table    20s


Wait Until Report Detail Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s
    Wait Until Element Is Visible    xpath=//h1[normalize-space()='รายละเอียดการรายงาน']    20s


Click First View Report Button
    Wait Until Element Is Visible    xpath=(//button[@aria-label='ดูรายละเอียด'])[1]    15s
    Scroll Element Into View         xpath=(//button[@aria-label='ดูรายละเอียด'])[1]
    Click Element                    xpath=(//button[@aria-label='ดูรายละเอียด'])[1]


Open Case Management
    Wait Until Element Is Visible    xpath=//button[normalize-space()='จัดการ']    15s
    Scroll Element Into View         xpath=//button[normalize-space()='จัดการ']
    Click Element                    xpath=//button[normalize-space()='จัดการ']
    Wait Until Page Contains         จัดการเคส    10s


Logout
    Go To    ${FRONT_URL}/logout
    Sleep    2s


Login As Normal User
    Go To    ${FRONT_URL}/login
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${NORMAL_USER}
    Input Text    id=password      ${NORMAL_PASS}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s


*** Test Cases ***

TC1 - Admin Can View Dashboard
    Go To Report Management
    Page Should Contain Element    xpath=//h1[text()='Report Management']
    Page Should Contain    Report ทั้งหมด
    Page Should Contain    Report วันนี้
    Page Should Contain    ปิด Case วันนี้


TC2 - Reports Table Headers Correct
    Go To Report Management
    Wait Until Reports Table Loaded
    Page Should Contain    ID
    Page Should Contain    Reporter
    Page Should Contain    Driver
    Page Should Contain    หมวดหมู่
    Page Should Contain    รายละเอียด
    Page Should Contain    สถานะ
    Page Should Contain    สร้างเมื่อ
    Page Should Contain    การกระทำ


TC3 - Admin Can Open First Report Detail
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded

TC4 - Admin Can Issue Yellow Card
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded
    Open Case Management

    Wait Until Element Is Visible    xpath=(//input[@type='checkbox'])[1]    10s
    Click Element    xpath=(//input[@type='checkbox'])[1]

    Input Text    xpath=//textarea    Automation Yellow Card Test

    Select From List By Value
    ...    xpath=//select
    ...    WARNING_ISSUED

    Click Button    xpath=//button[contains(.,'มอบใบเหลือง')]
    Wait Until Page Contains    มอบใบเหลืองเรียบร้อย    15s

TC5 - Admin Can Close Case
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded
    Open Case Management

    # กดปฏิเสธเคส
    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='ปฏิเสธเคส']
    ...    15s

    Click Button
    ...    xpath=//button[normalize-space()='ปฏิเสธเคส']

    # ไม่ต้องรอ toast แล้ว
    Sleep    2s

    # รอให้ปุ่ม Close เปิดใช้งาน
    Wait Until Element Is Enabled
    ...    xpath=//button[normalize-space()='ปิดเคส']
    ...    15s

    Click Button
    ...    xpath=//button[normalize-space()='ปิดเคส']

    Wait Until Page Contains    ปิดเคสเรียบร้อย    15s


TC6 - Evidence Section Displayed
    Go To Report Management
    Wait Until Reports Table Loaded
    Click First View Report Button
    Wait Until Report Detail Loaded

    Execute Javascript    window.scrollTo(0, document.body.scrollHeight)

    Wait Until Page Contains    ไฟล์แนบ    10s


TC7 - User Cannot Access Admin Dashboard
    Logout
    Login As Normal User

    Go To    ${FRONT_URL}/admin/reports-dashboard
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    /admin/reports-dashboard