-- Login window
local loginWindow = nil
local registerWindow = nil

function showLoginWindow()
    if not loginWindow then
        local screenWidth, screenHeight = guiGetScreenSize()
        local windowWidth, windowHeight = 300, 200
        local x = (screenWidth - windowWidth) / 2
        local y = (screenHeight - windowHeight) / 2
        
        loginWindow = guiCreateWindow(x, y, windowWidth,, windowHeight, "ACNR Login", false)
        guiWindowSetSizable(loginWindow, false)
        
        guiCreateLabel(10, 30, windowWidth-20, 20, "Username:", false, loginWindow)
        local usernameEdit = guiCreateEdit(10, 50, windowWidth-20, 25, "", false, loginWindow)
        
        guiCreateLabel(10, 80, windowWidth-20, 20, "Password:", false, loginWindow)
        local passwordEdit = guiCreateEdit(10, 100, windowWidth-20, 25, "", false, loginWindow)
        guiEditSetMasked(passwordEdit, true)
        
        local loginBtn = guiCreateButton(10, 130, windowWidth-20, 25, "Login", false, loginWindow)
        local registerBtn = guiCreateButton(10, 160, windowWidth-20, 25, "Register", false, loginWindow)
        
        addEventHandler("onClientGUIClick", loginBtn, function()
            local username = guiGetText(usernameEdit)
            local password = guiGetText(passwordEdit)
            if username and password and #username > 0 and #password > 0 then
                triggerServerEvent("onPlayerAttemptLogin", localPlayer, username, password)
                destroyElement(loginWindow)
                loginWindow = nil
            end
        end, false)
        
        addEventHandler("onClientGUIClick", registerBtn, function()
            destroyElement(loginWindow)
            loginWindow = nil
            showRegisterWindow()
        end, false)
    end
    showCursor(true)
end

function showRegisterWindow()
    if not registerWindow then
        local screenWidth, screenHeight = guiGetScreenSize()
        local windowWidth, windowHeight = 300, 200
        local x = (screenWidth - windowWidth) / 2
        local y = (screenHeight - windowHeight) / 2
        
        registerWindow = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR Register", false)
        guiWindowSetSizable(registerWindow, false)
        
        guiCreateLabel(10, 30, windowWidth-20, 20, "Username:", false, registerWindow)
        local usernameEdit = guiCreateEdit(10, 50, windowWidth-20, 25, "", false, registerWindow)
        
        guiCreateLabel(10, 80, windowWidth-20, 20, "Password:", false, registerWindow)
        local passwordEdit = guiCreateEdit(10, 100, windowWidth-20, 25, "", false, registerWindow)
        guiEditSetMasked(passwordEdit, true)
        
        local registerBtn = guiCreateButton(10, 130, windowWidth-20, 25, "Register", false, registerWindow)
        local cancelBtn = guiCreateButton(10, 160, windowWidth-20, 25, "Cancel", false, registerWindow)
        
        addEventHandler("onClientGUIClick", registerBtn, function()
            local username = guiGetText(usernameEdit)
            local password = guiGetText(passwordEdit)
            if username and password and #username > 0 and #password > 0 then
                triggerServerEvent("onPlayerAttemptRegister", localPlayer, username, password)
                destroyElement(registerWindow)
                registerWindow = nil
            end
        end, false)
        
        addEventHandler("onClientGUIClick", cancelBtn, function()
            destroyElement(registerWindow)
            registerWindow = nil
            showLoginWindow()
        end, false)
    end
    showCursor(true)
end

-- Show login window when resource starts
addEventHandler("onClientResourceStart", resourceRoot, function()
    showLoginWindow()
end)

-- Hide cursor when GUI is closed
addEventHandler("onClientGUIClick", root, function()
    if not loginWindow and not registerWindow then
        showCursor(false)
    end
end)

-- Login/Register event handlers
addEvent("onPlayerLoginSuccess", true)
addEventHandler("onPlayerLoginSuccess", root, function()
    showCursor(false)
    outputChatBox("Login successful! Welcome to ACNR!", 0, 255, 0)
end)

addEvent("onPlayerLoginError", true)
addEventHandler("onPlayerLoginError", root, function(error)
    outputChatBox("Login failed: "..error, 255, 0, 0)
    showLoginWindow()
end)

addEvent("onPlayerRegisterSuccess", true)
addEventHandler("onPlayerRegisterSuccess", root, function()
    showCursor(false)
    outputChatBox("Registration successful! You can now login.", 0, 255, 0)
    showLoginWindow()
end)

addEvent("onPlayerRegisterError", true)
addEventHandler("onPlayerRegisterError", root, function(error)
    outputChatBox("Registration failed: "..error, 255, 0, 0)
    showRegisterWindow()
end)
