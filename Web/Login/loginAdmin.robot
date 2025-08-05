*** Settings ***
Library           SeleniumLibrary
Library           ImapLibrary2
Library           String
Library           Collections

*** Variables ***
${DELAY}                   3s
${BROWSER}                 edge

${ADMIN_URL}              https://admin.terrasoft.co.ke/auth/login
${ADMIN_EMAIL}            admin@terra.com
${ADMIN_PASSWORD}         Terra2012.

${STAGING_URL}            https://beta.terrasofthq.com/login
${USER_EMAIL}             stephaniekibet@terrasofthq.com
${USER_PASSWORD}          Admin1234!

${IMAP_SERVER}            imap.zoho.com
${IMAP_PORT}              993
${IMAP_APP_PASSWORD}      LvDYea4vKUu8
${EMAIL_FOLDER}           Inbox
${OTP_SUBJECT}            Your One-Time Password (OTP) for Secure Access
${OTP_TIMEOUT}            120

*** Test Cases ***
Open Admin Login Page
    Open Admin Login
    Sleep    ${DELAY}
    Close Browser

Login Admin With Valid Credentials
    Login Admin
    Sleep    ${DELAY}
    Close Browser

*** Keywords ***
Open Admin Login
    Open Browser    ${ADMIN_URL}    ${BROWSER}
    Maximize Browser Window

Open User Login
    Open Browser    ${STAGING_URL}    ${BROWSER}
    Maximize Browser Window

Login Admin
    Open Admin Login
    Input Text      xpath=//*[@id="app"]/div/div/div[2]/div/form/div[1]/input     ${ADMIN_EMAIL}
    Input Password  xpath=//*[@id="app"]/div/div/div[2]/div/form/div[2]/input     ${ADMIN_PASSWORD}
    Click Button    xpath=//*[@id="app"]/div/div/div[2]/div/form/div[3]/button

Login User
    Open User Login
    Input Text      id=emailAddress     ${USER_EMAIL}
    Input Password  id=password         ${USER_PASSWORD}
    Click Button    id=login-button

Get OTP From Email
    Open Mailbox    host=${IMAP_SERVER}    user=${USER_EMAIL}    password=${IMAP_APP_PASSWORD}    port=${IMAP_PORT}    ssl=True
    ${latest}=      Wait For Email    sender=info@terrasofthq.com    subject=${OTP_SUBJECT}    timeout=${OTP_TIMEOUT}
    ${body}=        Get Email Body    ${latest}
    ${otp}=         Extract OTP From Email Body    ${body}
    RETURN          ${otp}

Extract OTP From Email Body
    [Arguments]    ${body}
    ${otp}=        Fetch From Right    ${body}    OTP: 
    ${otp}=        Get Regexp Matches    ${otp}    \d{6}
    RETURN         ${otp[0]}

Input OTP And Submit
    [Arguments]    ${otp}
    ${otp_digits}=    Convert To List    ${otp}
    FOR    ${index}    ${digit}    IN ENUMERATE    @{otp_digits}
        Input Text    xpath=(//*[@id="app"]/div/div[2]/div[2]/div/div[2]/div/div/div/div[1]/div/div/div/input[1])[${index + 1}]    ${digit}
        Sleep    0.5s
    END
    Click Button    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div[2]/div/div/div/div[2]/button
