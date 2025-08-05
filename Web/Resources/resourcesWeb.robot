*** Settings ***
Library           SeleniumLibrary
Library           ImapLibrary2
Library           String
Library           Collections

*** Variables ***
${Delay}                   3s
${BROWSER}                 chrome
${ADMIN_URL}               https://admin.terrasoft.co.ke/auth/login
${ADMIN_EMAIL}             admin@terra.com
${ADMIN_PASSWORD}          Terra2012.
${STAGING_URL}             https://beta.terrasofthq.com/login
${EMAIL}                   stephaniekibet@terrasofthq.com
${IMAP_APP_PASSWORD}       LvDYea4vKUu8
${EMAIL_PASSWORD}          Admin1234!
${IMAP_SERVER}             imap.zoho.com
${OTP_SUBJECT}             Your One-Time Password (OTP) for Secure Access
${EMAIL_FOLDER}            Inbox
${IMAP_PORT}               993
${OTP_TIMEOUT}             120

*** Keywords ***
Configure Selenium
    Set Selenium Speed    5s

Open Browser With Clean Options
    [Arguments]    ${url}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --window-size=1920,1080
    Create WebDriver    Chrome    chrome_options=${options}
    Go To    ${url}

Load Login User Page
    Open Browser With Clean Options    ${STAGING_URL}

Load Login Admin Page
    Open Browser With Clean Options    ${ADMIN_URL}

Login Correct Credentials User
    Load Login User Page
    Input Text       id:emailAddress     ${EMAIL}
    Input Password   id:password         ${EMAIL_PASSWORD}
    Click Element    id:login-button

Login Correct Credentials Admin
    Load Login Admin Page
    Input Text       xpath=//*[@id="app"]/div/div/div[2]/div/form/div[1]/input     ${ADMIN_EMAIL}
    Input Password   xpath=//*[@id="app"]/div/div/div[2]/div/form/div[2]/input     ${ADMIN_PASSWORD}
    Click Element    xpath=//*[@id="app"]/div/div/div[2]/div/form/div[3]/button

Get OTP From Email
    Open Mailbox        host=${IMAP_SERVER}    user=${EMAIL}    password=${IMAP_APP_PASSWORD}    port=${IMAP_PORT}    ssl=True
    ${latest}=          Wait For Email    sender=info@terrasofthq.com   subject=${OTP_SUBJECT}   timeout=${OTP_TIMEOUT}
    ${body}=            Get Email Body    ${latest}
    ${otp}=             Extract OTP From Body    ${body}
    RETURN              ${otp}

Extract OTP From Body
    [Arguments]    ${body}
    ${otp}=        Fetch From Right    ${body}    OTP: 
    ${otp}=        Get Regexp Matches    ${otp}    \d{6}
    RETURN         ${otp}

Input OTP And Verify Login
    [Arguments]    ${otp}
    ${otp_digits}=    Convert To List    ${otp}
    FOR    ${index}    ${digit}    IN ENUMERATE    @{otp_digits}
        Input Text    xpath=(//*[@id="app"]/div/div[2]/div[2]/div/div[2]/div/div/div/div[1]/div/div/div/input[1])[${index + 1}]    ${digit}
        Sleep         0.5s
    END
    Click Button    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div[2]/div/div/div/div[2]/button
