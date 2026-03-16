*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}      https://deploy-production-88fa.up.railway.app
${LOGIN_PATH}    /api/auth/login
${BANNED_USER}   driver2
${BANNED_PASS}   driver1234


*** Test Cases ***
TC-B1 - Banned User Cannot Login
    Create Session    api    ${BASE_URL}

    ${payload}=    Create Dictionary
    ...    username=${BANNED_USER}
    ...    password=${BANNED_PASS}

    ${resp}=    POST On Session
    ...    api
    ...    ${LOGIN_PATH}
    ...    json=${payload}
    ...    expected_status=any

    Log To Console    ======================
    Log To Console    LOGIN STATUS: ${resp.status_code}
    Log To Console    LOGIN BODY: ${resp.text}
    Log To Console    ======================

    # ต้องไม่สามารถ login ได้
    Should Be True
    ...    ${resp.status_code} == 401 or ${resp.status_code} == 403