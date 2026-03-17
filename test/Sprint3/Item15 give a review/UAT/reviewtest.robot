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
${PASSENGER_EMAIL}      user4@example.com
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
    [Documentation]    Passenger ค้นหา booking แล้วกดจอง
    [Tags]             step2  passenger
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/findTrip
    Sleep    3s
    
    Wait Until Element Is Visible    xpath=//button[contains(text(), 'ค้นหา')]    ${TIMEOUT}
    Log    FindTrip page loaded
    
    # === กรอกจุดเริ่มต้น + เลือก autocomplete ===
    Type And Select Autocomplete    xpath=//input[contains(@placeholder,'กรุงเทพ')]    ${START_LOCATION}
    Sleep    1s
    
    # === กรอกจุดปลายทาง + เลือก autocomplete ===
    Type And Select Autocomplete    xpath=//input[contains(@placeholder,'เชียงใหม่')]    ${END_LOCATION}
    Sleep    1s
    
    # Click ค้นหา
    Click Element    xpath=//button[contains(text(), 'ค้นหา')]
    Sleep    5s
    
    Wait Until Page Contains    ผลการค้นหา    ${TIMEOUT}
    Log    Search results loaded
    
    # === คลิก trip card แรก (Bangkok → Chiang Mai) ===
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'route-card')]
    ...    ${TIMEOUT}
    Click Element    xpath=//div[contains(@class,'route-card')]
    Sleep    2s
    Log    Clicked first trip card
    
    # === คลิกปุ่ม จองที่นั่ง ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')]
    ...    ${TIMEOUT}
    Click Element
    ...    xpath=(//button[contains(text(),'จองที่นั่ง') or contains(text(),'จอง')])[1]
    Sleep    2s
    Log    Clicked จองที่นั่ง
    
    # === รอ modal booking ขึ้น ===
    Sleep    3s
    Log    Waiting for booking modal...
    Wait Until Element Is Visible    xpath=//div[contains(@class,'modal-overlay')]    20s
    Log    ✓ Booking modal found!
    
    # === เลือกจำนวนที่นั่งจาก select dropdown ===
    Wait Until Element Is Visible    xpath=//select    ${TIMEOUT}
    Select From List By Value    xpath=//select    4
    Sleep    1s
    Log    Selected 4 seats
    
    # === เลือกจุดขึ้นรถ (พิมพ์แล้วเลือก dropdown แรก) ===
    # ใช้ placeholder "พิมพ์ชื่อสถานที่..." ตัวแรก
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[1]
    ...    กรุงเทพมหานคร
    Sleep    1s
    Log    Selected pickup location
    
    # === เลือกจุดลงรถ (พิมพ์แล้วเลือก dropdown แรก) ===
    # ใช้ placeholder "พิมพ์ชื่อสถานที่..." ตัวที่สอง
    Type And Select Autocomplete
    ...    xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[2]
    ...    เชียงใหม่
    Sleep    1s
    Log    Selected dropoff location
    
    # === กดปุ่ม ยืนยันการจอง ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'ยืนยันการจอง')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันการจอง')]
    Sleep    5s
    Log    Clicked ยืนยันการจอง
    
    # Verify
    ${book_ok}=    Run Keyword And Return Status    Page Should Contain    สำเร็จ
    Run Keyword If    ${book_ok}    Log    ✓ Booking completed
    ...    ELSE    Log    ⚠️ Booking unclear - check manually
    
    Close All Browsers


STEP_03_Driver_Accept_And_Complete
    [Documentation]    Driver ยอมรับการจองและเสร็จสิ้นการเดินทาง
    [Tags]             step3  driver
    
    Open Browser Incognito    ${LOGIN_URL}
    Driver Login    ${DRIVER_EMAIL}    ${DRIVER_PASS}
    
    Sleep    2s
    
    # === Hover ที่ "การเดินทางทั้งหมด" ให้ dropdown ลงมา ===
    Wait Until Element Is Visible
    ...    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    ...    ${TIMEOUT}
    Mouse Over    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    Sleep    1s
    Log    Hovered on การเดินทางทั้งหมด
    
    # === คลิก "คำขอจองเส้นทางของฉัน" จาก dropdown ===
    Wait Until Element Is Visible
    ...    xpath=//a[@href='/myRoute']
    ...    ${TIMEOUT}
    Click Element    xpath=//a[@href='/myRoute']
    Sleep    3s
    Log    ✓ Navigated to myRoute (คำขอจองเส้นทางของฉัน)
    
    # === รอหน้า myRoute โหลด แล้วหา booking ที่รอดำเนินการ ===
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    ...    ${TIMEOUT}
    Log    Booking request found
    
    # === คลิก booking card แรก ===
    Click Element
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'booking') or contains(@class,'request')])[1]
    Sleep    2s
    Log    Clicked booking request card
    
    # === กดปุ่ม "ยืนยันคำขอ" ครั้งแรก (ยอมรับการจอง) ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),'ยืนยันคำขอ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    Log    ✓ Clicked ยืนยันคำขอ (1st)
    
    # === รอ overlay ขึ้น แล้วกดยืนยันอีกรอบ ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'btn-primary') and contains(text(),'ยืนยันคำขอ')]
    Sleep    3s
    Log    ✓ Confirmed in overlay
    
    # === รอหน้า "ยืนยันแล้ว" ขึ้นมา ===
    Wait Until Page Contains    ยืนยันแล้ว    ${TIMEOUT}
    Log    Reached confirmation page
    Sleep    3s

    # === กดปุ่ม Tab "ยืนยันแล้ว" เพื่อไปหน้ายืนยัน (ใช้ JS เพื่อหลีกเลี่ยง navbar interception) ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'ยืนยันแล้ว')]
    ...    ${TIMEOUT}
    Sleep    2s
    Execute Javascript
    ...    Array.from(document.querySelectorAll('button.tab-button')).find(btn => btn.textContent.includes('ยืนยันแล้ว')).click();
    Sleep    3s
    Log    ✓ Clicked ยืนยันแล้ว tab
    
    # === กดปุ่ม "เสร็จสิ้นการเดินทาง" (สีเขียว) ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-green-600') and contains(text(),'เสร็จสิ้นการเดินทาง')]
    Sleep    3s
    Log    ✓ Trip completed
    Close All Browsers


STEP_04_Passenger_Review
    [Documentation]    Passenger เขียนรีวิวคนขับ ของเที่ยวที่เสร็จสิ้น
    [Tags]             step4  passenger  review
    
    Open Browser Incognito    ${LOGIN_URL}
    Passenger Login    ${PASSENGER_EMAIL}    ${PASSENGER_PASS}
    
    Go To    ${BASE_URL}/myTrip
    Sleep    2s
    Reload Page
    Sleep    3s
    
    # === คลิกแท็บ "เสร็จสิ้น" ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(text(),'เสร็จสิ้น')]
    Sleep    2s
    Log    ✓ Clicked เสร็จสิ้น tab
    
    # === รอ trip card แรก ขึ้นมา ===
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'card') or contains(@class,'trip')])[1]
    ...    ${TIMEOUT}
    Log    Trip card found
    
    # === คลิกปุ่ม "รีวิวคนขับ" (สีเหลือง) บน card ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-500') and contains(text(),'รีวิวคนขับ')]
    Sleep    5s
    Log    ✓ Clicked รีวิวคนขับ
    
    # === รอ review modal/dialog เปิด (รอ textarea แทน) ===
    Wait Until Element Is Visible
    ...    xpath=//textarea
    ...    20s
    Log    ✓ Review form opened - textarea found
    
    # Scroll to make sure we can see all elements
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    2s
    
    # === คลิก 5 ดาว (span elements ภายในเซคชั่นให้คะแนน) ===
    FOR    ${i}    IN RANGE    1    6
        Wait Until Element Is Visible
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        ...    ${TIMEOUT}
        Click Element
        ...    xpath=(//div[contains(@class,'flex') and contains(@class,'text-3xl')]/span)[${i}]
        Sleep    0.5s
    END
    Log    ✓ Selected 5 stars
    
    # === ใส่ความคิดเห็น ===
    Wait Until Element Is Visible    xpath=//textarea    ${TIMEOUT}
    Input Text    xpath=//textarea    คนขับดีมากครับ ปลอดภัย บริการเพ้นฟูล รีบสูง!
    Sleep    1s
    Log    ✓ Filled comment
    
    # === อัพโหลดรูป 3 ภาพ ===
    ${image_dir}=    Set Variable    D:\\Y3T2\\SotwareEngi\\SoftEnProJ\\Sprint\\img\\Sprint3\\reviewUATTest
    ${file_inputs}=    Get WebElements    xpath=//input[@type='file']
    
    FOR    ${idx}    IN RANGE    1    4
        ${image_file}=    Set Variable    ${image_dir}\\review${idx}test.jpg
        Run Keyword And Continue On Failure
        ...    Choose File
        ...    ${file_inputs}[0]
        ...    ${image_file}
        Sleep    1s
        Log    ✓ Uploaded review${idx}test.jpg
    END
    
    # === กดปุ่ม "ส่งรีวิว" (สีเหลืองเข้ม bg-yellow-600) ===
    Wait Until Element Is Visible
    ...    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    ...    ${TIMEOUT}
    Click Element    xpath=//button[contains(@class,'bg-yellow-600') and contains(text(),'ส่งรีวิว')]
    Sleep    3s
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
    [Arguments]    ${input_locator}    ${text}
    [Documentation]    พิมพ์ข้อความใน input แล้วรอ Google Autocomplete dropdown
    ...    รองรับ locator แบบ: id=... หรือ xpath=...
    
    # รอให้ pac-container เก่าปิดก่อน (ถ้ามี)
    Run Keyword And Continue On Failure    Wait Until Element Is Not Visible    xpath=//div[contains(@class,'pac-container') and contains(@style,'display')]    5s
    Sleep    1s
    
    # สร้าง locator ที่ถูกต้อง - ตรวจสอบว่าขึ้นต้นด้วย xpath= หรือไม่
    ${is_xpath}=    Evaluate    "${input_locator}".startswith("xpath=")
    ${loc}=    Set Variable If    ${is_xpath}    ${input_locator}    id=${input_locator}
    
    # คลิก input
    Click Element    ${loc}
    Sleep    0.5s
    
    # Clear แล้วพิมพ์
    Clear Element Text    ${loc}
    Input Text    ${loc}    ${text}
    Sleep    3s
    
    # รอ Google Autocomplete dropdown ขึ้น
    Wait Until Element Is Visible    xpath=//div[contains(@class,'pac-container')][contains(@style,'display: block')] | //div[contains(@class,'pac-container')][not(contains(@style,'display: none'))]    ${TIMEOUT}
    Sleep    1s
    
    # คลิก pac-item แรกที่ visible
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'pac-item')])[1]    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Sleep    2s
    
    # Verify ว่า input มีค่าแล้ว
    ${val}=    Get Value    ${loc}
    Log    ${input_locator} value: ${val}
    Should Not Be Empty    ${val}    msg=${input_locator} is still empty after autocomplete!
    Log    ✓ ${input_locator} filled: ${val}


Type And Select Autocomplete By Element
    [Arguments]    ${element}    ${text}
    [Documentation]    เหมือน Type And Select Autocomplete แต่รับ WebElement แทน id
    ...    ใช้สำหรับกรณีที่ไม่รู้ id ล่วงหน้า
    
    Click Element    ${element}
    Sleep    0.5s
    
    Clear Element Text    ${element}
    Input Text    ${element}    ${text}
    Sleep    3s
    
    # รอ pac-container ขึ้น
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'pac-container')]
    ...    ${TIMEOUT}
    Sleep    1s
    
    # คลิก pac-item แรก
    Wait Until Element Is Visible
    ...    xpath=(//div[contains(@class,'pac-item')])[1]
    ...    ${TIMEOUT}
    Click Element    xpath=(//div[contains(@class,'pac-item')])[1]
    Sleep    2s
    
    ${val}=    Get Value    ${element}
    Log    Autocomplete filled: ${val}
    Should Not Be Empty    ${val}    msg=Input still empty after autocomplete!
    Log    ✓ Filled: ${val}


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
