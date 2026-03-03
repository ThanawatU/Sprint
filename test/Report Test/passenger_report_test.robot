*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser And Login
Suite Teardown    Close Browser

*** Variables ***
${FRONT_URL}    http://cs-softeng-sec1-g4.cpkku.com
${BROWSER}      Chrome
${USERNAME}     mark___
${PASSWORD}     Mark1234

*** Keywords ***
Open Browser And Login
    Open Browser    ${FRONT_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s

*** Test Cases ***
User Can Submit Report Successfully
    Go To    ${FRONT_URL}/my-trips
    Wait Until Page Does Not Contain    กำลังโหลดข้อมูล...    20s

    # คลิก trip แรก
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]    15s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]

    # รอปุ่มรายงาน (ต้องดู DOM จริงว่าชื่ออะไร)
    Wait Until Element Is Visible    xpath=//button[contains(.,'รายงาน')]    10s
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # รอ modal หรือหน้า form
    Wait Until Element Is Visible    xpath=//textarea    15s

    Input Text    xpath=//textarea    ทดสอบรายงานโดย automation

    Select From List By Index    xpath=//select    1

    Choose File
    ...    xpath=//input[@type='file']
    ...    ${CURDIR}/files/test1.jpg\n${CURDIR}/files/test2.jpg

    Click Button    xpath=//button[contains(.,'ส่งรายงาน')]

    Wait Until Page Contains    ส่งรายงานสำเร็จ    15s