*** Settings ***
Documentation     API Test Suite for Report System (User & Admin Flows)
Library           RequestsLibrary
Library           Collections
Library           JSONLibrary

Suite Setup       Setup Tokens And Users For Testing

*** Variables ***
${BASE_URL}         https://deploy-production-88fa.up.railway.app/api
${REPORT_URL}       ${BASE_URL}/reports
${ROUTES_URL}       ${BASE_URL}/routes
${BOOKINGS_URL}     ${BASE_URL}/bookings
${AUTH_URL}         ${BASE_URL}/auth/login

# ข้อมูลสำหรับ Login
${ADMIN_USER}       admin@example.com          
${ADMIN_PASSWORD}   123456789
${DRIVER_USER}      tester1@ex.com
${DRIVER_PASSWORD}  123456789
${USER2_EMAIL}      tester2@ex.com
${USER2_PASSWORD}   123456789
${USER3_EMAIL}      tester3@ex.com
${USER3_PASSWORD}   123456789

${VEHICLE_ID}       cmmuoy3e60028fncl0x87myhn

# ตัวแปรสำหรับเก็บค่าแบบ Dynamic
${ADMIN_TOKEN}      ${EMPTY}
${USER_TOKEN}       ${EMPTY}
${USER2_TOKEN}      ${EMPTY}
${USER3_TOKEN}      ${EMPTY}
${USER1_ID}         ${EMPTY}
${USER2_ID}         ${EMPTY}
${USER3_ID}         ${EMPTY}
${ROUTE_ID}         ${EMPTY}
${BOOKING_ID}       ${EMPTY}
${BOOKING_ID_2}     ${EMPTY}
${REPORT_ID}        ${EMPTY}
${REPORT_ID_2}      ${EMPTY}
${GROUP_REPORT_ID}  ${EMPTY}

*** Keywords ***
Setup Tokens And Users For Testing
    [Documentation]    ล็อกอินเพื่อขอ Token และดึง ID ของผู้ใช้คนอื่นๆ มาเตรียมไว้
    Create Session    api    ${BASE_URL}
    
    # 1. Login as Main User (Driver)
    ${user_payload}=    Create Dictionary    email=${DRIVER_USER}    password=${DRIVER_PASSWORD}
    ${user_resp}=       POST On Session    api    ${AUTH_URL}    json=${user_payload}    expected_status=200
    ${USER_TOKEN}=      Set Variable    ${user_resp.json()}[data][token]
    Set Suite Variable  ${USER_TOKEN}
    ${USER1_ID}=        Set Variable    ${user_resp.json()}[data][user][id]
    Set Suite Variable  ${USER1_ID}

    # 2. Login as User 2 (Passenger 1)
    ${u2_payload}=      Create Dictionary    email=${USER2_EMAIL}    password=${USER2_PASSWORD}
    ${u2_resp}=         POST On Session    api    ${AUTH_URL}    json=${u2_payload}    expected_status=200
    ${USER2_ID}=        Set Variable    ${u2_resp.json()}[data][user][id]
    Set Suite Variable  ${USER2_ID}
    ${USER2_TOKEN}=     Set Variable    ${u2_resp.json()}[data][token]
    Set Suite Variable  ${USER2_TOKEN}
    
    # 3. Login as User 3 (Passenger 2)
    ${u3_payload}=      Create Dictionary    email=${USER3_EMAIL}    password=${USER3_PASSWORD}
    ${u3_resp}=         POST On Session    api    ${AUTH_URL}    json=${u3_payload}    expected_status=200
    ${USER3_ID}=        Set Variable    ${u3_resp.json()}[data][user][id]
    Set Suite Variable  ${USER3_ID}
    ${USER3_TOKEN}=     Set Variable    ${u3_resp.json()}[data][token]
    Set Suite Variable  ${USER3_TOKEN}

    # 4. Login as Admin
    ${admin_payload}=   Create Dictionary    email=${ADMIN_USER}    password=${ADMIN_PASSWORD}
    ${admin_resp}=      POST On Session    api    ${AUTH_URL}    json=${admin_payload}    expected_status=200
    ${ADMIN_TOKEN}=     Set Variable    ${admin_resp.json()}[data][token]
    Set Suite Variable  ${ADMIN_TOKEN}

*** Test Cases ***

# เตรียมข้อมูล: สร้าง Route และ Booking

0.1 Driver Should Be Able To Create A Route
    [Documentation]    Driver สร้างเส้นทางเพื่อเอา routeId
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    ${start_loc}=      Create Dictionary    lat=${13.75}    lng=${100.50}    address=Bangkok
    ${end_loc}=        Create Dictionary    lat=${14.00}    lng=${100.60}    address=Pathum
    
    ${payload}=        Create Dictionary    startLocation=${start_loc}    endLocation=${end_loc}    departureTime=2026-12-31T10:00:00.000Z    availableSeats=${4}    pricePerSeat=${100}    vehicleId=${VEHICLE_ID}
    
    ${response}=       POST On Session    api    ${ROUTES_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${ROUTE_ID}=       Set Variable    ${response.json()}[data][id]
    Set Suite Variable  ${ROUTE_ID}

0.2 Passenger 1 Should Be Able To Create A Booking
    [Documentation]    Passenger 1 (User 2) สร้างการจองเพื่อเอา bookingId
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER2_TOKEN}    Content-Type=application/json
    ${pickup}=         Create Dictionary    lat=${13.76}    lng=${100.51}    address=Pickup
    ${dropoff}=        Create Dictionary    lat=${13.99}    lng=${100.59}    address=Dropoff
    
    ${payload}=        Create Dictionary    routeId=${ROUTE_ID}    pickupLocation=${pickup}    dropoffLocation=${dropoff}    numberOfSeats=${1}
    
    ${response}=       POST On Session    api    ${BOOKINGS_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${BOOKING_ID}=     Set Variable    ${response.json()}[data][id]
    Set Suite Variable  ${BOOKING_ID}

0.3 Passenger 2 Should Be Able To Create A Booking
    [Documentation]    Passenger 2 (User 3) สร้างการจองเพื่อเอา bookingId
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER3_TOKEN}    Content-Type=application/json
    ${pickup}=         Create Dictionary    lat=${13.76}    lng=${100.51}    address=Pickup
    ${dropoff}=        Create Dictionary    lat=${13.99}    lng=${100.59}    address=Dropoff
    
    ${payload}=        Create Dictionary    routeId=${ROUTE_ID}    pickupLocation=${pickup}    dropoffLocation=${dropoff}    numberOfSeats=${1}
    
    ${response}=       POST On Session    api    ${BOOKINGS_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${BOOKING_ID_2}=   Set Variable    ${response.json()}[data][id]
    Set Suite Variable  ${BOOKING_ID_2}

# ฝั่งผู้ใช้งานทั่วไป (USER) - ระบบ Report

1. User Should Be Able To Create A Single Report
    [Documentation]    Driver รีพอร์ต Passenger 1 (POST /)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    ${reported_users}=  Create List    ${USER2_ID}
    ${payload}=        Create Dictionary    category=DANGEROUS_DRIVING    description=พูดจาไม่สุภาพ    routeId=${ROUTE_ID}    bookingId=${BOOKING_ID}    reportedUserIds=${reported_users}
    
    ${response}=       POST On Session    api    ${REPORT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${REPORT_ID}=      Set Variable    ${response.json()}[cases][0][id]
    Set Suite Variable  ${REPORT_ID}

2. User Should Be Able To Create A Group Report (Multiple Users)
    [Documentation]    Passenger 1 (User 2) รีพอร์ต Driver และ Passenger 2
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER2_TOKEN}    Content-Type=application/json
    ${reported_users}=  Create List    ${USER1_ID}    ${USER3_ID}
    ${payload}=        Create Dictionary    category=DANGEROUS_DRIVING    description=สร้างความเดือดร้อนในรถ    routeId=${ROUTE_ID}    bookingId=${BOOKING_ID}    reportedUserIds=${reported_users}
    
    ${response}=       POST On Session    api    ${REPORT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${GROUP_REPORT_ID}=  Set Variable    ${response.json()}[cases][0][id]
    Set Suite Variable  ${GROUP_REPORT_ID}

3. User Should Be Able To Get Their Own Reports
    [Documentation]    ผู้ใช้ดึงประวัติที่ตัวเองรีพอร์ตคนอื่น (GET /my)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/my    headers=${headers}    expected_status=200

4. User Should Be Able To Get Reports Against Them
    [Documentation]    เป้าหมาย(User 2) ตรวจสอบประวัติที่ตัวเองถูกรีพอร์ต (GET /against-me)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER2_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/against-me    headers=${headers}    expected_status=200

5. User Should Be Able To Get Report By ID
    [Documentation]    ผู้ใช้ดูรายละเอียด Report รายเคส (GET /:id)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/${REPORT_ID}    headers=${headers}    expected_status=200

6. User Should Be Able To Get Reports By Route ID
    [Documentation]    ดึงรายงานทั้งหมดใน Trip นั้น (GET /route/:routeId)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/route/${ROUTE_ID}    headers=${headers}    expected_status=200

7. User Should Be Able To Add Evidence To Report
    [Documentation]    ผู้ใช้อัปโหลดหลักฐาน (POST /:id/evidence)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER_TOKEN}    Content-Type=application/json
    ${evidence}=       Create Dictionary    url=https://example.com/chat-log.jpg    type=IMAGE
    ${evidence_list}=  Create List          ${evidence}
    ${payload}=        Create Dictionary    evidences=${evidence_list}
    
    ${response}=       POST On Session    api    ${REPORT_URL}/${REPORT_ID}/evidence    json=${payload}    headers=${headers}    expected_status=201


# ฝั่งแอดมิน (ADMIN)

8. Admin Should Be Able To Get Trips With Reports
    [Documentation]    แอดมินดึงรายการ Trip ที่มีคนรีพอร์ต (GET /admin/trips)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/admin/trips    headers=${headers}    expected_status=200

9. Admin Should Be Able To Get All Reports
    [Documentation]    แอดมินดึงรายการรีพอร์ตทั้งหมด (GET /admin/all)
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=       GET On Session    api    ${REPORT_URL}/admin/all    headers=${headers}    expected_status=200

10. Admin Should Be Able To Assign Report
    [Documentation]    แอดมินรับเรื่องเคส (PATCH /admin/:id/assign) -> UNDER_REVIEW
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=       PATCH On Session    api    ${REPORT_URL}/admin/${REPORT_ID}/assign    headers=${headers}    expected_status=200

11. Admin Should Be Able To Resolve Report
    [Documentation]    แอดมินอนุมัติเคส (PATCH /admin/:id/resolve) -> RESOLVED
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}    Content-Type=application/json
    ${payload}=        Create Dictionary    adminNotes=แจกใบเหลืองเรียบร้อย
    ${response}=       PATCH On Session    api    ${REPORT_URL}/admin/${REPORT_ID}/resolve    json=${payload}    headers=${headers}    expected_status=200


# ทดสอบ Flow การ Cancel / Reject

12. Create Another Report For Reject Test
    [Documentation]    สร้างเคสที่ 3 เพื่อให้แอดมินปัดตก (Passenger 2 รีพอร์ต Driver)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER3_TOKEN}    Content-Type=application/json
    ${reported_users}=  Create List    ${USER1_ID}
    ${payload}=        Create Dictionary    category=DANGEROUS_DRIVING    description=เคสสำหรับทดสอบปัดตก    routeId=${ROUTE_ID}    bookingId=${BOOKING_ID_2}    reportedUserIds=${reported_users}
    
    ${response}=       POST On Session    api    ${REPORT_URL}/    json=${payload}    headers=${headers}    expected_status=201
    
    ${REPORT_ID_2}=    Set Variable    ${response.json()}[cases][0][id]
    Set Suite Variable  ${REPORT_ID_2}

13. Admin Should Be Able To Reject Report
    [Documentation]    แอดมินปฏิเสธเคส (PATCH /admin/:id/reject) -> REJECTED
    ${headers}=        Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}    Content-Type=application/json
    ${payload}=        Create Dictionary    adminNotes=หลักฐานไม่เพียงพอ
    ${response}=       PATCH On Session    api    ${REPORT_URL}/admin/${REPORT_ID_2}/reject    json=${payload}    headers=${headers}    expected_status=200

14. User Should Be Able To Cancel Their Own Report
    [Documentation]    ผู้ใช้ยกเลิกรีพอร์ตของตัวเอง (PATCH /:id/cancel)
    ${headers}=        Create Dictionary    Authorization=Bearer ${USER2_TOKEN}
    
    ${response}=       PATCH On Session    api    ${REPORT_URL}/${GROUP_REPORT_ID}/cancel    headers=${headers}    expected_status=200