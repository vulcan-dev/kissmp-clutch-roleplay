local M = {}

require('Addons.VK.globals')

local function AddEvent(execFunc, name, time, runOnce)
    G_TimedEvents[name] = {
        timer = time,
        nextUpdate = 0,
        execFunc = execFunc,
        runOnce = runOnce,
        ran = false,
        name = name,
        firstPass = true
    }
end

local function RemoveEvent(name)
    print('RemoveEvent() ' .. name)
    G_TimedEvents[name] = nil
end

local function Update()
    for _, event in pairs(G_TimedEvents) do
        if not event.ran then
            if os.time() >= event.nextUpdate then
                event.nextUpdate = os.time() + event.timer

                if event.runOnce then
                    if not event.firstPass then
                        event.ran = true

                        G_Try(function ()
                            event.execFunc()
                        end, function ()
                            RemoveEvent(event.name)
                            return
                        end)
                    else
                        event.firstPass = false
                    end

                    event.firstPass = false
                else
                    if not event.firstPass then
                        G_Try(function ()
                            event.execFunc()
                        end, function ()
                            RemoveEvent(event.name)
                            return
                        end)
                    else
                        event.firstPass = false
                    end
                end
            end
        end
    end
end

M.AddEvent = AddEvent
M.RemoveEvent = RemoveEvent
M.Update = Update

return M