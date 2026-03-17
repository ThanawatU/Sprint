*** Settings ***
Library    SeleniumLibrary
Resource   ../resources/variables.robot
Resource   ../resources/locators.robot


*** Keywords ***

Open My Trip Page
    Go To    ${MY_TRIP_URL}

    Wait Until Page Contains    การเดินทางของฉัน    20s

    Wait Until Element Is Visible
    ...    ${TAB_ALL_TRIPS}
    ...    20s


Select All Trips Tab
    Click Button    ${TAB_ALL_TRIPS}


Open First Trip
    Wait Until Page Does Not Contain
    ...    กำลังโหลดข้อมูลการเดินทาง...
    ...    20s

    Wait Until Element Is Visible
    ...    ${TRIP_CARD}
    ...    20s

    ${trips}=    Get WebElements    ${TRIP_CARD}

    Click Element    ${trips}[0]