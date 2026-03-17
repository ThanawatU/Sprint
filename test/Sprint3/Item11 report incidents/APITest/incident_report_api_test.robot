*** Settings ***
Documentation     API Test Suite for Incident Report System
Library           RequestsLibrary
Library           Collections
Library           JSONLibrary

Suite Setup       Setup Tokens For Testing

*** Variables ***
${BASE_URL}         http://localhost:3000/api
${INCIDENT_URL}     ${BASE_URL}/incidents
${AUTH_URL}         ${BASE_URL}/auth/login

${ADMIN_USER}       admin@example.com          
${ADMIN_PASSWORD}   123456789
${DRIVER_USER}      tester1@gmail.com
${DRIVER_PASSWORD}  123456789

${ADMIN_TOKEN}      ${EMPTY}
${USER_TOKEN}       ${EMPTY}
${INCIDENT_ID}      ${EMPTY}
${INCIDENT_ID_2}    ${EMPTY}

*** Keywords ***
Setup Tokens For Testing
    Create Session    api    ${BASE_URL}
    
    # Login as Driver
    ${user_payload}=    Create Dictionary    email=${DRIVER_USER}    password=${DRIVER_PASSWORD}
    ${user_resp}=       POST On Session    api    ${AUTH_URL}    json=${user_payload}    expected_status=200
    ${USER_TOKEN}=      Set Variable    ${user_resp.json()}[data][token]
    Set Suite Variable  ${USER_TOKEN}

    # Login as Admin
    ${admin_payload}=   Create Dictionary    email=${ADMIN_USER}    password=${ADMIN_PASSWORD}
    ${admin_resp}=      POST On Session    api    ${AUTH_URL}    json=${admin_payload}    expected_status=200
    ${ADMIN_TOKEN}=     Set Variable    ${admin_resp.json()}[data][token]
    Set Suite Variable  ${ADMIN_TOKEN}

*** Test Cases ***

# ฝั่งคนขับ (DRIVER)

1. User Should Be Able To Create An Incident
    [Documentation]    ผู้ใช้สร้างการแจ้งเหตุใหม่ (POST /) โดยไม่ส่ง Location
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    
    ${payload}=        Create Dictionary    category=ACCIDENT    description=รถชนท้ายกัน
    
    ${response}=       POST On Session    api    ${INCIDENT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${INCIDENT_ID}=    Set Variable    ${response.json()}[data][id]
    Set Suite Variable  ${INCIDENT_ID}

2. User Should Be Able To Get Their Own Incidents
    [Documentation]    ผู้ใช้ดึงประวัติการแจ้งเหตุของตัวเอง (GET /my)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}
    ${response}=       GET On Session    api    ${INCIDENT_URL}/my    headers=${headers}    expected_status=200

3. User Should Be Able To Get Incident By ID
    [Documentation]    ผู้ใช้ดูรายละเอียดเคสรายตัว (GET /:id)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}
    ${response}=       GET On Session    api    ${INCIDENT_URL}/${INCIDENT_ID}    headers=${headers}    expected_status=200

4. User Should Be Able To Add Evidence To Incident
    [Documentation]    ผู้ใช้อัปโหลดหลักฐานเพิ่มเติม (POST /:id/evidence)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    ${evidence}=       Create Dictionary    url=https://example.com/image.jpg    type=IMAGE
    ${evidence_list}=  Create List          ${evidence}
    ${payload}=        Create Dictionary    evidences=${evidence_list}
    
    ${response}=       POST On Session    api    ${INCIDENT_URL}/${INCIDENT_ID}/evidence    json=${payload}    headers=${headers}    expected_status=201

# ฝั่งแอดมิน (ADMIN)

5. Admin Should Be Able To Get All Incidents
    [Documentation]    แอดมินดึงรายการการแจ้งเหตุทั้งหมด (GET /admin/all)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=       GET On Session    api    ${INCIDENT_URL}/admin/all    headers=${headers}    expected_status=200
    
    ${length}=         Get Length    ${response.json()}
    Should Be True     ${length} > 0

6. Admin Should Be Able To Assign Incident
    [Documentation]    แอดมินรับเรื่องเคส (PATCH /admin/:id/assign)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=       PATCH On Session    api    ${INCIDENT_URL}/admin/${INCIDENT_ID}/assign    headers=${headers}    expected_status=200

7. Admin Should Be Able To Resolve Incident
    [Documentation]    แอดมินปิดเคส (PATCH /admin/:id/resolve)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}    Content-Type=application/json
    ${payload}=        Create Dictionary    adminNotes=ตรวจสอบและจัดการเรียบร้อยแล้ว
    ${response}=       PATCH On Session    api    ${INCIDENT_URL}/admin/${INCIDENT_ID}/resolve    json=${payload}    headers=${headers}    expected_status=200

# ทดสอบ Flow การ Cancel / Reject

8. Create Another Incident For Cancel And Reject Tests
    [Documentation]    สร้างเคสที่ 2 เพื่อเอาไว้เทสต์การ Cancel/Reject
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    
    # ✅ ลบ location ออก
    ${payload}=        Create Dictionary    category=OTHER    description=เคสสำหรับยกเลิก
    
    ${response}=       POST On Session    api    ${INCIDENT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    ${INCIDENT_ID_2}=  Set Variable    ${response.json()}[data][id]
    Set Suite Variable  ${INCIDENT_ID_2}

9. Admin Should Be Able To Reject Incident
    [Documentation]    แอดมินปัดตกเคส (PATCH /admin/:id/reject)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}    Content-Type=application/json
    ${payload}=        Create Dictionary    adminNotes=ข้อมูลไม่เพียงพอ
    ${response}=       PATCH On Session    api    ${INCIDENT_URL}/admin/${INCIDENT_ID_2}/reject    json=${payload}    headers=${headers}    expected_status=200

10. User Should Be Able To Cancel Their Own Incident
    [Documentation]    ผู้ใช้ยกเลิกการแจ้งเหตุของตัวเอง (PATCH /:id/cancel)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    
    # ✅ ลบ location ออก
    ${payload}=        Create Dictionary    category=OTHER    description=ผู้ใช้กดยกเลิกเอง
    
    ${create_resp}=    POST On Session    api    ${INCIDENT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    ${cancel_id}=      Set Variable    ${create_resp.json()}[data][id]
    
    ${response}=       PATCH On Session    api    ${INCIDENT_URL}/${cancel_id}/cancel    headers=${headers}    expected_status=200