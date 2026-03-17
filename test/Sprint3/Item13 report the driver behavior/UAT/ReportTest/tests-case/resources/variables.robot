*** Variables ***
# === URL ===
${BASE_URL}           http://localhost:3001
${LOGIN_URL}          ${BASE_URL}/login
${MY_TRIPS_URL}       ${BASE_URL}/myTrip
${MY_HISTORY_URL}     ${BASE_URL}/myHistory

# === Credentials (main suite) ===
${PASSENGER_EMAIL}        passenger_1
${PASSENGER_PASSWORD}     123456789
${PASSENGER_EMAIL_2}      passenger_2
${PASSENGER_PASSWORD_2}   123456789

# === Credentials (fresh users — ไม่เคย report ใครมาก่อน ใช้เฉพาะ TC_Report_HappyPath) ===
# สร้าง user เหล่านี้ใน test environment ก่อนรัน suite
# แต่ละ user ต้องมี booking ที่ยัง active อยู่อย่างน้อย 1 รายการ
${FRESH_EMAIL_1}          fresh_report_1@test.com
${FRESH_PASSWORD_1}       Password1234!
${FRESH_EMAIL_2}          fresh_report_2@test.com
${FRESH_PASSWORD_2}       Password1234!

# === Timeouts ===
${DEFAULT_TIMEOUT}        10s
${LONG_TIMEOUT}           10s
${SHORT_TIMEOUT}          5s
${ANIMATION_WAIT}         1s

# === Selectors: Tab ===
${TAB_PENDING}            xpath=//button[contains(@class,'tab-button') and contains(.,'รอดำเนินการ')]
${TAB_CONFIRMED}          xpath=//button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
${TAB_COMPLETED}          xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
${TAB_REJECTED}           xpath=//button[contains(@class,'tab-button') and contains(.,'ปฏิเสธ')]
${TAB_CANCELLED}          xpath=//button[contains(@class,'tab-button') and contains(.,'ยกเลิก')]
${TAB_ALL}                xpath=//button[contains(@class,'tab-button') and contains(.,'ทั้งหมด')]

# === Selectors: Trip Card ===
# FIX TC05, TC42: ใช้ p6 (padding class) + cursor-pointer แทน class='trip-card' เพราะ Tailwind scoped อาจไม่ติด
${TRIP_CARD}              xpath=//div[contains(@class,'cursor-pointer') and contains(@class,'p-6') and .//h4]
${TRIP_CARD_FIRST}        xpath=(//div[contains(@class,'cursor-pointer') and contains(@class,'p-6') and .//h4])[1]

# === Selectors: Buttons ===
# FIX TC10, TC13-15: normalize-space ภาษาไทยอาจมี whitespace ซ่อน → ใช้ contains แทน
${BTN_REPORT}             xpath=//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))]
${BTN_REPORT_FIRST}       xpath=(//button[contains(.,'รายงานปัญหา') and not(contains(.,'ดู'))])[1]
${BTN_CANCEL_BOOKING}     xpath=//button[contains(.,'ยกเลิกการจอง')]
${BTN_CANCEL_CONFIRM}     xpath=//button[contains(.,'ยืนยันการยกเลิก')]
${BTN_REVIEW}             xpath=//button[contains(.,'รีวิวคนขับ')]
${BTN_SUBMIT_REVIEW}      xpath=//button[contains(.,'ส่งรีวิว')]
${BTN_SUBMIT_REPORT}      xpath=//button[contains(.,'ส่งรายงาน')]
${BTN_SUBMIT_CANCEL}      xpath=//button[contains(.,'ยืนยันการยกเลิก')]
${BTN_DELETE}             xpath=//button[contains(.,'ลบรายการ')]
${BTN_CLOSE_MODAL}        xpath=//button[contains(.,'ปิด')]
# FIX TC12: ปุ่มนี้ใน template ใช้ contains text 'ดูประวัติการรายงาน'
${BTN_VIEW_HISTORY}       xpath=//button[contains(.,'ดูประวัติการรายงาน')]
${BTN_CHAT}               xpath=//button[contains(.,'แชทกับผู้ขับ')]

# === Selectors: Report Modal ===
# FIX TC19: modal ใช้ class 'fixed inset-0' → หา div ที่มีทั้งสองก็พอ
${MODAL_REPORT}           xpath=//div[contains(@class,'fixed') and contains(@class,'inset-0') and .//h3[contains(.,'รายงานปัญหา')]]
${REPORT_CATEGORY}        xpath=//div[contains(@class,'fixed')]//select[.//option[contains(.,'ขับรถอันตราย')]]
${REPORT_DESCRIPTION}     xpath=//div[contains(@class,'fixed')]//textarea[contains(@placeholder,'รายละเอียดปัญหา')]
${REPORT_USER_CHECKBOX}   xpath=//div[contains(@class,'fixed')]//table//input[@type='checkbox']
${REPORT_USER_CB_FIRST}   xpath=(//div[contains(@class,'fixed')]//table//input[@type='checkbox'])[1]
${REPORT_EVIDENCE_INPUT}  xpath=//div[contains(@class,'fixed')]//input[@type='file']

# === Selectors: Cancel Modal ===
${MODAL_CANCEL}           xpath=//div[contains(@class,'fixed') and contains(@class,'inset-0') and .//h3[contains(.,'เหตุผลการยกเลิก')]]
${CANCEL_REASON_SELECT}   xpath=//div[contains(@class,'fixed')]//select[.//option[contains(.,'เปลี่ยนแผน')]]

# === Selectors: Review Modal ===
${MODAL_REVIEW}           xpath=//div[contains(@class,'fixed') and contains(@class,'inset-0') and .//h3[contains(.,'รีวิวการเดินทาง')]]
${REVIEW_STAR}            xpath=(//div[contains(@class,'fixed')]//span[contains(@class,'cursor-pointer') and contains(.,'★')])[4]
${REVIEW_COMMENT}         xpath=//div[contains(@class,'fixed')]//textarea[contains(@placeholder,'ความคิดเห็น')]
${REVIEWED_BADGE}         xpath=//span[contains(.,'รีวิวแล้ว')]

# === Selectors: Trip Detail (expanded) ===
# FIX TC06, TC08: h5 อาจถูก scope ด้วย div ที่ซ่อนอยู่ → ใช้ contains text แทน normalize-space
${DETAIL_ROUTE_HEADER}    xpath=//h5[contains(.,'รายละเอียดเส้นทาง')]
${DETAIL_ORIGIN_TEXT}     xpath=//*[contains(.,'จุดเริ่มต้น')]
${DETAIL_DEST_TEXT}       xpath=//*[contains(.,'จุดปลายทาง')]

# === Selectors: Driver Image ===
# FIX TC42: img อยู่ใน trip card แต่ class 'rounded-full' อาจไม่ครบ → ใช้ w-12 h-12 ที่ตรงกับ template
${DRIVER_IMG}             xpath=(//div[contains(@class,'cursor-pointer') and contains(@class,'p-6')])[1]//img[contains(@class,'rounded-full') or (contains(@class,'w-12') and contains(@class,'h-12'))]

# === Selectors: Toast / Alert ===
# FIX TC38: toast อาจแสดงข้อความสั้นกว่า → ใช้ contains แบบกว้างขึ้น
${TOAST_SUCCESS}          xpath=//*[contains(.,'สำเร็จ')]
${TOAST_ERROR}            xpath=//*[contains(@class,'error') or contains(@class,'toast')]
${TEXT_REVIEWED}          xpath=//span[contains(.,'รีวิวแล้ว')]
${BADGE_ACTIVE_REPORT}    xpath=//*[contains(.,'มีเคสที่กำลังตรวจสอบอยู่')]
