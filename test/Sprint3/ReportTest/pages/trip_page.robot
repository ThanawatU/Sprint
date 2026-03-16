*** Settings ***
Library    SeleniumLibrary
Resource   ../resources/variables.robot
Resource   ../resources/locators.robot


*** Keywords ***

Open My Trip Page
    Go To    ${FRONT_URL}/myTrip

    Wait Until Page Contains    การเดินทางของฉัน


Select All Trips Tab
    Click Button    ${TAB_ALL_TRIPS}


Open First Trip
    Wait Until Element Is Visible    ${TRIP_CARD}

    Click Element    xpath=(${TRIP_CARD})[1]