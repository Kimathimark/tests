*** Settings ***
Library           SeleniumLibrary
Library           ImapLibrary2
Library           String
Library           Collections
Library           RequestsLibrary
Suite Setup       Open Browser To Login Page
Suite Teardown    Close Browser
Test Teardown     Capture Page Screenshot

*** Variables ***
${DELAY}                      3s
${BROWSER}                    chrome
${ADMIN_URL}                  https://admin.terrasoft.co.ke/auth/login
${ADMIN_EMAIL}                admin@terra.com
${ADMIN_PASSWORD}             Terra2012.
${STAGING_URL}                https://beta.terrasofthq.com/login
${EMAIL}                      stephaniekibet@terrasofthq.com
${EMAIL_PASSWORD}             Admin123!
${IMAP_APP_PASSWORD}          LvDYea4vKUu8
${IMAP_SERVER}                imap.zoho.com
${IMAP_PORT}                  993
${EMAIL_FOLDER}               Inbox
${OTP_SUBJECT}                Your One-Time Password (OTP) for Secure Access
${OTP_TIMEOUT}                120
${DASHBOARD_URL}              https://beta.terrasofthq.com/

*** Test Cases ***
Login With OTP
    [Tags]    regression
    Login With Valid Credentials
    ${otp}=    Get OTP From Email
    Input OTP And Submit    ${otp}
    Sleep    5s
    Location Should Contain    dashboard
    Capture Page Screenshot

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${STAGING_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}

Login With Valid Credentials
    Input Text      id:emailAddress     ${EMAIL}
    Input Password  id:password         ${EMAIL_PASSWORD}
    Click Element   id:login-button
    Sleep           3s

Get OTP From Email
    Open Mailbox       host=${IMAP_SERVER}    user=${EMAIL}    password=${IMAP_APP_PASSWORD}    port=${IMAP_PORT}    ssl=True
    ${mail}=           Wait For Email        sender=info@terrasofthq.com   subject=${OTP_SUBJECT}   timeout=${OTP_TIMEOUT}
    ${body}=           Get Email Body        ${mail}
    ${otp}=            Extract OTP From Body ${body}
    Close Mailbox
    RETURN             ${otp}

Extract OTP From Body
    [Arguments]    ${body}
    ${otp_line}=   Fetch From Right    ${body}    OTP:
    ${otp}=        Get Regexp Matches  ${otp_line}    \d{6}
    Should Not Be Empty    ${otp}    msg=OTP not found in the email body
    RETURN         ${otp}[0]

Input OTP And Submit
    [Arguments]    ${otp}
    ${digits}=     Convert To List    ${otp}
    :FOR    ${index}    ${digit}    IN ENUMERATE    @{digits}
    \   ${xpath}=    Set Variable    (//input[@type="tel"])[${index + 1}]
    \   Input Text    ${xpath}    ${digit}
    \   Sleep         0.2s
    Click Button    xpath=//button[contains(., 'Continue') or contains(@type, 'submit')]
