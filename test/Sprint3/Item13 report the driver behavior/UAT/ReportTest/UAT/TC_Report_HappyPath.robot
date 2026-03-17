*** Settings ***
Library    SeleniumLibrary
Suite Setup    Setup Suite
Suite Teardown    Close Browser

*** Variables ***
${BASE_URL}           https://csse1469.cpkku.com 
${LOGIN_URL}          ${BASE_URL}/login
${MY_TRIPS_URL}       ${BASE_URL}/myTrip
${MY_HISTORY_URL}     ${BASE_URL}/myHistory

${MY_HISTORY_PATH}    /myHistory

${BROWSER}    Chrome

${VALID_IMAGE}      ${CURDIR}/test-report.jpg
${LARGE_FILE}       ${CURDIR}/large-file.gif

# === Credentials (main suite) ===
${PASSENGER_EMAIL}        passenger_5
${PASSENGER_PASSWORD}     123456789
${PASSENGER_EMAIL_2}      passenger_6
${PASSENGER_PASSWORD_2}   123456789



*** Keywords ***
Setup Suite
    Open Browser And Login
    Create Report For History Test

Open Browser And Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver

    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}

    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --incognito

    Open Browser    ${LOGIN_URL}    Chrome    options=${options}
    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    20s
    Input Text    id=identifier    ${PASSENGER_EMAIL}
    Input Text    id=password      ${PASSENGER_PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    20s

Create Report For History Test
    Go To    ${MY_TRIPS_URL}

    Wait Until Page Contains    การเดินทางของฉัน    20s
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูลการเดินทาง...    20s

    Click Button    xpath=//button[contains(.,'ทั้งหมด')]

    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'trip-card')])[1]
    ...    20s

    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]

    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='รายงานปัญหา']
    ...    20s

    Click Button    xpath=//button[normalize-space()='รายงานปัญหา']

    Wait Until Element Is Visible
    ...    xpath=//h3[normalize-space()='รายงานปัญหาการเดินทาง']
    ...    20s

    Click Element    xpath=(//input[@type='checkbox'])[1]

    Select From List By Value
    ...    xpath=//select
    ...    DANGEROUS_DRIVING

    Input Text
    ...    xpath=//textarea
    ...    การทดสอบรายงานปัญหาอัตโนมัติ ใช้ในการ UAT เท่านั้น

    Click Button    xpath=//button[normalize-space()='ส่งรายงาน']

    Wait Until Page Contains    ส่งรายงานสำเร็จ    20s
    Wait Until Location Contains    ${MY_HISTORY_PATH}    20s

Open First Report Detail
    Wait Until Element Is Visible
    ...    xpath=(//button[contains(.,'ดู') and contains(.,'รายละเอียด')])[1]
    ...    15s

    Click Button
    ...    xpath=(//button[contains(.,'ดู') and contains(.,'รายละเอียด')])[1]

    Wait Until Page Contains
    ...    ผู้ถูกรายงาน
    ...    10s

Go To Home Page
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    xpath=//body    10s


Go To My Reports
    Go To    ${MY_HISTORY_URL}
    Wait Until Page Contains    ประวัติการรายงานของฉัน    15s


Wait Until Reports Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s


Open First Trip Report
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'trip-card')])[1]
    ...    15s

    Click Element
    ...    xpath=(//div[contains(@class,'trip-card')])[1]

    Wait Until Page Contains
    ...    รายละเอียด


*** Test Cases ***


TC-H1 - MyHistory Menu Visible When Logged In
    Go To Home Page
    Page Should Contain Element
    ...    xpath=//a[@href='/myHistory' and contains(.,'ประวัติการรีพอร์ต')]


TC-H2 - Navigate To MyHistory Page
    Go To Home Page
    Click Element    xpath=//a[@href='/myHistory']
    Wait Until Location Contains    ${MY_HISTORY_PATH}    10s
    Page Should Contain    ประวัติการรายงานของฉัน


TC1 - Report Page Loads
    Go To My Reports
    Wait Until Reports Loaded
    Page Should Contain    ประวัติการรายงานของฉัน


TC2 - Report Card Displays Correct Information
    Go To My Reports
    Wait Until Reports Loaded

    Page Should Contain Element
    ...    xpath=//div[contains(@class,'trip-card')]


TC3 - User Can Open Report Detail
    Go To My Reports
    Wait Until Reports Loaded

    Open First Report Detail

    Page Should Contain    ผู้ถูกรายงาน
    Page Should Contain    รายละเอียด


TC4 - Evidence Section Displayed
    Go To My Reports
    Wait Until Reports Loaded

    Open First Report Detail

    Page Should Contain    หลักฐาน


TC5 - User Can Upload Valid Evidence
    Go To My Reports
    Wait Until Reports Loaded

    Open First Report Detail

    Wait Until Element Is Visible
    ...    xpath=//input[@type='file']
    ...    10s

    Choose File
    ...    xpath=//input[@type='file']
    ...    ${VALID_IMAGE}

    Click Button
    ...    xpath=//button[contains(.,'อัปโหลด')]

    Wait Until Page Contains
    ...    อัปโหลด


TC6 - Upload File Larger Than 10MB Should Fail
    Go To My Reports
    Wait Until Reports Loaded

    Open First Report Detail

    Choose File
    ...    xpath=//input[@type='file']
    ...    ${LARGE_FILE}

    Page Should Contain    10MB


TC7 - Search By Keyword
    Go To My Reports
    Wait Until Reports Loaded

    Input Text
    ...    xpath=//input[@placeholder='ค้นหาจากคำอธิบาย...']
    ...    ทดสอบ

    Click Button
    ...    xpath=//button[contains(.,'ค้นหา')]

    Wait Until Reports Loaded


TC8 - Filter By Status
    Go To My Reports
    Wait Until Reports Loaded

    Select From List By Value
    ...    xpath=(//select)[2]
    ...    RESOLVED

    Click Button    xpath=//button[contains(.,'ค้นหา')]
    Wait Until Reports Loaded


TC9 - Reset Search Form
    Go To My Reports
    Wait Until Reports Loaded

    Click Button    xpath=//button[contains(.,'รีเซ็ต')]
    Page Should Contain    ประวัติการรายงานของฉัน
