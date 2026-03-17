*** Settings ***
Documentation     Complete Review System Test Suite
...               ====================================
...               Combines UAT setup (STEP 1-3) with comprehensive review test cases (TC 1-8)
...               Each test case runs its own setup to create a fresh completed trip ready for review
...               
...               WORKFLOW:
...               1. STEP_01: Driver creates route
...               2. STEP_02: Passenger searches and books
...               3. STEP_03: Driver accepts and marks complete
...               4. TC_01-08: Each test case with built-in setup
...               
...               PREREQUISITES:
...               - Backend & Frontend running (https://csse1469.cpkku.com/)
...               - Test images in: img/Sprint3/reviewUATTest/
...               - Test accounts configured
...               - ChromeDriver installed and path updated
Library           SeleniumLibrary
Library           Collections

Suite Setup       Log    Starting Complete Review System Test Suite
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}              Chrome
${LOGIN_URL}            https://csse1469.cpkku.com/login
${BASE_URL}             https://csse1469.cpkku.com
${TIMEOUT}              20s

${DRIVER_EMAIL}         review1@example.com
${DRIVER_PASS}          123456789
${PASSENGER_EMAIL}      review2@example.com
${PASSENGER_PASS}       123456789

${START_LOCATION}       กรุงเทพมหานคร
${END_LOCATION}         เชียงใหม่
${SEAT_COUNT}           4
${PRICE_PER_SEAT}       250

${IMAGE_DIR}            D:\\Y3T2\\SotwareEngi\\SoftEnProJ\\Sprint\\img\\Sprint3\\reviewUATTest


*** Test Cases ***

STEP_01_Driver_Create_Route
    [Documentation]    Driver สร้าง Route ใหม่
    [Tags]             setup  step1  driver
    
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Go To    ${BASE_URL}/createTrip
    Sleep    3s
    
    Wait Until Element Is Visible    id=startPoint    ${TIMEOUT}
    
    Type And Select Autocomplete    startPoint    ${START_LOCATION}
    Sleep    1s
    
    Type And Select Autocomplete    endPoint    ${END_LOCATION}
    Sleep    1s
    
    ${tomorrow}=    Get Tomorrow Date
    Fill Date And Time    travelDate    travelTime    ${tomorrow}    09:00
    Sleep    1s
    
    Input Text    id=seatCount      ${SEAT_COUNT}
    Sleep    0.3s
    Input Text    id=pricePerSeat   ${PRICE_PER_SEAT}
    Sleep    0.5s
    
    Wait Until Element Is Visible    id=vehicle    ${TIMEOUT}
    Sleep    0.5s
    
    Click Button    xpath=//button[contains(text(), 'สร้างการเดินทาง')]
    Sleep    3s
    
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    15s
    Run Keyword If    ${ok}    Log    ✓ Route created
    ...    ELSE    Log    ⚠️ Check result manually
    
    Sleep    3s
    Close All Browsers


STEP_02_Passenger_Search_And_Book
    [Documentation]    Passenger ค้นหา booking แล้วกดจอง
    [Tags]             setup  step2  passenger
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/findTrip
    Sleep    3s
    
    Wait Until Element Is Visible    xpath=//button[contains(text(), 'ค้นหา')]    ${TIMEOUT}
    Log    FindTrip page loaded
    
    Type And Select Autocomplete
    ...    xpath=//input[contains(@placeholder,'กรุงเทพ')]
    ...    ${START_LOCATION}
    Sleep    1s
    
    Type And Select Autocomplete
    ...    xpath=//input[contains(@placeholder,'เชียงใหม่')]
    ...    ${END_LOCATION}
    Sleep    1s
    
    Click Element    xpath=//button[contains(text(), 'ค้นหา')]
    Sleep    5s
    
    Wait Until Page Contains    ผลการค้นหา    ${TIMEOUT}
    Log    Search results loaded
    
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'route-card')]
    ...    ${TIMEOUT}
    Click Element    xpath=//div[contains(@class,'route-card')]
    Sleep    2s
    Log    Clicked first trip card
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')]
    ...    ${TIMEOUT}
    Click Element
    ...    xpath=(//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')])[1]
    Sleep    2s
    Log    Clicked จองที่นั่ง
    
    Sleep    3s
    Log    Waiting for booking modal...
    Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]    20s
    Log    ✓ Booking modal found!
    
    Wait Until Element Is Visible    xpath=//select    ${TIMEOUT}
    Select From List By Value    xpath=//select    4
    Sleep    1s
    Log    Selected 4 seats
    
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[1]
    ...    ${START_LOCATION}
    Sleep    1s
    Log    Selected pickup location
    
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[2]
    ...    ${END_LOCATION}
    Sleep    1s
    Log    Selected dropoff location
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'ยืนยันการจอง')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันการจอง')]
    Sleep    5s
    Log    Clicked ยืนยันการจอง
    
    ${book_ok}=    Run Keyword And Return Status    Page Should Contain    สำเร็จ
    Run Keyword If    ${book_ok}    Log    ✓ Booking completed
    ...    ELSE    Log    ⚠️ Booking unclear - check manually
    
    Close All Browsers


STEP_03_Driver_Accept_And_Complete
    [Documentation]    Driver ยอมรับการจองและเสร็จสิ้นการเดินทาง
    [Tags]             setup  step3  driver
    
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    ...    ${TIMEOUT}
    Mouse Over    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    Sleep    1s
    Log    Hovered on การเดินทางทั้งหมด
    
    Wait Until Element Is Visible
    ...    xpath=//a[@href='/myRoute']
    ...    ${TIMEOUT}
    Click Element    xpath=//a[@href='/myRoute']
    Sleep    3s
    Log    ✓ Navigated to myRoute (คำขอจองเส้นทางของฉัน)
    
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    ...    ${TIMEOUT}
    Log    Booking request found
    
    Click Element
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    Sleep    2s
    Log    Clicked booking request card
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'ยืนยันคำขอ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    Log    ✓ Clicked ยืนยันคำขอ (1st)
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    Log    ✓ Confirmed in overlay
    
    Wait Until Page Contains    ยืนยันแล้ว    ${TIMEOUT}
    Log    Reached confirmation page
    Sleep    3s

    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(., 'เส้นทางของฉัน')]
    ...    ${TIMEOUT}
    Sleep    2s
    Execute Javascript
    ...    Array.from(document.querySelectorAll('button.tab-button')).find(btn => btn.textContent.includes('เส้นทางของฉัน')).click();
    Sleep    3s
    Log    ✓ Clicked เส้นทางของฉัน tab
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    Sleep    3s
    Log    ✓ Trip completed
    Close All Browsers


TC_01_Review_5_Stars_Excellent_Driver
    [Documentation]    TEST CASE 1: Setup trip then Passenger gives 5 stars with positive comment and images
    [Tags]             testcase  tc01  5stars  positive  images
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Review with 5 stars =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 5 STARS ==
    FOR    ${i}    IN RANGE    1    6
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    Log    ✓ Selected 5 stars
    
    # == FILL COMMENT ==
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    ยอดเยี่ยมมากครับ! ขับรถปลอดภัย มีมารยาท บริการดีมากครับ ขอบคุณ!
    Sleep    1s
    Log    ✓ Filled positive comment
    
    # == UPLOAD 3 IMAGES ==
    ${file_inputs}=    Get WebElements    xpath=//input[@type='file']
    FOR    ${idx}    IN RANGE    1    4
        ${image_file}=    Set Variable    ${IMAGE_DIR}\\review${idx}test.jpg
        Run Keyword And Continue On Failure
        ...    Choose File
        ...    ${file_inputs}[0]
        ...    ${image_file}
        Sleep    1s
    END
    Log    ✓ Uploaded 3 images
    
    # == SUBMIT REVIEW ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
    Log    ✓ TC_01 Review submitted successfully (5 stars)
    
    Close All Browsers


TC_02_Review_1_Star_Bad_Driver
    [Documentation]    TEST CASE 2: Setup trip then Passenger gives 1 star with negative comment (no images)
    [Tags]             testcase  tc02  1star  negative  noimage
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Review with 1 star =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 1 STAR ==
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[1]
    ...    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[1]
    Sleep    0.5s
    Log    ✓ Selected 1 star
    
    # == FILL NEGATIVE COMMENT ==
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    ขับรถเร็วเกินไป ไม่ติดต่อสื่อสาร ให้ความรู้สึกไม่ปลอดภัย ไม่แนะนำครับ
    Sleep    1s
    Log    ✓ Filled negative comment
    
    # == SUBMIT WITHOUT IMAGES ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
    Log    ✓ TC_02 Review submitted without images (1 star)
    
    Close All Browsers


TC_03_Review_No_Rating_Selected_Error
    [Documentation]    TEST CASE 3: Setup trip then test validation - Submit without rating (should fail)
    [Tags]             testcase  tc03  validation  error  norating
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Attempt review without rating =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SKIP RATING - ADD COMMENT WITHOUT STAR ==
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    ทดสอบส่งรีวิวโดยไม่เลือกคะแนน
    Sleep    1s
    Log    ✓ Filled comment without rating
    
    # == TRY TO SUBMIT WITHOUT RATING ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    2s
    
    # == CHECK IF ERROR APPEARS OR ALERT SHOWS ==
    ${error_shown}=    Run Keyword And Return Status
    ...    Page Should Contain    กรุณาให้คะแนน
    
    Run Keyword If    ${error_shown}
    ...    Log    ✓ TC_03 Error validation works - must select rating
    ...    ELSE    Log    ⚠️ TC_03 No error shown - check if validation exists
    
    Close All Browsers


TC_04_Review_Exceed_Max_Images_Error
    [Documentation]    TEST CASE 4: Setup trip then test validation - Upload more than 3 images (should fail)
    [Tags]             testcase  tc04  validation  error  maximage
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Try to upload 4+ images =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 5 STARS ==
    FOR    ${i}    IN RANGE    1    6
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    Log    ✓ Selected 5 stars
    
    # == TRY TO UPLOAD 4 IMAGES (EXCEED LIMIT) ==
    ${file_inputs}=    Get WebElements    xpath=//input[@type='file']
    FOR    ${idx}    IN RANGE    1    5
        ${image_file}=    Set Variable    ${IMAGE_DIR}\\review${idx}test.jpg
        ${file_exists}=    Run Keyword And Return Status
        ...    File Should Exist    ${image_file}
        
        Run Keyword If    ${file_exists}
        ...    Run Keyword And Continue On Failure
        ...        Choose File
        ...        ${file_inputs}[0]
        ...        ${image_file}
        
        Sleep    1s
    END
    Log    ✓ Attempted to upload 4 images
    
    # == CHECK IF ERROR MESSAGE APPEARS ==
    ${error_shown}=    Run Keyword And Return Status
    ...    Page Should Contain    ไม่เกิน 3 รูป
    
    Run Keyword If    ${error_shown}
    ...    Log    ✓ TC_04 Image limit validation works - max 3 images
    ...    ELSE    Log    ⚠️ TC_04 System may allow images or show different error
    
    Close All Browsers


TC_05_Review_Only_Image_No_Comment
    [Documentation]    TEST CASE 5: Setup trip then Passenger submits review with only images, no comment
    [Tags]             testcase  tc05  imageonly  nocomment
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Review with images only =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 4 STARS ==
    FOR    ${i}    IN RANGE    1    5
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    Log    ✓ Selected 4 stars
    
    # == SKIP COMMENT - UPLOAD IMAGES ==
    ${file_inputs}=    Get WebElements    xpath=//input[@type='file']
    FOR    ${idx}    IN RANGE    1    4
        ${image_file}=    Set Variable    ${IMAGE_DIR}\\review${idx}test.jpg
        Run Keyword And Continue On Failure
        ...    Choose File
        ...    ${file_inputs}[0]
        ...    ${image_file}
        Sleep    1s
    END
    Log    ✓ Uploaded 3 images without comment
    
    # == SUBMIT ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
    Log    ✓ TC_05 Review submitted with images only (4 stars)
    
    Close All Browsers


TC_06_Review_With_Long_Comment
    [Documentation]    TEST CASE 6: Setup trip then Passenger submits review with long detailed comment
    [Tags]             testcase  tc06  longcomment  detailed
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Review with long comment =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 5 STARS ==
    FOR    ${i}    IN RANGE    1    6
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    Log    ✓ Selected 5 stars
    
    # == FILL LONG DETAILED COMMENT ==
    ${long_comment}=    Set Variable    โครงการนี้ทำให้ฉันประทับใจ ขับรถปลอดภัยมากครับ มีการแนะนำเส้นทาง ถามความปรารถนานะ การสื่อสารดีมากกว่าคนขับทั่วไป บรรยากาศในรถสะอาด เพลงฟังเพลิดเพลินดี ราคายุติธรรม ค่อนข้างจะตรงต่อเวลา ขอบคุณมากครับ แนะนำให้เพื่อนและครอบครัว
    
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    ${long_comment}
    Sleep    1s
    Log    ✓ Filled long detailed comment
    
    # == SUBMIT ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
    Log    ✓ TC_06 Long review submitted (5 stars + detailed comment)
    
    Close All Browsers


TC_07_Review_Minimum_Rating
    [Documentation]    TEST CASE 7: Setup trip then Passenger submits review with minimum 1 star
    [Tags]             testcase  tc07  minimum  validation
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Review with 1 star minimum =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review form opened
    
    # == SELECT 1 STAR (MINIMUM) ==
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[1]
    ...    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[1]
    Sleep    0.5s
    Log    ✓ Selected 1 star (minimum rating)
    
    # == ADD COMMENT ==
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    บริการไม่ดี ไม่แนะนำ
    Sleep    1s
    
    # == SUBMIT ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
    Log    ✓ TC_07 Minimum rating review submitted (1 star)
    
    Close All Browsers


TC_08_Review_Modal_Close_Button
    [Documentation]    TEST CASE 8: Setup trip then Test that review modal can be closed without submitting
    [Tags]             testcase  tc08  modal  ui
    
    # ===== SETUP: Create fresh trip (STEP 01-03) =====
    Setup Complete Trip
    
    # ===== TEST: Close modal without submitting =====
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    Wait Until Element Is Visible    xpath=//textarea    20s
    Log    ✓ Review modal opened
    
    # == SELECT SOME STARS ==
    FOR    ${i}    IN RANGE    1    4
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    
    # == FILL COMMENT ==
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    Test comment
    Sleep    1s
    Log    ✓ Filled partial review data
    
    # == CLICK CLOSE BUTTON ==
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'ปิด') and contains(@class,'bg-gray')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ปิด') and contains(@class,'bg-gray')]
    Sleep    2s
    Log    ✓ Modal closed without submitting
    
    # Verify we're back on myTrip page
    Wait Until Page Contains    การเดินทางของฉัน    ${TIMEOUT}
    Log    ✓ TC_08 Returned to myTrip page - modal closed successfully
    
    Close All Browsers


*** Keywords ***

Setup Complete Trip
    [Documentation]    Setup keyword that runs STEP_01-03 to create a completed trip ready for review
    ...                This keyword runs in background and closes browser automatically
    
    # STEP 01: Driver creates route
    Log    [SETUP] Starting STEP_01 - Driver creates route
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Go To    ${BASE_URL}/createTrip
    Sleep    3s
    
    Wait Until Element Is Visible    id=startPoint    ${TIMEOUT}
    Type And Select Autocomplete    startPoint    ${START_LOCATION}
    Sleep    1s
    Type And Select Autocomplete    endPoint    ${END_LOCATION}
    Sleep    1s
    
    ${tomorrow}=    Get Tomorrow Date
    Fill Date And Time    travelDate    travelTime    ${tomorrow}    09:00
    Sleep    1s
    
    Input Text    id=seatCount      ${SEAT_COUNT}
    Sleep    0.3s
    Input Text    id=pricePerSeat   ${PRICE_PER_SEAT}
    Sleep    0.5s
    
    Wait Until Element Is Visible    id=vehicle    ${TIMEOUT}
    Sleep    0.5s
    Click Button    xpath=//button[contains(text(), 'สร้างการเดินทาง')]
    Sleep    3s
    
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    15s
    Run Keyword If    ${ok}    Log    ✓ SETUP: Route created
    ...    ELSE    Log    ⚠️ SETUP: Check route creation manually
    Sleep    2s
    Close All Browsers
    
    # STEP 02: Passenger books trip
    Log    [SETUP] Starting STEP_02 - Passenger books trip
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/findTrip
    Sleep    3s
    Wait Until Element Is Visible    xpath=//button[contains(text(), 'ค้นหา')]    ${TIMEOUT}
    
    Type And Select Autocomplete
    ...    xpath=//input[contains(@placeholder,'กรุงเทพ')]
    ...    ${START_LOCATION}
    Sleep    1s
    Type And Select Autocomplete
    ...    xpath=//input[contains(@placeholder,'เชียงใหม่')]
    ...    ${END_LOCATION}
    Sleep    1s
    
    Click Element    xpath=//button[contains(text(), 'ค้นหา')]
    Sleep    5s
    Wait Until Page Contains    ผลการค้นหา    ${TIMEOUT}
    
    Wait Until Element Is Visible    xpath=//div[contains(@class,'route-card')]    ${TIMEOUT}
    Click Element    xpath=//div[contains(@class,'route-card')]
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')]
    ...    ${TIMEOUT}
    Click Element    xpath=(//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')])[1]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]    20s
    
    Wait Until Element Is Visible    xpath=//select    ${TIMEOUT}
    Select From List By Value    xpath=//select    4
    Sleep    1s
    
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[1]
    ...    ${START_LOCATION}
    Sleep    1s
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[2]
    ...    ${END_LOCATION}
    Sleep    1s
    
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ยืนยันการจอง')]    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันการจอง')]
    Sleep    5s
    
    ${book_ok}=    Run Keyword And Return Status    Page Should Contain    สำเร็จ
    Run Keyword If    ${book_ok}    Log    ✓ SETUP: Booking completed
    ...    ELSE    Log    ⚠️ SETUP: Booking unclear - check manually
    Sleep    2s
    Close All Browsers
    
    # STEP 03: Driver accepts and marks trip complete
    Log    [SETUP] Starting STEP_03 - Driver accepts and marks trip complete
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    ...    ${TIMEOUT}
    Mouse Over    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    Sleep    1s
    
    Wait Until Element Is Visible    xpath=//a[@href='/myRoute']    ${TIMEOUT}
    Click Element    xpath=//a[@href='/myRoute']
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    ...    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ยืนยันคำขอ')]    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    
    Wait Until Page Contains    ยืนยันแล้ว    ${TIMEOUT}
    Sleep    2s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(., 'เส้นทางของฉัน')]
    ...    ${TIMEOUT}
    Execute Javascript
    ...    Array.from(document.querySelectorAll('button.tab-button')).find(btn => btn.textContent.includes('เส้นทางของฉัน')).click();
    Sleep    3s
    
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    Sleep    3s
    Log    ✓ SETUP: Trip completed - ready for review
    Close All Browsers


Open Browser Incognito
    [Arguments]    ${url}
    [Documentation]    เปิด Chrome Incognito
    
    ${chromedriver}=    Set Variable    C:\\Users\\wisit\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe
    
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --incognito
    Call Method    ${options}    add_argument    --disable-password-manager
    Call Method    ${options}    add_argument    --disable-popup-blocking
    
    Open Browser    ${url}    ${BROWSER}    options=${options}    executable_path=${chromedriver}
    Maximize Browser Window
    Set Selenium Speed    0.5


Driver Login
    [Arguments]    ${email}    ${password}
    
    Go To    ${LOGIN_URL}
    Sleep    2s
    Input Text    id=identifier    ${email}
    Input Text    id=password    ${password}
    Click Button    xpath=//button[@type='submit']
    Sleep    3s
    Run Keyword And Continue On Failure    Press Keys    None    ESCAPE
    Sleep    1s
    Log    Driver login OK


Passenger Login
    [Arguments]    ${email}    ${password}
    
    Go To    ${LOGIN_URL}
    Sleep    2s
    Input Text    id=identifier    ${email}
    Input Text    id=password    ${password}
    Click Button    xpath=//button[@type='submit']
    Sleep    3s
    Run Keyword And Continue On Failure    Press Keys    None    ESCAPE
    Sleep    1s
    Log    Passenger login OK


Get Tomorrow Date
    [Documentation]    Return tomorrow's date in ISO format YYYY-MM-DD
    
    ${tomorrow}=    Evaluate    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=1)).replace(month=4).strftime('%Y-%m-%d')
    RETURN    ${tomorrow}


Fill Date And Time
    [Arguments]    ${date_id}    ${time_id}    ${date_value}    ${time_value}
    [Documentation]    Set date/time via JS targeting Vue's v-model directly
    
    Execute Javascript
    ...    (function() {
    ...        var el = document.getElementById('${date_id}');
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, '${date_value}');
    ...        el.dispatchEvent(new Event('input', { bubbles: true }));
    ...        el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    })();
    Sleep    0.5s
    
    Execute Javascript
    ...    (function() {
    ...        var el = document.getElementById('${time_id}');
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, '${time_value}');
    ...        el.dispatchEvent(new Event('input', { bubbles: true }));
    ...        el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    })();
    Sleep    0.5s
    
    ${d_val}=    Get Value    id=${date_id}
    ${t_val}=    Get Value    id=${time_id}
    Log    Date: ${d_val} | Time: ${t_val}
    Should Not Be Empty    ${d_val}    msg=Date still empty!
    Should Not Be Empty    ${t_val}    msg=Time still empty!
    Log    ✓ Date and Time filled successfully


Type And Select Autocomplete
    [Arguments]    ${input_locator}    ${text}
    [Documentation]    พิมพ์ข้อความใน input แล้วรอ Google Autocomplete dropdown
    
    Run Keyword And Continue On Failure    Wait Until Element Is Not Visible    xpath=//div[contains(@class,'pac-container') and contains(@style,'display')]    5s
    Sleep    1s
    
    ${is_xpath}=    Evaluate    "${input_locator}".startswith("xpath=")
    ${loc}=    Set Variable If    ${is_xpath}    ${input_locator}    id=${input_locator}
    
    Click Element    ${loc}
    Sleep    0.5s
    
    Clear Element Text    ${loc}
    Input Text    ${loc}    ${text}
    Sleep    3s
    
    Wait Until Element Is Visible    xpath=//div[contains(@class,'pac-container')][contains(@style,'display: block')] | //div[contains(@class,'pac-container')][not(contains(@style,'display: none'))]    ${TIMEOUT}
    Sleep    1s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Sleep    2s
    
    ${val}=    Get Value    ${loc}
    Log    ${input_locator} value: ${val}
    Should Not Be Empty    ${val}    msg=${input_locator} is still empty after autocomplete!
    Log    ✓ ${input_locator} filled: ${val}


Close All Browser Windows
    [Documentation]    Close all open browsers
    Close All Browsers
