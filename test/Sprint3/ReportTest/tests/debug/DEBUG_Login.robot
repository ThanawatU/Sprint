*** Settings ***
Documentation     Debug Suite — ตรวจสอบ Login Page Selectors
...               รันไฟล์นี้ก่อนถ้า TC01 fail ด้วย "Element did not appear"
...               จะ print ข้อมูล DOM จริงออกมาให้ดูว่า selector ควรเป็นอะไร

Library           SeleniumLibrary
Resource          ../resources/variables.robot

Suite Teardown    Close Browser

*** Test Cases ***

DEBUG01 - เปิดหน้า Login และ Capture Screenshot
    [Documentation]    เปิด browser ไปที่ login URL แล้ว screenshot ทันที
    [Tags]    debug
    Open Browser    ${LOGIN_URL}    chrome
    ...    options=add_argument("--start-maximized")
    Maximize Browser Window
    # รอ page โหลดด้วยวิธีง่ายที่สุดก่อน
    Sleep    5s
    Capture Page Screenshot    login_page_initial.png
    Log    URL ปัจจุบัน: ${LOGIN_URL}
    ${current_url}=    Get Location
    Log    Actual URL after load: ${current_url}

DEBUG02 - แสดง Title และ Source ของ Login Page
    [Documentation]    ดู page title และตรวจ source ว่ามี input element อะไรบ้าง
    [Tags]    debug
    ${title}=    Get Title
    Log    Page Title: ${title}
    ${source}=    Get Source
    # ตรวจหา input elements ต่างๆ
    ${has_email_type}=      Run Keyword And Return Status    Should Contain    ${source}    type="email"
    ${has_email_name}=      Run Keyword And Return Status    Should Contain    ${source}    name="email"
    ${has_email_id}=        Run Keyword And Return Status    Should Contain    ${source}    id="email"
    ${has_password_type}=   Run Keyword And Return Status    Should Contain    ${source}    type="password"
    ${has_submit_btn}=      Run Keyword And Return Status    Should Contain    ${source}    type="submit"
    ${has_login_text}=      Run Keyword And Return Status    Should Contain    ${source}    เข้าสู่ระบบ
    ${has_nuxt}=            Run Keyword And Return Status    Should Contain    ${source}    __nuxt
    Log    [INPUT] type="email" พบ: ${has_email_type}
    Log    [INPUT] name="email" พบ: ${has_email_name}
    Log    [INPUT] id="email"   พบ: ${has_email_id}
    Log    [INPUT] type="password" พบ: ${has_password_type}
    Log    [BUTTON] type="submit" พบ: ${has_submit_btn}
    Log    [TEXT] เข้าสู่ระบบ พบ: ${has_login_text}
    Log    [NUXT] __nuxt พบ: ${has_nuxt}

DEBUG03 - นับ Input Elements ทั้งหมดบน Login Page
    [Documentation]    นับและ log xpath ของ input ทุกตัวบนหน้า
    [Tags]    debug
    ${count}=    Get Element Count    xpath=//input
    Log    จำนวน input elements: ${count}
    FOR    ${i}    IN RANGE    1    ${count}+1
        ${loc}=    Set Variable    xpath=(//input)[${i}]
        ${type}=    Run Keyword And Ignore Error    Get Element Attribute    ${loc}    type
        ${name}=    Run Keyword And Ignore Error    Get Element Attribute    ${loc}    name
        ${id}=      Run Keyword And Ignore Error    Get Element Attribute    ${loc}    id
        ${placeholder}=    Run Keyword And Ignore Error    Get Element Attribute    ${loc}    placeholder
        Log    Input[${i}]: type=${type}  name=${name}  id=${id}  placeholder=${placeholder}
    END

DEBUG04 - ตรวจ Selector แบบต่างๆ ที่ใช้ใน keywords.robot
    [Documentation]    ทดสอบทีละ selector และบอกว่าอันไหนเจอ
    [Tags]    debug
    @{email_selectors}=    Create List
    ...    xpath=//input[@type='email']
    ...    xpath=//input[contains(@name,'email')]
    ...    xpath=//input[contains(@id,'email')]
    ...    xpath=//input[contains(@placeholder,'อีเมล')]
    ...    xpath=//input[contains(@placeholder,'Email')]
    ...    xpath=//form//input[@type='text'][1]
    ...    xpath=//form//input[1]
    FOR    ${sel}    IN    @{email_selectors}
        ${found}=    Run Keyword And Return Status    Element Should Be Visible    ${sel}
        Log    ${sel}  →  พบ: ${found}
    END

DEBUG05 - Capture Screenshot หลัง JS Hydration (รอ 10 วินาที)
    [Documentation]    รอ JS hydration เสร็จแล้ว screenshot ใหม่
    [Tags]    debug
    Sleep    10s
    Capture Page Screenshot    login_page_after_hydration.png
    ${count_after}=    Get Element Count    xpath=//input
    Log    จำนวน input หลัง hydration: ${count_after}
    # ลองทดสอบ input ที่พบ
    ${found_email}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//input[@type='email']    timeout=3s
    Log    หลัง hydration พบ email input: ${found_email}

DEBUG06 - ตรวจสอบ URL หน้า Login จริง (อาจ redirect ต่างกัน)
    [Documentation]    บางระบบ route /login ไปที่ /auth/login หรือ /signin
    [Tags]    debug
    ${current}=    Get Location
    Log    URL จริงหลัง navigate: ${current}
    # ถ้า redirect ไปที่อื่น ให้ update LOGIN_URL ใน variables.robot
    Should Not Contain    ${current}    404
    Should Not Contain    ${current}    error

DEBUG07 - ทดสอบ Login จริงด้วย Selector ที่แก้แล้ว
    [Documentation]    ทดสอบ login flow ทั้งหมดหลังหา selector ถูกต้องแล้ว
    [Tags]    debug    login_test
    # รอ hydration
    Sleep    3s
    # หา email field
    ${email_field}=    Find Visible Element
    ...    xpath=//input[@type='email']
    ...    xpath=//input[contains(@name,'email')]
    ...    xpath=//input[contains(@placeholder,'อีเมล')]
    ...    xpath=//form//input[1]
    Log    ใช้ email selector: ${email_field}
    Input Text    ${email_field}    ${PASSENGER_EMAIL}
    # หา password field
    ${pass_field}=    Find Visible Element
    ...    xpath=//input[@type='password']
    ...    xpath=//input[contains(@name,'password')]
    ...    xpath=//input[contains(@placeholder,'รหัสผ่าน')]
    Log    ใช้ password selector: ${pass_field}
    Input Text    ${pass_field}    ${PASSENGER_PASSWORD}
    Capture Page Screenshot    login_form_filled.png
    # หา submit button
    ${submit}=    Find Visible Element
    ...    xpath=//button[@type='submit']
    ...    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    ...    xpath=//button[contains(.,'Login')]
    ...    xpath=//form//button[1]
    Log    ใช้ submit selector: ${submit}
    Click Element    ${submit}
    Sleep    3s
    Capture Page Screenshot    after_login_click.png
    ${url_after}=    Get Location
    Log    URL หลัง submit: ${url_after}

*** Keywords ***
Find Visible Element
    [Arguments]    @{selectors}
    [Documentation]    วนหา element จาก list ของ selectors คืน selector แรกที่พบ
    FOR    ${sel}    IN    @{selectors}
        ${found}=    Run Keyword And Return Status    Element Should Be Visible    ${sel}
        Return From Keyword If    ${found}    ${sel}
    END
    Fail    ไม่พบ element จาก selectors ที่ให้มา: ${selectors}
