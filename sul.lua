local time = require("timer")
local http = require("coro-http")
local json = require("json")

local sul = {
    API = {
        LatestCommit = "https://gitlab.com/api/v4/projects/60830036/repository/commits?per_page=1"
    },

    Events = {},
    Functions = {}
}

function sul.Functions.Get(endpoint)
    assert(type(endpoint) == "string" or endpoint ~= "", "Invalid endpoint: must be a non-empty string.")

    local response, body = http.request("GET", endpoint)
    assert(response, "No response received from HTTP request.")
    assert(response.statusCode ~= 404, "Status 404!")

    return body or "No body content returned."
end

function sul.Events.OnCommit(interval, callback)
    assert(type(interval) == "number", "Expected number for interval, got " .. type(interval))
    assert(type(callback) == "function", "Expected function for callback, got " .. type(callback))
    
    coroutine.wrap(function()
        while true do
            local latest_commit = sul.Functions.Get(sul.API.LatestCommit)
            
            local file = io.open("LatestCommit.json", "r"); local current_commit = file and file:read("*all") or "{}"
            if file then file:close() end
            
            local unix_timestamp = os.time(); local current_time = os.date("%Y-%m-%d %H:%M:%S", unix_timestamp)

            if tostring(current_commit) ~= tostring(latest_commit) then
                file = io.open("LatestCommit.json", "w")
                if file then
                    file:write(latest_commit)
                    file:close()
                end

                latest_commit = json.decode(latest_commit)[1]
                callback(latest_commit, unix_timestamp, current_time)
            end

            time.sleep(tonumber(interval) * 1000)
        end
    end)()
end


return sul