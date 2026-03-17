*** Settings ***
Library    SeleniumLibrary
Resource   ../resources/variables.robot
Resource   ../resources/locators.robot


*** Keywords ***

Open Report Modal
    Wait Until Element Is Visible    ${REPORT_BUTTON}

    Click Button    ${REPORT_BUTTON}

    Wait Until Element Is Visible    ${REPORT_MODAL}


Select First User
    Click Element    ${CHECKBOX_USER}


Select Problem Type
    [Arguments]    ${type}

    Select From List By Value
    ...    ${PROBLEM_SELECT}
    ...    ${type}


Input Description
    [Arguments]    ${text}

    Input Text
    ...    ${DESCRIPTION}
    ...    ${text}


Upload Image
    Choose File
    ...    ${UPLOAD_IMAGE}
    ...    ${IMAGE_PATH}


Submit Report
    Click Button    ${SUBMIT_REPORT}