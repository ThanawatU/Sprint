*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser And Login As User
Suite Teardown    Close Browser

*** Variables ***
${FRONT_URL}    https://csse1469.cpkku.com
${BROWSER}      Chrome
${USERNAME}     mark___
${PASSWORD}     Mark1234
${MY_HISTORY_PATH}    /myHistory

${VALID_IMAGE}      ${CURDIR}/file-test/test-report.jpg
${LARGE_FILE}       ${CURDIR}/file-test/large-file.gif


*** Keywords ***
Open Browser And Login As User
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --incognito
    Call Method    ${options}    add_argument    --disable-notifications

    Open Browser    ${FRONT_URL}/login    ${BROWSER}    options=${options}
    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s


Go To Home Page
    Go To    ${FRONT_URL}
    Wait Until Element Is Visible    xpath=//body    10s


Go To My Reports
    Go To    ${FRONT_URL}/myHistory
    Wait Until Page Contains    ประวัติการรายงานของฉัน    15s


Wait Until Reports Loaded
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s


Open First Report Detail
    Wait Until Element Is Visible    xpath=(//button[contains(.,'ดูรายละเอียด')])[1]    15s
    Click Button    xpath=(//button[contains(.,'ดูรายละเอียด')])[1]
    Wait Until Page Contains    รายละเอียดการรายงาน    10s


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
    Page Should Contain Element    xpath=//span[contains(@class,'rounded-full')]
    Page Should Contain Element    xpath=//button[contains(.,'ดูรายละเอียด')]


TC3 - User Can Open Report Detail
    Go To My Reports
    Wait Until Reports Loaded
    Open First Report Detail
    Page Should Contain    ผู้ถูกรายงาน
    Page Should Contain    เลขที่การจอง
    Page Should Contain    คำอธิบาย


TC4 - Evidence Section Displayed
    Go To My Reports
    Wait Until Reports Loaded
    Open First Report Detail
    Execute Javascript    window.scrollTo(0, document.body.scrollHeight)

    Page Should Contain Element
    ...    xpath=//*[contains(text(),'หลักฐานที่แนบไว้') or contains(text(),'ยังไม่มีหลักฐาน')]


TC5 - User Can Upload Valid Evidence
    Go To My Reports
    Wait Until Reports Loaded
    Open First Report Detail

    Wait Until Element Is Visible    xpath=//input[@type='file']    10s
    Choose File    xpath=//input[@type='file']    ${VALID_IMAGE}
    Click Button    xpath=//button[contains(.,'อัปโหลดหลักฐาน')]

    Wait Until Page Contains    อัปโหลดหลักฐานสำเร็จ    20s


TC6 - Upload File Larger Than 10MB Should Fail
    Go To My Reports
    Wait Until Reports Loaded
    Open First Report Detail

    Choose File    xpath=//input[@type='file']    ${LARGE_FILE}
    Page Should Contain    10MB


TC7 - Search By Keyword
    Go To My Reports
    Wait Until Reports Loaded

    Input Text    xpath=//input[@placeholder='ค้นหาคำอธิบาย...']    ทดสอบ
    Click Button    xpath=//button[contains(.,'ค้นหา')]
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
