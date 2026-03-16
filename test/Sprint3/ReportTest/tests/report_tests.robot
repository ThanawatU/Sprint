*** Settings ***
Library     SeleniumLibrary

Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot

Suite Setup       Open Browser And Login
Suite Teardown    Close Browser

Test Teardown     Capture Page Screenshot


*** Test Cases ***

Passenger Can Submit Report Successfully
    Open Trip And Report

    Submit Valid Report

    Wait Until Page Contains    ส่งรายงานสำเร็จ


Passenger Cannot Submit Without Selecting User
    Open Trip And Report

    Select Problem Type    DANGEROUS_DRIVING

    Input Description
    ...    automation report testing

    Element Should Be Disabled
    ...    xpath=//button[normalize-space()='ส่งรายงาน']


Passenger Cannot Submit With Short Description
    Open Trip And Report

    Select First User
    Select Problem Type    DANGEROUS_DRIVING

    Input Description    สั้น

    Element Should Be Disabled
    ...    xpath=//button[normalize-space()='ส่งรายงาน']