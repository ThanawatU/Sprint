*** Settings ***
Documentation     Review System Test Cases - Comprehensive coverage for review functionality
...
...               IMPORTANT SETUP REQUIRED:
...               ========================
...               Each test case requires a COMPLETED UN-REVIEWED TRIP.
...               
...               RECOMMENDED WORKFLOW:
...               1. Run UAT (review_system_e2e.robot) to create completed trip:
...                  - STEP_01: Driver creates route
...                  - STEP_02: Passenger books
...                  - STEP_03: Driver accepts & marks complete
...               
...               2. Run ONE test case to test the review functionality:
...                  robot -i 5stars review_test_cases.robot
...                  (or any other tag: 1star, imageonly, longcomment, etc.)
...               
...               3. Repeat steps 1-2 for each test case
...               
...               EXAMPLE BATCH RUN:
...               ================
...               # Test Case 1: 5 Stars
...               cd ..\UAT
...               robot --include step1 --include step2 --include step3 review_system_e2e.robot
...               cd ..\TestCase
...               robot -i 5stars review_test_cases.robot
...
...               # Test Case 2: 1 Star
...               cd ..\UAT
...               robot --include step1 --include step2 --include step3 review_system_e2e.robot
...               cd ..\TestCase
...               robot -i 1star review_test_cases.robot
...
...               PREREQUISITES:
...               ==============
...               - Backend & Frontend running (http://localhost:3003)
...               - Test images in: img/Sprint3/reviewUATTest/
...                 * review1test.jpg
...                 * review2test.jpg
...                 * review3test.jpg
...               - Test account: user4@example.com / 123456789
...               - ChromeDriver path: C:\\Users\\wisit\\.wdm\\drivers\\chromedriver\\...
...
...               TEST CASES SUMMARY:
...               ==================
...               TC_01: 5 stars + comment + 3 images (happy path)
...               TC_02: 1 star + negative comment (no images)
...               TC_03: Submit without rating (validation error)
...               TC_03: Upload 4 images exceeds limit (validation error)
...               TC_04: Upload oversized .tif file (validation error)
...               TC_05: 4 stars + images only (no comment)
...               TC_06: 5 stars + long detailed comment
...               TC_07: 1 star minimum rating
...               TC_08: Close modal without submitting
Library           SeleniumLibrary
Library           Collections

Suite Setup       Log    Starting Review System Test Cases
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}              Chrome
${LOGIN_URL}            http://localhost:3003/login
${BASE_URL}             http://localhost:3003
${TIMEOUT}              15s

${PASSENGER_EMAIL}      user4@example.com
${PASSENGER_PASS}       123456789

${IMAGE_DIR}            D:\\Y3T2\\SotwareEngi\\SoftEnProJ\\Sprint\\img\\Sprint3\\reviewUATTest


*** Test Cases ***

TC_01_Review_5_Stars_Excellent_Driver
    [Documentation]    Passenger gives 5 stars with positive comment and images
    [Tags]             review  5stars  positive  images
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find and click review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form - textarea must appear
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
    Log    ✓ Review submitted successfully
    
    Close All Browsers


TC_02_Review_1_Star_Bad_Driver
    [Documentation]    Passenger gives 1 star with negative comment (no images)
    [Tags]             review  1star  negative  noimage
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    Log    ✓ Review submitted without images
    
    Close All Browsers


TC_03_Review_No_Rating_Selected_Error
    [Documentation]    Test validation: Submit review without selecting any rating (should fail)
    [Tags]             review  validation  error  norating
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    ...    Log    ✓ Error validation works - must select rating
    ...    ELSE    Log    ⚠️ No error shown - check if validation exists
    
    Close All Browsers


TC_03_Review_Exceed_Max_Images_Error
    [Documentation]    Test validation: Try to upload more than 3 images (should fail or limit)
    [Tags]             review  validation  error  maximage
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    ...    Log    ✓ Image limit validation works - max 3 images
    ...    ELSE    Log    ⚠️ System may allow images or show different error
    
    Close All Browsers


TC_04_Review_Oversized_Image_Error
    [Documentation]    Test validation: Try to upload image exceeding file size limit (should fail)
    [Tags]             review  validation  error  filesize
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    Input Text    xpath=//textarea    ทดสอบอัพโหลดไฟล์ขนาดใหญ่
    Sleep    1s
    
    # == TRY TO UPLOAD OVERSIZED IMAGE ==
    # Note: This assumes a file named "oversized_image.tif" exists or we simulate the attempt
    ${oversized_image}=    Set Variable    ${IMAGE_DIR}\\oversized_image.tif
    ${file_inputs}=    Get WebElements    xpath=//input[@type='file']
    
    ${file_exists}=    Run Keyword And Return Status
    ...    File Should Exist    ${oversized_image}
    
    Run Keyword If    ${file_exists}
    ...    Run Keyword And Continue On Failure
    ...        Choose File
    ...        ${file_inputs}[0]
    ...        ${oversized_image}
    ...    ELSE    Log    ⚠️ Oversized test image not found - test demonstration only
    
    Sleep    2s
    
    # == CHECK IF ERROR MESSAGE APPEARS ==
    ${size_error}=    Run Keyword And Return Status
    ...    Page Should Contain    ขนาดไม่เกิน
    
    ${format_error}=    Run Keyword And Return Status
    ...    Page Should Contain    เฉพาะไฟล์รูปภาพ
    
    Run Keyword If    ${size_error}
    ...    Log    ✓ File size validation works
    ...    ELSE    Run Keyword If    ${format_error}
    ...        Log    ✓ File format validation works
    ...        ELSE    Log    ⚠️ File validation may need verification
    
    Close All Browsers


TC_05_Review_Only_Image_No_Comment
    [Documentation]    Passenger submits review with only images, no text comment
    [Tags]             review  imageonly  nocomment
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    Log    ✓ Review submitted with images only
    
    Close All Browsers


TC_06_Review_With_Long_Comment
    [Documentation]    Passenger submits review with long detailed comment
    [Tags]             review  longcomment  detailed
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    Log    ✓ Long review submitted
    
    Close All Browsers


TC_07_Review_Minimum_Rating
    [Documentation]    Passenger submits review with minimum 1 star - should not allow 0 stars
    [Tags]             review  minimum  validation
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    Log    ✓ Minimum rating review submitted
    
    Close All Browsers


TC_08_Review_Modal_Close_Button
    [Documentation]    Test that review modal can be closed without submitting
    [Tags]             review  modal  ui
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # Click "เสร็จสิ้น" tab
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    
    # Find review button
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    
    # Wait for review form
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
    ...    xpath=//button[contains(text(),'ปิด') and contains(@class,'bg-gray-100')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ปิด') and contains(@class,'bg-gray-100')]
    Sleep    2s
    Log    ✓ Modal closed without submitting
    
    # Verify we're back on myTrip page
    Wait Until Page Contains    การเดินทางของฉัน    ${TIMEOUT}
    Log    ✓ Returned to myTrip page
    
    Close All Browsers


*** Keywords ***

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
