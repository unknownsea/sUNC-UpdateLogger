local sul = require("./sul.lua")
local discordia = require('discordia')
local client = discordia.Client()

local file = io.open(".env", "r")
local token = file and file:read("*a"):match("DISCORD_BOT_TOKEN=(%S+)")
if file then file:close() end
assert(token, "Bot token not found in .env file")

sul.Events.OnCommit(2.5, function(latest_commit, unix, current_time)
    local channel = client:getChannel("1315204426075738136")
    if channel then
        channel:send{
            embed = {
                title = "**sUNC Updated**",
                description = "[Commit](" .. latest_commit.web_url .. ")",
                fields = {
                    {
						name = "",
						value = "```\n" .. latest_commit.title .. "```",
						inline = false
					},
                    {
						name = "",
						value = "```\n" .. latest_commit.message .. "```",
						inline = false
					},
                },
                footer = {
                    text = latest_commit.author_name .. " | " .. latest_commit.created_at
                },
                color = 0x000000
            }
        }
    else
        print("Channel not found!")
    end
end)

client:run('Bot ' .. token)