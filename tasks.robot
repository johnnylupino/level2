*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.PDF
Library             RPA.FileSystem
Library             OperatingSystem
Library             RPA.Archive


*** Variables ***
${FINAL_FILES_DIR}      ${OUTPUT_DIR}${/}final_pdf


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download csv
    Run Keyword And Continue On Failure    Get orders
    ZIP All receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Close the annoying modal
    Click Button    css:.alert-buttons .btn-dark

Fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input.form-control    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Element When Visible    id:preview

Submit order
    Click Button    id:order

Order another
    Click Button    id:order-another

Get orders
    ${orders}=    Read table from CSV    orders.csv

    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Run Keyword And Continue On Failure    Fill the form    ${row}
        Click Element When Visible    id:order
        ${order_page_html}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${order_page_html}    ${OUTPUT_DIR}${/}receipts${/}${row}[Order number].pdf
        Wait Until Keyword Succeeds    5 x    10 s    Take a screenshot of the robot    ${row}
        ${pdf}=    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}${row}[Order number].pdf
        ${screenshot}=    Create List    ${OUTPUT_DIR}${/}images${/}${row}[Order number].png
        ...    ${OUTPUT_DIR}${/}receipts${/}${row}[Order number].pdf
        Add Files To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}final${/}receipt${row}[Order number].pdf
        Order another
    END

Store the order receipt as a PDF file
    [Arguments]    ${row}
    ${order_page_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_page_html}    ${OUTPUT_DIR}${/}receipts${/}${row}[Order number].pdf

Take a screenshot of the robot
    [Arguments]    ${row}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}images${/}${row}[Order number].png

ZIP All receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}final    final_pdfs.zip
