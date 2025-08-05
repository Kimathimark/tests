*** Settings ***
Library           SeleniumLibrary
Library           ImapLibrary2
Library           String
Library           Collections
Suite Teardown    Close Browser
Test Teardown     Capture Page Screenshot

*** Variables ***
${DELAY}                   3s
${BROWSER}                 chrome

${ADMIN_URL}               https://admin.terrasoft.co.ke/auth/login
${ADMIN_EMAIL}             admin@terra.com
${ADMIN_PASSWORD}          Terra2012.

${STAGING_URL}            https://beta.terrasofthq.com/login
${EMAIL}                  stephaniekibet@terrasofthq.com
${EMAIL_PASSWORD}         Admin123!

${IMAP_SERVER}            imap.zoho.com
${IMAP_PORT}              993
${IMAP_APP_PASSWORD}      LvDYea4vKUu8
${EMAIL_FOLDER}           Inbox
${OTP_SUBJECT}            Your One-Time Password (OTP) for Secure Access
${OTP_TIMEOUT}            120

*** Test Cases ***
User Registration
    Open Registration Page
    Fill Personal And Company Info
    Select Industry And Country
    Add Phone Number
    Select Company Type And Business ID
    Choose Products Of Interest
    Submit Registration

Login As User With OTP
    Login Correct Credentials User
    ${otp}=    Get OTP From Email
    Input OTP And Verify Login
    Sleep    3s
    Location Should Contain    dashboard

Login As Admin
    Login Correct Credentials Admin
    Sleep    3s
    Location Should Contain    admin

*** Keywords ***
Open Registration Page
    Open Browser    ${STAGING_URL}    ${BROWSER}
    Maximize Browser Window
    Click Element   id:create-account-button

Fill Personal And Company Info
    Input Text    xpath=//input[@placeholder='John Doe']                   Mary Poppins
    Input Text    xpath=//input[@placeholder='Terra']                     My Company
    Input Text    xpath=//input[@placeholder='terra@example.co.ke']      stephkiby@gmail.com

Select Industry And Country
    Click Element    xpath=//div[label[contains(text(),'Industry')]]//button
    Wait Until Element Is Visible   xpath=//div[@role='option'][1]    10s
    Click Element    xpath=//div[@role='option'][1]

    Click Element    xpath=//div[label[contains(text(),'Country')]]//button
    Wait Until Element Is Visible   xpath=//div[@role='option'][1]    5s
    Click Element    xpath=//div[@role='option'][1]

Add Phone Number
    Click Element    xpath=//div[contains(@class,'phone-input')]//span
    Wait Until Element Is Visible    xpath=//ul/li[1]/span[1]    5s
    Click Element    xpath=//ul/li[1]/span[1]
    Input Text       xpath=//input[@placeholder='12345678']    712345678

Select Company Type And Business ID
    Select From List By Index    xpath=//select    1
    Input Text    xpath=(//input[@placeholder='12345678'])[last()]    00100100

Choose Products Of Interest
    Click Element    xpath=(//div[@class='option'])[5]
    Sleep            1s
    Click Element    xpath=(//div[@class='option'])[4]

Submit Registration
    Click Element    id:signup-button
    Sleep            5s

Login Correct Credentials User
    Open Browser    ${STAGING_URL}    ${BROWSER}
    Maximize Browser Window
    Input Text      id:emailAddress      ${EMAIL}
    Input Password  id:password          ${EMAIL_PASSWORD}
    Click Element   id:login-button
    Sleep           3s

Login Correct Credentials Admin
    Open Browser    ${ADMIN_URL}    ${BROWSER}
    Maximize Browser Window
    Input Text      xpath=//input[@type='text']         ${ADMIN_EMAIL}
    Input Password  xpath=//input[@type='password']     ${ADMIN_PASSWORD}
    Click Element   xpath=//button[contains(., 'Login')]

Get OTP From Email
    Open Mailbox    host=${IMAP_SERVER}    user=${EMAIL}    password=${IMAP_APP_PASSWORD}    port=${IMAP_PORT}    ssl=True
    ${latest}=      Wait For Email    sender=info@terrasofthq.com   subject=${OTP_SUBJECT}   timeout=${OTP_TIMEOUT}
    ${body}=        Get Email Body    ${latest}
    ${otp}=         Extract OTP From Body    ${body}
    Close Mailbox
    RETURN          ${otp}

Extract OTP From Body
    [Arguments]    ${body}
    ${otp_line}=   Fetch From Right    ${body}    OTP:
    ${otp}=        Get Regexp Matches    ${otp_line}    \d{6}
    Should Not Be Empty    ${otp}    OTP not found in email body.
    RETURN         ${otp}[0]

Input OTP And Verify Login
    [Arguments]    ${otp}
    ${otp_digits}=    Convert To List    ${otp}
    :FOR    ${index}    ${digit}    IN ENUMERATE    @{otp_digits}
    \   Input Text    xpath=(//input[@type='text' and @inputmode='numeric'])[${index + 1}]    ${digit}
    \   Sleep         0.2s
    Click Button    xpath=//button[contains(., 'Verify')]
