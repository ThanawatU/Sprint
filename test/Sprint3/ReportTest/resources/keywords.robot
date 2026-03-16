*** Settings ***
Library     SeleniumLibrary
Resource    variables.robot

*** Keywords ***
# ─────────────────────────────────────────
# Browser / Session
# ─────────────────────────────────────────
Open Browser And Login
    [Documentation]    เปิด browser, รอ page โหลดเสร็จ แล้ว login ด้วย passenger account
    Open Browser    ${LOGIN_URL}    chrome
    ...    options=add_argument("--start-maximized");add_argument("--disable-notifications")
    Maximize Browser Window
    Wait For Login Page To Be Ready
    Fill Login Form    ${PASSENGER_EMAIL}    ${PASSENGER_PASSWORD}
    Wait For Successful Login

Open Browser And Login As Second Passenger
    [Documentation]    Login ด้วย passenger account คนที่สอง
    Open Browser    ${LOGIN_URL}    chrome
    ...    options=add_argument("--start-maximized");add_argument("--disable-notifications")
    Maximize Browser Window
    Wait For Login Page To Be Ready
    Fill Login Form    ${PASSENGER_EMAIL_2}    ${PASSENGER_PASSWORD_2}
    Wait For Successful Login

Wait For Login Page To Be Ready
    [Documentation]    รอให้ login form โหลดเสร็จก่อน interact
    ...    ลอง selectors หลายแบบเพื่อรองรับ Nuxt hydration delay
    Wait Until Page Contains Element
    ...    xpath=//input[@type='email'] | //input[contains(@placeholder,'email') or contains(@placeholder,'อีเมล') or contains(@name,'email')] | //form//input[1]
    ...    timeout=${LONG_TIMEOUT}
    # รอ JS hydration เสร็จ (Nuxt อาจ mount form ช้า)
    Sleep    0.5s

Fill Login Form
    [Arguments]    ${email}    ${password}
    [Documentation]    กรอก email + password รองรับ selector หลายรูปแบบ
    ${email_field}=    Get Login Email Field
    ${pass_field}=     Get Login Password Field
    Clear Element Text    ${email_field}
    Input Text    ${email_field}    ${email}
    Clear Element Text    ${pass_field}
    Input Text    ${pass_field}    ${password}
    ${submit_btn}=    Get Login Submit Button
    Click Element    ${submit_btn}

Get Login Email Field
    [Documentation]    หา email input ด้วย fallback selectors หลายแบบ
    ${selectors}=    Create List
    ...    xpath=//input[@type='email']
    ...    xpath=//input[contains(@name,'email') or contains(@id,'email')]
    ...    xpath=//input[contains(@placeholder,'อีเมล') or contains(@placeholder,'Email') or contains(@placeholder,'email')]
    ...    xpath=//form//input[@type='text'][1]
    FOR    ${sel}    IN    @{selectors}
        ${found}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${sel}
        Return From Keyword If    ${found}    ${sel}
    END
    Fail    ไม่พบ email input field — ตรวจสอบ selector ใน login page

Get Login Password Field
    [Documentation]    หา password input ด้วย fallback selectors
    ${selectors}=    Create List
    ...    xpath=//input[@type='password']
    ...    xpath=//input[contains(@name,'password') or contains(@id,'password')]
    ...    xpath=//input[contains(@placeholder,'รหัสผ่าน') or contains(@placeholder,'Password')]
    FOR    ${sel}    IN    @{selectors}
        ${found}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${sel}
        Return From Keyword If    ${found}    ${sel}
    END
    Fail    ไม่พบ password input field — ตรวจสอบ selector ใน login page

Get Login Submit Button
    [Documentation]    หา submit button ด้วย fallback selectors
    ${selectors}=    Create List
    ...    xpath=//button[@type='submit']
    ...    xpath=//button[contains(.,'เข้าสู่ระบบ') or contains(.,'Login') or contains(.,'Sign in') or contains(.,'ลงชื่อเข้าใช้')]
    ...    xpath=//form//button[1]
    FOR    ${sel}    IN    @{selectors}
        ${found}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${sel}
        Return From Keyword If    ${found}    ${sel}
    END
    Fail    ไม่พบ submit button — ตรวจสอบ selector ใน login page

Wait For Successful Login
    [Documentation]    รอยืนยันว่า login สำเร็จ: form หายไป หรือ redirect สำเร็จ
    # ลองรอ redirect โดยตรวจว่าไม่อยู่บน login page อีกต่อไป
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    1s    Verify Not On Login Page
    # รอ page ใหม่ render เสร็จ
    Wait Until Element Is Visible
    ...    xpath=//nav | //*[@id='__nuxt'] | //main
    ...    timeout=${DEFAULT_TIMEOUT}
    Sleep    0.5s

Verify Not On Login Page
    [Documentation]    ตรวจว่าออกจาก login page แล้ว
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    login
    Should Not Contain    ${current_url}    signin

Navigate To My Trips
    [Documentation]    ไปที่หน้า My Trips และรอ content โหลด
    Go To    ${MY_TRIPS_URL}
    # รอ Nuxt page transition + API call เสร็จ
    Wait Until Page Contains Element
    ...    xpath=//div[contains(@class,'tab-button')] | //h2[contains(.,'การเดินทางของฉัน')]
    ...    timeout=${LONG_TIMEOUT}
    # รอ trip card หรือ empty state อย่างใดอย่างหนึ่ง
    Wait Until Page Contains Element
    ...    xpath=//div[contains(@class,'trip-card')] | //*[contains(.,'ไม่พบรายการเดินทาง') or contains(.,'กำลังโหลด')]
    ...    timeout=${LONG_TIMEOUT}
    # ถ้า loading indicator ยังอยู่ ให้รอหายไปก่อน
    Run Keyword And Ignore Error
    ...    Wait Until Page Does Not Contain    กำลังโหลด    timeout=${DEFAULT_TIMEOUT}
    Sleep    ${ANIMATION_WAIT}

# ─────────────────────────────────────────
# Tab Navigation
# ─────────────────────────────────────────
Click Tab
    [Arguments]    ${tab_locator}
    Click Element    ${tab_locator}
    Sleep    ${ANIMATION_WAIT}

# ─────────────────────────────────────────
# Trip Card Interactions
# ─────────────────────────────────────────
Click First Trip Card
    [Documentation]    คลิก trip card ใบแรกเพื่อ expand รายละเอียด
    Wait Until Element Is Visible    ${TRIP_CARD_FIRST}    timeout=${DEFAULT_TIMEOUT}
    Click Element    ${TRIP_CARD_FIRST}
    Sleep    ${ANIMATION_WAIT}

Click Trip Card By Index
    [Arguments]    ${index}
    ${locator}=    Set Variable    xpath=(//div[contains(@class,'trip-card')])[${index}]
    Wait Until Element Is Visible    ${locator}    timeout=${DEFAULT_TIMEOUT}
    Click Element    ${locator}
    Sleep    ${ANIMATION_WAIT}

Get Trip Count For Tab
    [Arguments]    ${status}
    ${count}=    Get Text
    ...    xpath=//button[contains(@class,'tab-button') and contains(.,'${status}')]
    [Return]    ${count}

# ─────────────────────────────────────────
# Report Modal
# ─────────────────────────────────────────
Open Report Modal
    [Documentation]    คลิกปุ่ม 'รายงานปัญหา' ของ trip ใบแรก
    Click Element    ${BTN_REPORT_FIRST}
    Wait Until Element Is Visible    ${MODAL_REPORT}    timeout=${DEFAULT_TIMEOUT}

Select First Reportable User
    [Documentation]    เลือก checkbox ผู้ใช้คนแรกใน report modal
    Wait Until Element Is Visible    ${REPORT_USER_CB_FIRST}    timeout=${DEFAULT_TIMEOUT}
    Select Checkbox    ${REPORT_USER_CB_FIRST}

Select Problem Category
    [Arguments]    ${value}
    Select From List By Value    ${REPORT_CATEGORY}    ${value}

Input Report Description
    [Arguments]    ${text}
    Clear Element Text    ${REPORT_DESCRIPTION}
    Input Text    ${REPORT_DESCRIPTION}    ${text}

Submit Report Form
    Click Element    ${BTN_SUBMIT_REPORT}

Close Report Modal
    Click Element    ${BTN_CLOSE_MODAL}
    Wait Until Element Is Not Visible    ${MODAL_REPORT}    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────
# Cancel Modal
# ─────────────────────────────────────────
Open Cancel Modal
    [Documentation]    คลิกปุ่ม 'ยกเลิกการจอง' ของ trip ใบแรก
    Click Element    ${BTN_CANCEL_BOOKING}
    Wait Until Element Is Visible    ${MODAL_CANCEL}    timeout=${DEFAULT_TIMEOUT}

Select Cancel Reason
    [Arguments]    ${value}
    Select From List By Value    ${CANCEL_REASON_SELECT}    ${value}

Submit Cancel Form
    Click Element    ${BTN_SUBMIT_CANCEL}

Close Cancel Modal
    Click Element    ${BTN_CLOSE_MODAL}
    Wait Until Element Is Not Visible    ${MODAL_CANCEL}    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────
# Review Modal
# ─────────────────────────────────────────
Open Review Modal
    [Documentation]    คลิกปุ่ม 'รีวิวคนขับ' ของ trip ที่ completed
    Click Element    ${BTN_REVIEW}
    Wait Until Element Is Visible    ${MODAL_REVIEW}    timeout=${DEFAULT_TIMEOUT}

Select Star Rating
    [Arguments]    ${stars}
    [Documentation]    คลิกดาวตามจำนวนที่ระบุ (1-5)
    Click Element    xpath=(//div[contains(@class,'text-3xl')]//span[contains(@class,'cursor-pointer')])[${stars}]

Input Review Comment
    [Arguments]    ${text}
    Clear Element Text    ${REVIEW_COMMENT}
    Input Text    ${REVIEW_COMMENT}    ${text}

Submit Review Form
    Click Element    ${BTN_SUBMIT_REVIEW}

Close Review Modal
    Click Element    ${BTN_CLOSE_MODAL}
    Wait Until Element Is Not Visible    ${MODAL_REVIEW}    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────
# Assertions
# ─────────────────────────────────────────
Verify Report Button Replaced By History Button
    [Documentation]    หลังส่ง report แล้ว ปุ่มรายงานต้องเปลี่ยนเป็น 'ดูประวัติการรายงาน'
    Wait Until Element Is Visible    ${BTN_VIEW_HISTORY}    timeout=${DEFAULT_TIMEOUT}
    Element Should Not Be Visible    ${BTN_REPORT}

Verify Report Button Is Not Visible For Trip
    [Arguments]    ${trip_index}
    Element Should Not Be Visible
    ...    xpath=(//div[contains(@class,'trip-card')])[${trip_index}]//button[normalize-space()='รายงานปัญหา']

Verify User Checkbox Is Disabled
    [Arguments]    ${user_id}
    Element Should Be Disabled
    ...    xpath=//table//input[@type='checkbox' and @value='${user_id}']

Verify Submit Button Is Disabled
    Element Should Be Disabled    ${BTN_SUBMIT_REPORT}

Verify Submit Report Button Is Enabled
    Element Should Be Enabled    ${BTN_SUBMIT_REPORT}

Verify Cancel Button Disabled When No Reason
    Element Should Be Disabled    ${BTN_SUBMIT_CANCEL}

Verify Reviewed Badge Shown
    Wait Until Element Is Visible    ${TEXT_REVIEWED}    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    ${TEXT_REVIEWED}

Verify Review Button Hidden
    Element Should Not Be Visible    ${BTN_REVIEW}

Wait For Toast
    [Arguments]    ${message}    ${timeout}=${LONG_TIMEOUT}
    Wait Until Page Contains    ${message}    timeout=${timeout}
