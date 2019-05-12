TRPG = {} --Create the meta table at the start

--Load in all mod files
for _,v in pairs(file.Find("TristRPG/*.lua","LUA")) do
    include("TristRPG/" .. v)
end

print("TristRPG Successfully Loaded!")