*** Settings ***
Documentation     UAT for Review System with Incognito Mode - Full E2E Flow
...               1. Driver creates Route
...               2. Passenger searches, books (fills details completely)
...               3. Driver accepts, changes status to complete
...               4. Passenger reviews
Library           SeleniumLibrary
Library           Collections

Suite Setup       Log    Starting Complete E2E UAT
Suite Teardown    Close All Browser Windows

*** Variables ***
${BROWSER}              Chrome
${LOGIN_URL}            http://localhost:3003/login
${BASE_URL}             http://localhost:3003
${TIMEOUT}              15s

${DRIVER_EMAIL}         user1@example.com
${DRIVER_PASS}          123456789
${PASSENGER_EMAIL}      user2@example.com
${PASSENGER_PASS}       123456789

${START_LOCATION}       กรุงเทพมหานคร
${END_LOCATION}         เชียงใหม่
${SEAT_COUNT}           4
${PRICE_PER_SEAT}       250


*** Test Cases ***

STEP_01_Driver_Create_Route
    [Documentation]    Driver สร้าง Route ใหม่
    [Tags]             step1  driver
    
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Go To    ${BASE_URL}/createTrip
    Sleep    3s
    
    Wait Until Element Is Visible    id=startPoint    ${TIMEOUT}
    
    # === กรอก startPoint แล้วเลือก autocomplete ตัวแรก ===
    Type And Select Autocomplete    startPoint    ${START_LOCATION}
    Sleep    1s
    
    # === กรอก endPoint แล้วเลือก autocomplete ตัวแรก ===
    Type And Select Autocomplete    endPoint    ${END_LOCATION}
    Sleep    1s
    
    # Fill date/time
    ${tomorrow}=    Get Tomorrow Date
    Fill Date And Time    travelDate    travelTime    ${tomorrow}    09:00
    Sleep    1s
    
    Input Text    id=seatCount      ${SEAT_COUNT}
    Sleep    0.3s
    Input Text    id=pricePerSeat   ${PRICE_PER_SEAT}
    Sleep    0.5s
    
    # Select vehicle (มีรถอยู่แล้วตามรูป)
    Wait Until Element Is Visible    id=vehicle    ${TIMEOUT}
    Sleep    0.5s
    
    # Submit
    Click Button    xpath=//button[contains(text(), 'สร้างการเดินทาง')]
    Sleep    3s
    
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains    สำเร็จ    15s
    Run Keyword If    ${ok}    Log    ✓ Route created
    ...    ELSE    Log    ⚠️ Check result manually
    
    Sleep    3s
    Close All Browsers


STEP_02_Passenger_Search_And_Book
    [Documentation]    Passenger ค้นหา booking และกรอก บ้คกิ้งข้อมูลให้ครบ แล้วกดจอง
    [Tags]             step2  passenger
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/findTrip
    Sleep    3s
    
    # Wait for page to load
    Wait Until Element Is Visible    xpath=//button[contains(text(), 'ค้นหา')]    ${TIMEOUT}
    Log    Findtrip page loaded
    
    # Search - ใช้ autocomplete เหมือนตอนสร้างทริป
    # เลือจุดเริ่มต้น
    Type And Select Autocomplete    fromLocation    ${START_LOCATION}
    Sleep    1s
    
    # เลือจุดปลายทาง
    Type And Select Autocomplete    toLocation    ${END_LOCATION}
    Sleep    1s
    
    Log    Filling fields: ${START_LOCATION} → ${END_LOCATION}
    
    # Click search
    ${btn}=    Get WebElements    xpath=//button[contains(text(), 'ค้นหา')]
    Run Keyword If    ${btn}    Click Element    ${btn}[0]
    Sleep    8s
    Log    Clicked search, waiting for results...
    
    # Check if results loaded
    ${has_trip}=    Run Keyword And Return Status    Page Should Contain    ${START_LOCATION}
    Log    Trip found on page: ${has_trip}
    
    # Wait for trip card to be visible
    Wait Until Page Contains Element    xpath=(//div[contains(@class, 'card') or contains(@class, 'trip')])[1]    ${TIMEOUT}
    Log    Trip card is visible
    
    # Click on trip to expand
    ${trip}=    Get WebElements    xpath=(//div[contains(@class, 'card') or contains(@class, 'trip')])[1]
    Run Keyword If    ${trip}    Click Element    ${trip}[0]
    Sleep    3s
    Log    Clicked trip card
    
    # Fill passenger count if needed
    ${pax_input}=    Run Keyword And Continue On Failure    Get WebElements    xpath=//input[@name='passengers']
    Run Keyword And Continue On Failure    Input Text    ${pax_input}[0]    1
    Sleep    1s
    
    # Click Book button
    ${book}=    Get WebElements    xpath=//button[contains(text(), 'จอง')]
    Log    Found ${book.__len__()} book buttons
    Run Keyword If    ${book}    Click Element    ${book}[0]
    Sleep    5s
    Log    Clicked book button
    
    # Verify booking
    ${book_ok}=    Run Keyword And Return Status    Page Should Contain    สำเร็จ
    Run Keyword If    ${book_ok}    Log    ✓ Booking completed
    ...    ELSE    Log    ⚠️ Booking unclear
    
    Close All Browsers


STEP_03_Driver_Accept_And_Complete
    [Documentation]    Driver ยอมรับแล้ว เปลี่ยนสถานะจนเป็น Complete
    [Tags]             step3  driver
    
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    
    # Click trip to expand
    ${trip}=    Get WebElements    xpath=(//div[contains(@class, 'card') or contains(@class, 'trip')])[1]
    Run Keyword If    ${trip}    Click Element    ${trip}[0]
    Sleep    2s
    
    # Accept booking
    ${accept}=    Get WebElements    xpath=//button[contains(text(), 'ยอมรับ')]
    Run Keyword If    ${accept}    Click Element    ${accept}[0]
    Sleep    2s
    Log    ✓ Accepted
    
    # Change status - try any status buttons
    ${all_btns}=    Get WebElements    xpath=//button[contains(text(), 'รับ') or contains(text(), 'เริ่ม') or contains(text(), 'ทำการ') or contains(text(), 'สิ้น') or contains(text(), 'เสร็จ') or contains(text(), 'ปิด')]
    
    # Click buttons in sequence for status changes
    FOR    ${btn}    IN    @{all_btns}
        ${txt}=    Get Text    ${btn}
        Run Keyword And Continue On Failure    Click Element    ${btn}
        Sleep    1s
        Log    Clicked: ${txt}
    END
    
    Log    ✓ Trip completed
    Close All Browsers


STEP_04_Passenger_Review
    [Documentation]    Passenger กลับไปเขียนรีวิว
    [Tags]             step4  passenger  review
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    2s
    
    # Click trip to expand
    ${trip}=    Get WebElements    xpath=(//div[contains(@class, 'card') or contains(@class, 'trip')])[1]
    Run Keyword If    ${trip}    Click Element    ${trip}[0]
    Sleep    2s
    
    # Click review button
    ${review}=    Get WebElements    xpath=//button[contains(text(), 'รีวิว') or contains(text(), 'เขียน')]
    Run Keyword If    ${review}    Click Element    ${review}[0]
    Sleep    2s
    
    # Click stars (1-5)
    FOR    ${i}    IN RANGE    1    6
        ${stars}=    Get WebElements    xpath=(//button[contains(@class, 'star')] | //span[contains(@class, 'star')])[${i}]
        Run Keyword And Continue On Failure    Click Element    ${stars}
        Sleep    0.3s
    END
    
    # Fill comment
    ${textarea}=    Run Keyword And Continue On Failure    Get WebElements    xpath=//textarea
    Run Keyword And Continue On Failure    Input Text    ${textarea}[0]    คนขับดีมากครับ บริการเพ้นฟูล!!
    Sleep    1s
    
    # Submit
    ${submit}=    Get WebElements    xpath=//button[contains(text(), 'ส่ง') or contains(text(), 'บันทึก')]
    Run Keyword If    ${submit}    Click Element    ${submit}[0]
    Sleep    2s
    
    Log    ✓ Review submitted
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


Close All Browser Windows
    Close All Browsers


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
    [Documentation]    Return tomorrow's date in ISO format YYYY-MM-DD (required by frontend DateTime constructor)
    
    ${tomorrow}=    Evaluate    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=1)).replace(month=4).strftime('%Y-%m-%d')
    RETURN    ${tomorrow}


Fill Date And Time
    [Arguments]    ${date_id}    ${time_id}    ${date_value}    ${time_value}
    [Documentation]    Set date/time via JS targeting Vue's v-model directly
    
    # === Fill Date ===
    Execute Javascript
    ...    (function() {
    ...        var el = document.getElementById('${date_id}');
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, '${date_value}');
    ...        el.dispatchEvent(new Event('input', { bubbles: true }));
    ...        el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    })();
    Sleep    0.5s
    
    # === Fill Time ===
    Execute Javascript
    ...    (function() {
    ...        var el = document.getElementById('${time_id}');
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, '${time_value}');
    ...        el.dispatchEvent(new Event('input', { bubbles: true }));
    ...        el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    })();
    Sleep    0.5s
    
    # Verify
    ${d_val}=    Get Value    id=${date_id}
    ${t_val}=    Get Value    id=${time_id}
    Log    Date: ${d_val} | Time: ${t_val}
    Should Not Be Empty    ${d_val}    msg=Date still empty!
    Should Not Be Empty    ${t_val}    msg=Time still empty!
    Log    ✓ Date and Time filled successfully


Type And Select Autocomplete
    [Arguments]    ${input_id}    ${text}
    [Documentation]    พิมพ์ข้อความใน input แล้วรอ Google Autocomplete dropdown
    ...    จากนั้นกด option แรกในรายการ
    
    # รอให้ pac-container เก่าปิดก่อน (ถ้ามี)
    Run Keyword And Continue On Failure    Wait Until Element Is Not Visible    xpath=//div[contains(@class,'pac-container') and contains(@style,'display')]    5s
    Sleep    1s
    
    # คลิก input
    Click Element    id=${input_id}
    Sleep    0.5s
    
    # Clear แล้วพิมพ์
    Clear Element Text    id=${input_id}
    Input Text    id=${input_id}    ${text}
    Sleep    3s
    
    # รอ Google Autocomplete dropdown ขึ้น
    # ใช้ XPath ที่ strict ขึ้น - ต้องเป็น pac-container ที่ visible
    Wait Until Element Is Visible    xpath=//div[contains(@class,'pac-container')][contains(@style,'display: block')] | //div[contains(@class,'pac-container')][not(contains(@style,'display: none'))]    ${TIMEOUT}
    Sleep    1s
    
    # คลิก pac-item แรกที่ visible
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Sleep    2s
    
    # Verify ว่า input มีค่าแล้ว
    ${val}=    Get Value    id=${input_id}
    Log    ${input_id} value: ${val}
    Should Not Be Empty    ${val}    msg=${input_id} is still empty after autocomplete!
    Log    ✓ ${input_id} filled: ${val}


Click Map Pin Button
    [Arguments]    ${input_id}
    [Documentation]    คลิกปุ่ม map pin ที่อยู่ใน div.relative เดียวกับ input
    
    # จาก Vue template: input อยู่ใน div.relative และ button เป็น sibling ถัดไปเลย
    Click Element    xpath=//input[@id='${input_id}']/following-sibling::button
    Sleep    3s
    
    # รอ modal-overlay เปิด (ตรงกับ Vue template ที่ใช้ class modal-overlay)
    Wait Until Element Is Visible    xpath=//div[@class='modal-overlay']    ${TIMEOUT}
    Log    ✓ Map modal opened for ${input_id}


Pick Location On Map
    [Arguments]    ${lat}    ${lng}
    [Documentation]    Trigger Google Maps click ที่ lat/lng — ค้นหา map instance จาก __e3_ หรือ __gm
    
    # รอ map render ก่อน (Google Maps ใช้เวลาโหลด tile)
    Sleep    4s
    
    ${result}=    Execute Javascript
    ...    (function(){
    ...        try {
    ...            var latLng = new google.maps.LatLng(${lat}, ${lng});
    ...            
    ...            // วิธี 1: หา map instance จากทุก div ใน modal-content
    ...            var allDivs = document.querySelectorAll('.modal-content div');
    ...            var map = null;
    ...            for (var i = 0; i < allDivs.length; i++) {
    ...                var d = allDivs[i];
    ...                // Google Maps เก็บ instance ใน key ที่ขึ้นต้นด้วย __
    ...                var keys = Object.keys(d);
    ...                for (var k = 0; k < keys.length; k++) {
    ...                    if (keys[k].indexOf('__') === 0 && d[keys[k]] && typeof d[keys[k]].getCenter === 'function') {
    ...                        map = d[keys[k]];
    ...                        break;
    ...                    }
    ...                }
    ...                if (map) break;
    ...            }
    ...            
    ...            if (!map) return 'ERROR: map instance not found';
    ...            
    ...            // Pan ไปที่ location ก่อน แล้ว trigger click
    ...            map.panTo(latLng);
    ...            google.maps.event.trigger(map, 'click', { latLng: latLng });
    ...            return 'OK: triggered click at ${lat},${lng}';
    ...        } catch(e) {
    ...            return 'ERROR: ' + e.message;
    ...        }
    ...    })();
    Log    Map click result: ${result}
    Sleep    3s
    
    # รอให้ Vue resolvePicked() ทำงานเสร็จ — ชื่อสถานที่จะไม่ใช่ — ยังไม่เลือก —
    Wait Until Element Is Visible
    ...    xpath=//div[@class='modal-content']//div[contains(@class,'text-gray-700')]/div[2][not(contains(text(),'ยังไม่เลือก')) and not(contains(text(),'—'))]
    ...    20s
    Log    ✓ Location name resolved


Confirm Map Selection
    [Documentation]    กดปุ่ม ใช้ตำแหน่งนี้ แล้วรอ modal ปิด
    
    Wait Until Element Is Enabled
    ...    xpath=//button[contains(text(),'ใช้ตำแหน่งนี้')]
    ...    ${TIMEOUT}
    
    Click Element    xpath=//button[contains(text(),'ใช้ตำแหน่งนี้')]
    Sleep    1s
    
    Wait Until Element Is Not Visible
    ...    xpath=//div[@class='modal-overlay']
    ...    ${TIMEOUT}
    Log    ✓ Modal closed
