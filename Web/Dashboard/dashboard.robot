*** Settings ***
Library           SeleniumLibrary
Library           String
Suite Setup       Load Login User Page
Suite Teardown    Close Browser

*** Variables ***
${staging_url}    https://admindb-dev.terrasofthq.com
${token}          2|SAXQXLC7GUUIEWRHFPDPPO62O3KGRCIY
${browser}        Chrome

*** Test Cases ***
Open Dashboard in browser with token
    [Documentation]    Open browser using the login token
    Go To    ${staging_url}/login?token=${token}
    Location Should Contain    dashboard

*** Keywords ***
Load Login User Page
    ${profile}=    Generate Random String    10
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --user-data-dir=/tmp/chrome-profile-${profile}
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --disable-gpu
    Create WebDriver    Chrome    options=${options}
    Maximize Browser Window
