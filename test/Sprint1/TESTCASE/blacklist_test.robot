*** Settings ***
Library           RequestsLibrary
Library           Collections

Suite Setup       Setup Admin Session

*** Variables ***
${BASE_URL}              http://localhost:3000
${SESSION_ALIAS}         admin_api
${ADMIN_USER}            admin123
${ADMIN_PASS}            123456789

# อัปเดต User ID ใหม่
${TARGET_USER_ID}        cmlp9wtno0000hh5tm9wid5ko

*** Test Cases ***
Complete Blacklist Lifecycle Workflow
    [Documentation]    TEST : Create -> Get -> Lift -> Add Evidence
    
    # 2. Create Blacklist
    ${body}=    Create Dictionary    
    ...    userId=${TARGET_USER_ID}
    ...    type=PASSENGER    
    ...    reason=Test    
    ...    suspendedUntil=${None}

    ${resp_create}=    POST On Session    ${SESSION_ALIAS}    /api/blacklists    json=${body}
    Status Should Be    201    ${resp_create}
    
    ${blacklist_id}=    Set Variable    ${resp_create.json()}[id]
    Set Suite Variable    ${CREATED_BLACKLIST_ID}    ${blacklist_id}
    Log To Console    \n[Step 2] Created Blacklist ID: ${CREATED_BLACKLIST_ID}

    # 3. GET All Blacklists
    ${resp_all}=    GET On Session    ${SESSION_ALIAS}    /api/blacklists
    Status Should Be    200    ${resp_all}
    
    # ดึงเฉพาะ id ทั้งหมดในลิสต์ออกมาเป็น list ใหม่
    ${all_ids}=    Evaluate    [item['id'] for item in $resp_all.json()]
    List Should Contain Value    ${all_ids}    ${CREATED_BLACKLIST_ID}
    Log To Console    [Step 3] Get All Success (Found ID in list)

    # 4. GET Blacklist by User ID
    ${resp_user}=    GET On Session    ${SESSION_ALIAS}    /api/blacklists/${TARGET_USER_ID}
    Status Should Be    200    ${resp_user}
    # เช็คว่าคนแรกในลิสต์ (index 0) มี userId ตรงกับที่เราส่งไป
    Should Be Equal As Strings    ${resp_user.json()}[0][userId]    ${TARGET_USER_ID}
    Log To Console    [Step 4] Get By User ID Success

    # 5. PATCH Lift Blacklist
    ${resp_lift}=    PATCH On Session    ${SESSION_ALIAS}    /api/blacklists/${CREATED_BLACKLIST_ID}/lift
    Status Should Be    200    ${resp_lift}
    Log To Console    [Step 5] Lift Blacklist Success

    # 6. POST Add Evidence
    ${evidence_body}=    Create Dictionary    
    ...    type=IMAGE    
    ...    url=https://www.youtube.com/watch?v=dQw4w9WgXcQ
    
    ${resp_evidence}=    POST On Session    ${SESSION_ALIAS}    /api/blacklists/${CREATED_BLACKLIST_ID}/evidence    json=${evidence_body}
    Status Should Be    201    ${resp_evidence}
    Log To Console    [Step 6] Add Evidence Success

*** Keywords ***
Setup Admin Session
    Create Session    ${SESSION_ALIAS}    ${BASE_URL}    disable_warnings=1
    ${login_payload}=    Create Dictionary    username=${ADMIN_USER}    password=${ADMIN_PASS}
    ${resp}=    POST On Session    ${SESSION_ALIAS}    /api/auth/login    json=${login_payload}
    Status Should Be    200    ${resp}
    
    ${token}=    Set Variable    ${resp.json()}[data][token]
    ${auth_header}=    Create Dictionary    Authorization=Bearer ${token}
    Update Session    ${SESSION_ALIAS}    headers=${auth_header}