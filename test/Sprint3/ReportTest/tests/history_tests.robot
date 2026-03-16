*** Settings ***
Library     SeleniumLibrary
Resource    ../keywords/common_keywords.robot
Resource    ../resources/variables.robot

Suite Setup     Open Browser And Login
Suite Teardown  Close Browser


*** Test Cases ***

TC-H1 Navigate To MyHistory Page
    Go To    ${MY_HISTORY_URL}

    Wait Until Page Contains
    ...    ประวัติการรายงานของฉัน


TC-H2 Report Card Displayed
    Go To    ${MY_HISTORY_URL}

    Wait Until Element Is Visible
    ...    xpath=//button[contains(.,'ดูรายละเอียด')]


TC-H3 Open Report Detail
    Go To    ${MY_HISTORY_URL}

    Click Button
    ...    xpath=(//button[contains(.,'ดูรายละเอียด')])[1]

    Wait Until Page Contains
    ...    รายละเอียดการรายงาน


TC-H4 Evidence Section Displayed
    Go To    ${MY_HISTORY_URL}

    Click Button
    ...    xpath=(//button[contains(.,'ดูรายละเอียด')])[1]

    Execute Javascript
    ...    window.scrollTo(0, document.body.scrollHeight)

    Page Should Contain Element
    ...    xpath=//*[contains(text(),'หลักฐาน')]




    