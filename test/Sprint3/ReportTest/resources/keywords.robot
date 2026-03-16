*** Settings ***
Library    SeleniumLibrary

Resource   ../resources/variables.robot
Resource   ../pages/login_page.robot
Resource   ../pages/trip_page.robot
Resource   ../pages/report_modal.robot


*** Keywords ***

Open Browser And Login
    Open Login Page
    Login


Open Trip And Report
    Open My Trip Page
    Select All Trips Tab
    Open First Trip
    Open Report Modal


Submit Valid Report
    Select First User
    Select Problem Type    DANGEROUS_DRIVING

    Input Description
    ...    automation report testing more than ten characters

    Upload Image

    Submit Report