*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser And Login
Suite Teardown    Close Browser

*** Variables ***
${FRONT_URL}    http://cs-softeng-sec1-g4.cpkku.com
${BROWSER}      Chrome
${USERNAME}     mark___
${PASSWORD}     Mark1234
${IMAGE_PATH}   /Users/cherryp/Desktop/test-report.jpg

*** Keywords ***
Open Browser And Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver

    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}

    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --incognito

    Open Browser    ${FRONT_URL}/login    Chrome    options=${options}
    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    20s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    20s

*** Test Cases ***
Passenger Can Submit Report Successfully
    [Documentation]    Passenger รายงานปัญหา กรอกครบ แล้วส่งสำเร็จ

    Go To    ${FRONT_URL}/myTrip
    Wait Until Page Contains    การเดินทางของฉัน    20s
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูลการเดินทาง...    20s

    # กด tab ทั้งหมดก่อน
    Click Button    xpath=//button[contains(.,'ทั้งหมด')]

    # รอ DOM update
    Sleep    1s

    # รอ trip-card
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'trip-card')]
    ...    20s

    # คลิก trip แรก
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]

    # ถ้ามีปุ่มรายงานปัญหา ให้กด
    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='รายงานปัญหา']
    ...    20s

    Click Button    xpath=//button[normalize-space()='รายงานปัญหา']

    # รอ modal เปิด
    Wait Until Element Is Visible
    ...    xpath=//h3[normalize-space()='รายงานปัญหาการเดินทาง']
    ...    20s

    # เลือก checkbox คนแรก
    Click Element    xpath=(//input[@type='checkbox'])[1]

    # เลือกประเภท
    Select From List By Value
    ...    xpath=//select
    ...    DANGEROUS_DRIVING

    # กรอกรายละเอียด (เกิน 10 ตัวอักษร)
    Input Text
    ...    xpath=//textarea[@placeholder='กรอกรายละเอียดปัญหา...']
    ...    ทดสอบรายงานปัญหาโดยระบบ automation ผ่านแน่นอน

    # อัปโหลดรูปภาพประกอบ
    Choose File
    ...    xpath=//input[@type='file']
    ...    ${IMAGE_PATH}

    Sleep    1s

    # กดส่งรายงาน
    Wait Until Element Is Enabled
    ...    xpath=//button[normalize-space()='ส่งรายงาน']
    ...    15s

    Click Button    xpath=//button[normalize-space()='ส่งรายงาน']

    # รอ success toast
    Wait Until Page Contains    ส่งรายงานสำเร็จ    20s

    # รอ redirect
    Wait Until Location Contains    /myHistory    20s