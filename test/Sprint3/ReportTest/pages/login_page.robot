*** Settings ***
Library    SeleniumLibrary
Resource   ../resources/variables.robot
Resource   ../resources/locators.robot

*** Keywords ***

Open Login Page
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver

    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --disable-infobars
    Call Method    ${options}    add_argument    --disable-geolocation

    SeleniumLibrary.Open Browser    ${FRONT_URL}/login    ${BROWSER}    options=${options}
    Maximize Browser Window


Login
    Wait Until Element Is Visible    ${LOGIN_USERNAME}

    Input Text    ${LOGIN_USERNAME}    ${USERNAME}
    Input Text    ${LOGIN_PASSWORD}    ${PASSWORD}

    Click Button    ${LOGIN_BUTTON}

    Wait Until Location Does Not Contain    /login

    Close Popup If Exists


Close Popup If Exists
    Run Keyword And Ignore Error
    ...    Click Button    ${IGNORE_POPUP}