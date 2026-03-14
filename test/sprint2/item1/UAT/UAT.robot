*** Settings ***
Library         SeleniumLibrary
Library         OperatingSystem
Test Teardown   Close Browser

*** Variables ***
${CHROME_DRIVER_PATH}       C:${/}Program Files${/}ChromeForTesting${/}chromedriver-win64${/}chromedriver.exe
${CHROME_BROWSER_PATH}      C:${/}Program Files${/}ChromeForTesting${/}chrome-win64${/}chrome.exe

${BASE_URL}                 https://csse1469.cpkku.com/
${ADMIN_USER}               admin123
${ADMIN_PASS}               123456789
${TEST_USER}                tester
${TEST_PASS}                123456789

${DOWNLOAD_DIR}             ${EXECDIR}${/}downloads


*** Keywords ***
Open Chrome
    ${opts}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Evaluate    setattr($opts, "binary_location", r"""${CHROME_BROWSER_PATH}""")
    Call Method    ${opts}    add_argument    --start-maximized
    Call Method    ${opts}    add_argument    --disable-notifications
    ${prefs}=    Create Dictionary    download.default_directory=${DOWNLOAD_DIR}    download.prompt_for_download=${False}    download.directory_upgrade=${True}    credentials_enable_service=${False}    profile.password_manager_enabled=${False}    profile.password_manager_leak_detection=${False}
    Call Method    ${opts}    add_experimental_option    prefs    ${prefs}

    ${exclude}=    Evaluate    ['enable-automation']
    Call Method    ${opts}    add_experimental_option    excludeSwitches    ${exclude}

    ${svc}=     Evaluate    sys.modules["selenium.webdriver.chrome.service"].Service(executable_path=r"${CHROME_DRIVER_PATH}")
    Create Webdriver    Chrome    options=${opts}    service=${svc}
    Set Selenium Speed  0

Open Chrome in Incognito Mode
    ${opts}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Evaluate    setattr($opts, "binary_location", r"""${CHROME_BROWSER_PATH}""")
    Call Method    ${opts}    add_argument    --start-maximized
    Call Method    ${opts}    add_argument    --disable-notifications
    Call Method    ${opts}    add_argument    --incognito
    Call Method    ${opts}    add_argument    --disable-features\=PasswordLeakDetection
    ${prefs}=    Create Dictionary    download.default_directory=${DOWNLOAD_DIR}    download.prompt_for_download=${False}    download.directory_upgrade=${True}    credentials_enable_service=${False}    profile.password_manager_enabled=${False}    profile.password_manager_leak_detection=${False}
    Call Method    ${opts}    add_experimental_option    prefs    ${prefs}

    ${exclude}=    Evaluate    ['enable-automation']
    Call Method    ${opts}    add_experimental_option    excludeSwitches    ${exclude}

    ${svc}=     Evaluate    sys.modules["selenium.webdriver.chrome.service"].Service(executable_path=r"${CHROME_DRIVER_PATH}")
    Create Webdriver    Chrome    options=${opts}    service=${svc}
    Set Selenium Speed  0

Go To Login Page
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    xpath=//a[@href='/login']    10s
    Click Element    xpath=//a[@href='/login']
    Wait Until Element Is Visible    id=loginForm    10s

Login As Admin And Go Dashboard
    Wait Until Element Is Visible    id=identifier    10s
    Input Text        id=identifier    ${ADMIN_USER}
    Input Password    id=password      ${ADMIN_PASS}
    Click Button      xpath=//form[@id='loginForm']//button[@type='submit']
    Wait Until Element Is Visible    xpath=//div[contains(@class,'dropdown-trigger')]    15s
    Go To    ${BASE_URL}admin/users
    Wait Until Location Contains    /admin/users    10s

Open Monitor Page
    Go To    ${BASE_URL}admin/monitor
    Wait Until Location Contains    /admin/monitor    10s

Verify Home Page
    Location Should Be    ${BASE_URL}
    Page Should Contain Element    xpath=//a[@href='/login']

Verify Login Page And Form
    Location Should Contain    /login
    Page Should Contain Element    id=loginForm
    Page Should Contain Element    id=identifier
    Page Should Contain Element    id=password

Verify Admin Logged In And On Dashboard
    Location Should Contain    /admin/users
    Page Should Contain Element    xpath=//a[@href='/admin/monitor']
    Page Should Contain Element    xpath=//a[@href='/admin/users']

Verify Monitor Tabs Exist
    Location Should Contain    /admin/monitor
    Page Should Contain Element    xpath=//button[contains(.,'AuditLog')]
    Page Should Contain Element    xpath=//button[contains(.,'SystemLog')]
    Page Should Contain Element    xpath=//button[contains(.,'AccessLog')]


Switch Monitor Tab
    [Arguments]    ${tab_name}
    ${raw_xpath}=     Set Variable    //nav//button[contains(normalize-space(), '${tab_name}')]
    ${tab_btn}=       Set Variable    xpath=${raw_xpath}
    ${active_btn}=    Set Variable    xpath=//nav//button[contains(normalize-space(), '${tab_name}') and contains(@class, 'border-b-2')]
    
    Wait Until Element Is Visible    ${tab_btn}    10s
    Scroll Element Into View         ${tab_btn}
    Sleep    0.5s
    
    Execute Javascript    document.evaluate("${raw_xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Element Is Visible    ${active_btn}    10s
    Sleep    1.5s


Click Export CSV Button And Verify Download
    Create Directory    ${DOWNLOAD_DIR}
    Empty Directory     ${DOWNLOAD_DIR}
    ${export_btn_xpath}=    Set Variable    //button[contains(normalize-space(), 'Export CSV')]
    Wait Until Element Is Visible    xpath=${export_btn_xpath}    10s
    Execute Javascript    document.evaluate("${export_btn_xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Keyword Succeeds    10s    1s    Verify File Downloaded

Verify File Downloaded
    ${files}=    List Files In Directory    ${DOWNLOAD_DIR}
    ${file_count}=    Get Length    ${files}
    Should Be True    ${file_count} > 0    "ไฟล์ CSV ยังไม่ถูกดาวน์โหลดหรือโหลดไม่สำเร็จ"

# ---------------------------
# AuditLog Keywords
# ---------------------------
Verify AuditLog
    Switch Monitor Tab    AuditLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'AuditLog')]    10s
    Page Should Contain Element      xpath=//table
    Page Should Contain Element      xpath=//th[normalize-space()='Time']
    Page Should Contain Element      xpath=//th[normalize-space()='User']
    Page Should Contain Element      xpath=//th[normalize-space()='Role']
    Page Should Contain Element      xpath=//th[normalize-space()='Action']
    Page Should Contain Element      xpath=//th[normalize-space()='Entity']
    Page Should Contain Element      xpath=//th[normalize-space()='Entity ID']
    Page Should Contain Element      xpath=//th[normalize-space()='IP Address']
    Page Should Contain Element      xpath=//th[normalize-space()='User Agent']

Verify AuditLog Header
    Switch Monitor Tab    AuditLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'AuditLog')]    10s
    Page Should Contain    AuditLog (ล่าสุด 100 รายการ)

Verify AuditLog Columns
    Switch Monitor Tab    AuditLog
    Wait Until Element Is Visible    xpath=//th[normalize-space()='Time']    10s
    Page Should Contain Element      xpath=//th[normalize-space()='Time']
    Page Should Contain Element      xpath=//th[normalize-space()='User']
    Page Should Contain Element      xpath=//th[normalize-space()='Role']
    Page Should Contain Element      xpath=//th[normalize-space()='Action']
    Page Should Contain Element      xpath=//th[normalize-space()='Entity']
    Page Should Contain Element      xpath=//th[normalize-space()='Entity ID']
    Page Should Contain Element      xpath=//th[normalize-space()='IP Address']
    Page Should Contain Element      xpath=//th[normalize-space()='User Agent']

Verify AuditLog Has At Least 1 Row
    Switch Monitor Tab    AuditLog
    Wait Until Element Is Visible    xpath=//table//tbody/tr    10s
    Page Should Contain Element      xpath=//table//tbody/tr[1]

# ---------------------------
# SystemLog Keywords
# ---------------------------
Verify SystemLog
    Switch Monitor Tab    SystemLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'SystemLog')]    10s
    Page Should Contain Element    xpath=//th[normalize-space()='Time']
    Page Should Contain Element    xpath=//th[normalize-space()='Level']
    Page Should Contain Element    xpath=//th[normalize-space()='Request ID']
    Page Should Contain Element    xpath=//th[normalize-space()='Method']
    Page Should Contain Element    xpath=//th[normalize-space()='Path']
    Page Should Contain Element    xpath=//th[normalize-space()='Status']
    Page Should Contain Element    xpath=//th[normalize-space()='Duration']
    Page Should Contain Element    xpath=//th[normalize-space()='User']
    Page Should Contain Element    xpath=//th[normalize-space()='IP']
    Page Should Contain Element    xpath=//th[normalize-space()='User Agent']
    Page Should Contain Element    xpath=//th[normalize-space()='Error']

Verify SystemLog Header
    Switch Monitor Tab    SystemLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'SystemLog')]    10s
    Page Should Contain    SystemLog

Verify SystemLog Columns
    Switch Monitor Tab    SystemLog
    Wait Until Element Is Visible    xpath=//th[normalize-space()='Time']    10s
    Page Should Contain Element    xpath=//th[normalize-space()='Time']
    Page Should Contain Element    xpath=//th[normalize-space()='Level']
    Page Should Contain Element    xpath=//th[normalize-space()='Request ID']
    Page Should Contain Element    xpath=//th[normalize-space()='Method']
    Page Should Contain Element    xpath=//th[normalize-space()='Path']
    Page Should Contain Element    xpath=//th[normalize-space()='Status']
    Page Should Contain Element    xpath=//th[normalize-space()='Duration']
    Page Should Contain Element    xpath=//th[normalize-space()='User']
    Page Should Contain Element    xpath=//th[normalize-space()='IP']
    Page Should Contain Element    xpath=//th[normalize-space()='User Agent']
    Page Should Contain Element    xpath=//th[normalize-space()='Error']

Verify SystemLog Has At Least 1 Row
    Switch Monitor Tab    SystemLog
    Wait Until Element Is Visible    xpath=//table//tbody/tr    10s
    Page Should Contain Element      xpath=//table//tbody/tr[1]

# ---------------------------
# AccessLog Keywords
# ---------------------------
Verify AccessLog
    Switch Monitor Tab    AccessLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'AccessLog')]    10s
    Page Should Contain Element    xpath=//th[normalize-space()='Login Time']
    Page Should Contain Element    xpath=//th[normalize-space()='Logout Time']
    Page Should Contain Element    xpath=//th[normalize-space()='IP Address']
    Page Should Contain Element    xpath=//th[normalize-space()='User Agent']
    Page Should Contain Element    xpath=//th[normalize-space()='Session ID']

Verify AccessLog Header
    Switch Monitor Tab    AccessLog
    Wait Until Element Is Visible    xpath=//h2[contains(.,'AccessLog')]    10s
    Page Should Contain    AccessLog

Verify AccessLog Columns
    Switch Monitor Tab    AccessLog
    Wait Until Element Is Visible    xpath=//th[normalize-space()='Login Time']    10s
    Page Should Contain Element    xpath=//th[normalize-space()='Login Time']
    Page Should Contain Element    xpath=//th[normalize-space()='Logout Time']
    Page Should Contain Element    xpath=//th[normalize-space()='IP Address']
    Page Should Contain Element    xpath=//th[normalize-space()='User Agent']
    Page Should Contain Element    xpath=//th[normalize-space()='Session ID']

Verify AccessLog Has At Least 1 Row
    Switch Monitor Tab    AccessLog
    Wait Until Element Is Visible    xpath=//table//tbody/tr    10s
    Page Should Contain Element      xpath=//table//tbody/tr[1]

Select Export Format
    [Arguments]    ${format}
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 59f68a5 (Yodsanon_0215: add incident report system and refactor existing report module)
    ${select_xpath}=    Set Variable    xpath=(//select)[last()]
    
    Wait Until Element Is Visible    ${select_xpath}    10s
    Select From List By Label        ${select_xpath}    ${format}
<<<<<<< HEAD
=======
    Wait Until Element Is Visible    xpath=//select    10s
    Select From List By Label        xpath=//select    ${format}
>>>>>>> 60c32bc (Yodsanon_0215 :add test sprint 2)
=======
>>>>>>> 59f68a5 (Yodsanon_0215: add incident report system and refactor existing report module)

Click Export JSON Button And Verify Download
    Create Directory    ${DOWNLOAD_DIR}
    Empty Directory     ${DOWNLOAD_DIR}
    Select Export Format    JSON
    ${export_btn_xpath}=    Set Variable    //button[contains(normalize-space(), 'Export JSON')]
    Wait Until Element Is Visible    xpath=${export_btn_xpath}    10s
    Execute Javascript    document.evaluate("${export_btn_xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Keyword Succeeds    10s    1s    Verify File Downloaded

Click Export PDF Button And Verify Download
    Create Directory    ${DOWNLOAD_DIR}
    Empty Directory     ${DOWNLOAD_DIR}
    Select Export Format    PDF
    ${export_btn_xpath}=    Set Variable    //button[contains(normalize-space(), 'Export PDF')]
    Wait Until Element Is Visible    xpath=${export_btn_xpath}    10s
    Execute Javascript    document.evaluate("${export_btn_xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Keyword Succeeds    10s    1s    Verify File Downloaded

# ---------------------------
# User Data Request Keywords
# ---------------------------
Login As User
    Wait Until Element Is Visible    id=identifier    10s
    Input Text        id=identifier    ${TEST_USER}
    Input Password    id=password      ${TEST_PASS}
    Click Button      xpath=//form[@id='loginForm']//button[@type='submit']
    Wait Until Element Is Visible    xpath=//div[contains(@class,'dropdown-trigger')]    15s

Logout
    [Documentation]    คลิก Dropdown โปรไฟล์ (อ้างอิงจากเมนู /profile) แล้วกด Logout
    ${profile_dropdown}=    Set Variable    xpath=//div[contains(@class, 'dropdown-trigger') and .//a[contains(@href, '/profile')]]/div[contains(@class, 'cursor-pointer')]
    Wait Until Element Is Visible    ${profile_dropdown}    10s
    Click Element                    ${profile_dropdown}
    Sleep    1s
    Wait Until Element Is Visible    xpath=//button[contains(., 'Logout')]    10s
    Click Element                    xpath=//button[contains(., 'Logout')]
    Wait Until Location Contains     /    10s
    Sleep    1s

Submit User Data Request
    [Arguments]    ${format}    ${reason}=test
    Wait Until Element Is Visible    xpath=//select    10s
    Select From List By Label    xpath=//select    ${format}
    Input Text      xpath=//textarea    ${reason}
    Click Button    xpath=//button[contains(normalize-space(), 'ส่งคำขอข้อมูล')]
    Wait Until Page Contains    PENDING    10s

# ---------------------------
# คำขอข้อมูล
# ---------------------------
Approve Export Request By Format
    [Arguments]    ${format}
    ${btn_xpath}=    Set Variable    xpath=//tr[contains(., '${format}')]//button[contains(normalize-space(), 'อนุมัติ')]
    Wait Until Element Is Visible    ${btn_xpath}    10s
    Scroll Element Into View         ${btn_xpath}
    Click Button                     ${btn_xpath}
    Sleep    1s
    Handle Alert    ACCEPT
    Sleep    2s

Download User File By Format
    [Arguments]    ${format}
    ${btn_xpath}=    Set Variable    xpath=(//tr[td[normalize-space()='${format}'] and td[contains(.,'APPROVED')]]//button[contains(normalize-space(),'ดาวน์โหลด')])[1]
    Wait Until Element Is Visible    ${btn_xpath}    10s
    Scroll Element Into View         ${btn_xpath}
    Click Element                    ${btn_xpath}
    Sleep    2s

Verify File Count Equals
    [Arguments]    ${expected_count}
    ${files}=    List Files In Directory    ${DOWNLOAD_DIR}    exclude=*.crdownload
    ${file_count}=    Get Length    ${files}
    Should Be Equal As Integers    ${file_count}    ${expected_count}    "จำนวนไฟล์ไม่ตรงกับที่คาดหวัง"

*** Test Cases ***
# ---------------------------
# UAT-PNN-001 Audit Log Steps
# ---------------------------
UAT-PNN-001-STEP-001 Open Home Page
    Open Chrome
    Go To    ${BASE_URL}
    Verify Home Page

UAT-PNN-001-STEP-002 Click Login And See Login Form
    Open Chrome
    Go To    ${BASE_URL}
    Click Element    xpath=//a[@href='/login']
    Wait Until Element Is Visible    id=loginForm    10s
    Verify Login Page And Form

UAT-PNN-001-STEP-003 Admin Login And Go Dashboard
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Verify Admin Logged In And On Dashboard

UAT-PNN-001-STEP-004 Open Monitor And See Tabs
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify Monitor Tabs Exist

UAT-PNN-001-STEP-005 Verify AuditLog Header And Active Tab
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify AuditLog Header

UAT-PNN-001-STEP-006 Verify AuditLog Table Columns
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify AuditLog Columns

UAT-PNN-001-STEP-007 Verify AuditLog Data Exists
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify AuditLog Has At Least 1 Row

UAT-PNN-001-STEP-008 Verify And Click Export CSV
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AuditLog
    Click Export CSV Button And Verify Download

UAT-PNN-001-STEP-009 Verify And Click Export JSON
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AuditLog
    Click Export JSON Button And Verify Download

UAT-PNN-001-STEP-010 Verify And Click Export PDF
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AuditLog
    Click Export PDF Button And Verify Download

UAT-PNN-001 Admin View Audit Log
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify AuditLog
    Verify AuditLog Has At Least 1 Row
    Click Export CSV Button And Verify Download

# ---------------------------
# UAT-PNN-002 System Log Steps
# ---------------------------
UAT-PNN-002-STEP-001 Open Home Page
    Open Chrome
    Go To    ${BASE_URL}
    Verify Home Page

UAT-PNN-002-STEP-002 Click Login And See Login Form
    Open Chrome
    Go To    ${BASE_URL}
    Click Element    xpath=//a[@href='/login']
    Wait Until Element Is Visible    id=loginForm    10s
    Verify Login Page And Form

UAT-PNN-002-STEP-003 Admin Login And Go Dashboard
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Verify Admin Logged In And On Dashboard

UAT-PNN-002-STEP-004 Open Monitor And See Tabs
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify Monitor Tabs Exist

UAT-PNN-002-STEP-005 Verify SystemLog Header
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Verify SystemLog Header

UAT-PNN-002-STEP-006 Verify SystemLog Table Columns
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Verify SystemLog Columns

UAT-PNN-002-STEP-007 Verify SystemLog Data Exists
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Verify SystemLog Has At Least 1 Row

UAT-PNN-002-STEP-008 Verify And Click Export CSV
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Click Export CSV Button And Verify Download

UAT-PNN-002-STEP-009 Verify And Click Export JSON
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Click Export JSON Button And Verify Download

UAT-PNN-002-STEP-010 Verify And Click Export PDF
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Click Export PDF Button And Verify Download

UAT-PNN-002 Admin View System Log
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    SystemLog
    Verify SystemLog
    Verify SystemLog Has At Least 1 Row
    Click Export CSV Button And Verify Download

# ---------------------------
# UAT-PNN-003 Access Log Steps
# ---------------------------
UAT-PNN-003-STEP-001 Open Home Page
    Open Chrome
    Go To    ${BASE_URL}
    Verify Home Page

UAT-PNN-003-STEP-002 Click Login And See Login Form
    Open Chrome
    Go To    ${BASE_URL}
    Click Element    xpath=//a[@href='/login']
    Wait Until Element Is Visible    id=loginForm    10s
    Verify Login Page And Form

UAT-PNN-003-STEP-003 Admin Login And Go Dashboard
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Verify Admin Logged In And On Dashboard

UAT-PNN-003-STEP-004 Open Monitor And See Tabs
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Verify Monitor Tabs Exist

UAT-PNN-003-STEP-005 Verify AccessLog Header
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Verify AccessLog Header

UAT-PNN-003-STEP-006 Verify AccessLog Table Columns
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Verify AccessLog Columns

UAT-PNN-003-STEP-007 Verify AccessLog Data Exists
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Verify AccessLog Has At Least 1 Row

UAT-PNN-003-STEP-008 Verify And Click Export CSV
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Click Export CSV Button And Verify Download

UAT-PNN-003-STEP-009 Verify And Click Export JSON
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Click Export JSON Button And Verify Download

UAT-PNN-003-STEP-010 Verify And Click Export PDF
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Click Export PDF Button And Verify Download

UAT-PNN-003 Admin View Access Log
    Open Chrome
    Go To Login Page
    Login As Admin And Go Dashboard
    Open Monitor Page
    Switch Monitor Tab    AccessLog
    Verify AccessLog
    Verify AccessLog Has At Least 1 Row
    Click Export CSV Button And Verify Download

# ---------------------------
# UAT-PNN-004 User Request Data Log
# ---------------------------
UAT-PNN-004 User Request Data Log
    Open Chrome in Incognito Mode
    Go To Login Page
    Login As User
    Sleep    3s
    Go To    ${BASE_URL}profile/logs
    Wait Until Location Contains    /profile/logs    10s
    Submit User Data Request    CSV
    Sleep    2s
    Submit User Data Request    JSON
    Sleep    2s
    Submit User Data Request    PDF
    Sleep    2s
    Logout
    Sleep    2s

    Go To Login Page
    Login As Admin And Go Dashboard
    Go To    ${BASE_URL}admin/exports
    Wait Until Location Contains    /admin/exports    10s
    Approve Export Request By Format    CSV
    Sleep    2s
    Go To    ${BASE_URL}
    Sleep    2s
    Logout
    Sleep    1s

    Go To Login Page
    Login As User
    Go To    ${BASE_URL}profile/logs
    Wait Until Location Contains    /profile/logs    10s
    Download User File By Format    CSV
    Sleep    2s