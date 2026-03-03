*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}             http://localhost:3000/api
${USER_NAME}            nutho04
${USER_ID}              cmmamd1b2001hesfwwe4kvm49  # 🚀 ต้องมี ID ของ User ด้วย
${USER_PASSWORD}        0123456789
${ADMIN_NAME}           admin123
${ADMIN_PASSWORD}       123456789

*** Test Cases ***

Scenario 1: User Request -> Admin Approve -> User Download
    Create Session    api    ${BASE_URL}

    ${user_token}=    Login    ${USER_NAME}    ${USER_PASSWORD}
    ${user_headers}=    Create Dictionary    Authorization=Bearer ${user_token}
    
    ${filters}=    Create Dictionary    reason=User request test    userId=${USER_ID}
    ${payload}=    Create Dictionary    logType=AuditLog    format=PDF    filters=${filters}
    
    ${resp}=    POST On Session    api    /logs/exports    json=${payload}    headers=${user_headers}
    Status Should Be    201    ${resp}
    ${export_id}=    Set Variable    ${resp.json()['data']['id']}
    Set Suite Variable    ${ID_S1}    ${export_id}

    ${admin_token}=    Login    ${ADMIN_NAME}    ${ADMIN_PASSWORD}
    ${admin_headers}=    Create Dictionary    Authorization=Bearer ${admin_token}
    ${body}=    Create Dictionary    status=APPROVED
    ${approve}=    PATCH On Session    api    /logs/exports/${export_id}/review    json=${body}    headers=${admin_headers}
    Status Should Be    200    ${approve}

    ${dl}=    GET On Session    api    /logs/exports/${export_id}/download    headers=${user_headers}
    Status Should Be    200    ${dl}

Scenario 2: Admin Request -> Admin Download
    ${admin_token}=    Login    ${ADMIN_NAME}    ${ADMIN_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${admin_token}

    ${filters}=    Create Dictionary    reason=Admin system check
    ${payload}=    Create Dictionary    logType=SystemLog    format=CSV    filters=${filters}
    ${resp}=    POST On Session    api    /logs/exports    json=${payload}    headers=${headers}
    Status Should Be    201    ${resp}
    ${export_id}=    Set Variable    ${resp.json()['data']['id']}

    ${body}=    Create Dictionary    status=APPROVED
    PATCH On Session    api    /logs/exports/${export_id}/review    json=${body}    headers=${headers}

    ${dl}=    GET On Session    api    /logs/exports/${export_id}/download    headers=${headers}
    Status Should Be    200    ${dl}

Scenario 3: Admin Download User Request
    ${admin_token}=    Login    ${ADMIN_NAME}    ${ADMIN_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${admin_token}
    ${dl}=    GET On Session    api    /logs/exports/${ID_S1}/download    headers=${headers}
    Status Should Be    200    ${dl}

*** Keywords ***

Login
    [Arguments]    ${user}    ${pass}
    ${body}=    Create Dictionary    username=${user}    password=${pass}
    ${res}=    POST On Session    api    /auth/login    json=${body}
    # ตรวจสอบโครงสร้าง data.token ตาม auth.controller.js
    RETURN    ${res.json()['data']['token']}