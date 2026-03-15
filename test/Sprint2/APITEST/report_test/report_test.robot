*** Settings ***
Documentation     Report System API Test - Essential Cases Only
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Setup Session and Login

*** Variables ***
${BASE_URL}              https://csse1469.cpkku.com
${SESSION_ALIAS}         api

${REPORTER_USER}         reporttester01
${REPORTER_PASS}         123456789
${REPORTED_USER}         reporttester02
${REPORTED_PASS}         123456789
${ADMIN_USER}            admin123
${ADMIN_PASS}            123456789

${REPORTER_TOKEN}        ${EMPTY}
${REPORTED_TOKEN}        ${EMPTY}
${REPORTED_USER_ID}      ${EMPTY}
${ADMIN_TOKEN}           ${EMPTY}
${CREATED_REPORT_ID}     ${EMPTY}

*** Test Cases ***
# ============================================================
#  CREATE REPORT — สร้างรีพอร์ต
# ============================================================

Create Report Simple Case
    [Documentation]    สร้างรีพอร์ตแจ้งคนเดียว (Positive)
    [Tags]    CreateReport
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${reported_ids}=    Create List    ${REPORTED_USER_ID}
    ${body}=    Create Dictionary
    ...    reportedUserIds=${reported_ids}
    ...    category=DANGEROUS_DRIVING
    ...    description=คนขับขับรถเร็วเกินกำหนดมากและปาดซ้ายปาดขวาตลอดทาง
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports    json=${body}    headers=${headers}    expected_status=anything
    Log    Status=${resp.status_code}
    Should Be Equal As Integers    ${resp.status_code}    201
    ${json}=    Evaluate    __import__('json').loads("""${resp.text}""")
    Should Be True    ${json}[success]
    # Try to get case ID from response, or fetch from /my endpoint
    ${has_cases}=    Evaluate    'cases' in $json and len($json['cases']) > 0
    Run Keyword If    ${has_cases}    Set Suite Variable    ${CREATED_REPORT_ID}    ${json}[cases][0][id]    ELSE    Get Report ID From Latest
    Log    Created Report ID: ${CREATED_REPORT_ID}
    Sleep    2s

Create Report Without Token Should Fail
    [Documentation]    สร้างรีพอร์ตโดยไม่มี Token ต้อง Fail 401
    [Tags]    CreateReport    Negative
    ${reported_ids}=    Create List    ${REPORTED_USER_ID}
    ${body}=    Create Dictionary
    ...    reportedUserIds=${reported_ids}
    ...    category=DANGEROUS_DRIVING
    ...    description=ทดสอบสร้างรีพอร์ตโดยไม่มี Token
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports    json=${body}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    401

Create Report Missing Required Fields
    [Documentation]    ส่ง description เล็กเกินไป ต้อง Fail 400
    [Tags]    CreateReport    Negative
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${reported_ids}=    Create List    ${REPORTED_USER_ID}
    ${body}=    Create Dictionary
    ...    reportedUserIds=${reported_ids}
    ...    category=OTHER
    ...    description=short
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    400

# ============================================================
#  ADD EVIDENCE — อัปโหลดหลักฐาน
# ============================================================

Add Single Evidence
    [Documentation]    อัปโหลดรูปภาพหลักฐาน (Positive)
    [Tags]    Evidence
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${evidence_item}=    Create Dictionary
    ...    type=IMAGE
    ...    url=https://res.cloudinary.com/demo/image/upload/v12345/evidence_test_1.jpg
    ...    fileName=evidence_test_1.jpg
    ...    mimeType=image/jpeg
    ...    fileSize=${1024000}
    ${evidence_list}=    Create List    ${evidence_item}
    ${body}=    Create Dictionary    evidences=${evidence_list}
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}/evidence    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    1s

Add Evidence Without Token Should Fail
    [Documentation]    อัปโหลดโดยไม่มี Token ต้อง 401
    [Tags]    Evidence    Negative
    ${evidence_item}=    Create Dictionary    type=IMAGE    url=https://example.com/img.jpg
    ${evidence_list}=    Create List    ${evidence_item}
    ${body}=    Create Dictionary    evidences=${evidence_list}
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}/evidence    json=${body}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    401

Add Too Many Images Should Fail
    [Documentation]    ส่ง IMAGE มากกว่า 3 ต้อง 400
    [Tags]    Evidence    Negative
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${ev1}=    Create Dictionary    type=IMAGE    url=https://example.com/1.jpg
    ${ev2}=    Create Dictionary    type=IMAGE    url=https://example.com/2.jpg
    ${ev3}=    Create Dictionary    type=IMAGE    url=https://example.com/3.jpg
    ${ev4}=    Create Dictionary    type=IMAGE    url=https://example.com/4.jpg
    ${evidence_list}=    Create List    ${ev1}    ${ev2}    ${ev3}    ${ev4}
    ${body}=    Create Dictionary    evidences=${evidence_list}
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}/evidence    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    400

Add Evidence Multiple Times
    [Documentation]    อัปโหลดหลักฐานครั้งที่ 2 (สะสม)
    [Tags]    Evidence
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${evidence_item}=    Create Dictionary
    ...    type=IMAGE
    ...    url=https://res.cloudinary.com/demo/image/upload/v12345/evidence_test_2.jpg
    ...    fileName=evidence_test_2.jpg
    ...    mimeType=image/jpeg
    ...    fileSize=${1024000}
    ${evidence_list}=    Create List    ${evidence_item}
    ${body}=    Create Dictionary    evidences=${evidence_list}
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}/evidence    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    201
    Sleep    1s

Create Report With Invalid Category Should Fail
    [Documentation]    สร้างรีพอร์ตด้วย category ที่ไม่ถูกต้อง ต้อง 400
    [Tags]    CreateReport    Negative
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${reported_ids}=    Create List    ${REPORTED_USER_ID}
    ${body}=    Create Dictionary
    ...    reportedUserIds=${reported_ids}
    ...    category=INVALID_CATEGORY
    ...    description=ทดสอบส่ง category ที่ไม่ถูกต้อง
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    400

# ============================================================
#  GET REPORTS — ดูประวัติรีพอร์ต
# ============================================================

Get My Reports
    [Documentation]    ผู้ร้องเรียนดูประวัติที่ตัวเองแจ้งไว้
    [Tags]    GetReports
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/my    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Set Variable    ${resp.json()}
    Should Be True    ${json['success']}


Get Reports Without Token Should Fail
    [Documentation]    ดูประวัติโดยไม่มี Token ต้อง 401
    [Tags]    GetReports    Negative
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/my    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    401

Get Report By ID
    [Documentation]    ดูรายละเอียดรีพอร์ตเรื่องเดียว
    [Tags]    GetReports
    Sleep    1s
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200

Get Report By ID Without Token Should Fail
    [Documentation]    ดูรายละเอียดโดยไม่มี Token ต้อง 401
    [Tags]    GetReports    Negative
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    401

# ============================================================
#  ADMIN — จัดการเคส
# ============================================================

Admin Get All Reports
    [Documentation]    แอดมินดูรายการรีพอร์ตทั้งหมด
    [Tags]    Admin
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/admin/all    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200

Admin Assign Report
    [Documentation]    แอดมินกดรับเรื่องเคส (UNDER_REVIEW)
    [Tags]    Admin
    Sleep    1s
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${resp}=    PATCH On Session    ${SESSION_ALIAS}    url=/api/reports/admin/${CREATED_REPORT_ID}/assign    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200
    Sleep    1s

Admin Update To Resolved
    [Documentation]    แอดมินตัดสินเคส RESOLVED
    [Tags]    Admin
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${body}=    Create Dictionary
    ...    status=RESOLVED
    ...    adminNotes=ตรวจสอบเรียบร้อย
    ${resp}=    PATCH On Session    ${SESSION_ALIAS}    url=/api/reports/admin/${CREATED_REPORT_ID}/status    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200
    Sleep    1s

Admin Issue Yellow Card
    [Documentation]    แอดมินออกใบเหลืองให้ผู้กระทำผิด
    [Tags]    Admin
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${user_ids}=    Create List    ${REPORTED_USER_ID}
    ${body}=    Create Dictionary
    ...    userIds=${user_ids}
    ...    adminComment=ออกใบเหลืองเตือน
    ...    notificationType=WARNING_ISSUED
    ${resp}=    POST On Session    ${SESSION_ALIAS}    url=/api/reports/admin/${CREATED_REPORT_ID}/issue-yellow    json=${body}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200

# ============================================================
#  VERIFY — ตรวจสอบสถานะสุดท้าย
# ============================================================

Verify Final Report Status
    [Documentation]    ตรวจสอบเคสหลังจากผ่านทุกขั้นตอน
    [Tags]    Verify
    Sleep    1s
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/${CREATED_REPORT_ID}    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Set Variable    ${resp.json()}
    Should Be Equal As Strings    ${json['status']}    RESOLVED

*** Keywords ***
Setup Session and Login
    [Documentation]    สร้าง Session และ Login ทุก role
    Create Session    ${SESSION_ALIAS}    ${BASE_URL}    disable_warnings=1

    # --- Create Reporter User ---
    ${reporter_reg}=    Create Dictionary
    ...    username=${REPORTER_USER}
    ...    password=${REPORTER_PASS}
    ...    email=ploomn@test.com
    ...    firstName=Ploom
    ...    lastName=Noom
    ...    phoneNumber=0812345001
    ...    dateOfBirth=1995-05-15
    ...    gender=MALE
    ${resp_reg_reporter}=    POST On Session    ${SESSION_ALIAS}    url=/api/users    json=${reporter_reg}    expected_status=anything
    Log    Reporter Register: ${resp_reg_reporter.status_code}
    Sleep    0.5s

    # --- Create Reported User ---
    ${reported_reg}=    Create Dictionary
    ...    username=${REPORTED_USER}
    ...    password=${REPORTED_PASS}
    ...    email=test123@test.com
    ...    firstName=Test
    ...    lastName=User
    ...    phoneNumber=0812345002
    ...    dateOfBirth=1998-03-20
    ...    gender=FEMALE
    ${resp_reg_reported}=    POST On Session    ${SESSION_ALIAS}    url=/api/users    json=${reported_reg}    expected_status=anything
    Log    Reported User Register: ${resp_reg_reported.status_code}
    Sleep    0.5s

    # --- Login Reporter ---
    ${reporter_payload}=    Create Dictionary    username=${REPORTER_USER}    password=${REPORTER_PASS}
    ${resp_reporter}=    POST On Session    ${SESSION_ALIAS}    url=/api/auth/login    json=${reporter_payload}    expected_status=anything
    Log    Reporter Login (${resp_reporter.status_code}): ${resp_reporter.text}
    Run Keyword If    ${resp_reporter.status_code} == 200    Set Suite Variable    ${REPORTER_TOKEN}    ${resp_reporter.json()['data']['token']}
    Sleep    0.5s

    # --- Login Reported User ---
    ${reported_payload}=    Create Dictionary    username=${REPORTED_USER}    password=${REPORTED_PASS}
    ${resp_reported}=    POST On Session    ${SESSION_ALIAS}    url=/api/auth/login    json=${reported_payload}    expected_status=anything
    Log    Reported User Login (${resp_reported.status_code}): ${resp_reported.text}
    Run Keyword If    ${resp_reported.status_code} == 200    Set Suite Variable    ${REPORTED_TOKEN}    ${resp_reported.json()['data']['token']}
    ${reported_user_id}=    Run Keyword If    ${resp_reported.status_code} == 200    Extract User Id    ${resp_reported.json()}    ELSE    Set Variable    ${EMPTY}
    Run Keyword If    '${reported_user_id}' != '${EMPTY}'    Set Suite Variable    ${REPORTED_USER_ID}    ${reported_user_id}
    Sleep    0.5s

    # --- Login Admin ---
    ${admin_payload}=    Create Dictionary    username=${ADMIN_USER}    password=${ADMIN_PASS}
    ${resp_admin}=    POST On Session    ${SESSION_ALIAS}    url=/api/auth/login    json=${admin_payload}    expected_status=anything
    Log    Admin Login (${resp_admin.status_code}): ${resp_admin.text}
    Run Keyword If    ${resp_admin.status_code} == 200    Set Suite Variable    ${ADMIN_TOKEN}    ${resp_admin.json()['data']['token']}
    Sleep    0.5s

Extract User Id
    [Arguments]    ${json}
    ${has_user}=    Evaluate    'data' in $json and 'user' in $json['data'] and 'id' in $json['data']['user']
    Return From Keyword If    ${has_user}    ${json['data']['user']['id']}
    ${has_data_id}=    Evaluate    'data' in $json and 'id' in $json['data']
    Return From Keyword If    ${has_data_id}    ${json['data']['id']}
    ${has_id}=    Evaluate    'id' in $json
    Return From Keyword If    ${has_id}    ${json['id']}
    Fail    Cannot extract user ID from: ${json}

Get Report ID From Latest
    [Documentation]    ดึง Report ID จาก /api/reports/my (เมื่อ API response ไม่มี cases field)
    ${headers}=    Create Dictionary    Authorization=Bearer ${REPORTER_TOKEN}
    Sleep    1s
    ${resp}=    GET On Session    ${SESSION_ALIAS}    url=/api/reports/my    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Evaluate    __import__('json').loads("""${resp.text}""")
    ${data_list}=    Set Variable    ${json}[data]
    ${latest}=    Get From List    ${data_list}    0
    Set Suite Variable    ${CREATED_REPORT_ID}    ${latest}[id]
    Log    Got Report ID from /reports/my: ${CREATED_REPORT_ID}
