*** Variables ***

${LOGIN_USERNAME}    id=identifier
${LOGIN_PASSWORD}    id=password
${LOGIN_BUTTON}      xpath=//button[@type='submit']

${IGNORE_POPUP}    xpath=//button[contains(.,'Ignore')]

${TAB_ALL_TRIPS}     xpath=//button[contains(.,'ทั้งหมด')]
${TRIP_CARD}    css:.trip-card

${REPORT_BUTTON}     xpath=//button[normalize-space()='รายงานปัญหา']
${REPORT_MODAL}      xpath=//h3[normalize-space()='รายงานปัญหาการเดินทาง']

${CHECKBOX_USER}     xpath=(//input[@type='checkbox'])[1]

${PROBLEM_SELECT}    xpath=//select
${DESCRIPTION}       xpath=//textarea

${UPLOAD_IMAGE}      xpath=//input[@type='file']

${SUBMIT_REPORT}     xpath=//button[normalize-space()='ส่งรายงาน']