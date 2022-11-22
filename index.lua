local computer = require('computer')
local component = require('component')
local JSON = (loadfile "JSON.lua")()
local itemConfig = io.open("config.json", "r")
local redstone = component.redstone
local transposer = component.transposer
local reactor_chamber = component.reactor_chamber
-- 北:2
-- x东:5
-- 西:4
-- z南:3
local sourceBoxSide = 4 -- 输入箱子
local reactorChamberSide = 3 -- 核电仓
local outPutBoxSide = 2 -- 输出箱子
local outPutDrawerSide = 0 -- 输出抽屉

-- 检查原材料箱中原材料数量
local function checkSourceBoxItems(itemName, itemCount)
    local itemSum = 0
    local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()

    for index, item in pairs(sourceBoxitemList) do
        if item.name then
            if item.name == itemName then
                itemSum = itemSum + item.size
            end
        end
    end

    if itemSum >= itemCount then
        return true
    else
        return false
    end
end

-- 选择配置文件中的项目
local function configSelect()
    print("Please enter config project:")
    local project = io.read()

    if itemConfig then
        local ItemConfig_table = JSON:decode(itemConfig:read("*a"))

        if (ItemConfig_table[project]) then
            itemConfig:close()
            return ItemConfig_table[project]
        else
            print("The project name you entered could not be found.")
            itemConfig:close()
            os.exit(0)
        end
    else
        print("config.json not found.")
        os.exit(0)
    end

end

-- 停止核电仓
local function stop()
    redstone.setOutput(reactorChamberSide, 0)
end

--启动核电仓
local function start()
    redstone.setOutput(reactorChamberSide, 14)
end

-- 向核电仓中转移原材料
local function insertItemsIntoReactorChamber(project)
    local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChamberLenth = reactorChamber.count()
    local projectLenth = #project

    for i = 1, projectLenth do
        for indexJ, j in pairs(project[i].slot) do
            for index, item in pairs(sourceBoxitemList) do
                if item.name == project[i].name then
                    transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, index + 1, j)
                end
            end
        end
    end
end

-- 核电仓热量检测
local function checkReactorChamberHeat()
    if (reactor_chamber.getHeat() >= 1000) then
        stop()
    elseif (reactor_chamber.getHeat() < 1000) then
        start()
    end
end

-- 寻找指定方向储物设备空slot
local function findNullSlot(boxSide)
    local box = transposer.getAllStacks(boxSide)
    for slot, item in pairs(box) do
        if not (item) then
            print("slot--->" .. slot + 1)
            return slot + 1
        end
    end
end

-- 物品移除和移入核电仓
local function removeAndInsert(removeSlot, removeSide, insertItemName)
    stop()
    transposer.transferItem(reactorChamberSide, removeSide, 1, removeSlot, findNullSlot(removeSide))

    while true do
        local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()
        if checkSourceBoxItems(insertItemName, 1) then
            for index, item in pairs(sourceBoxitemList) do
                if item.name == insertItemName then
                    transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, index + 1, removeSlot)
                    break
                end
            end
            break
        else
            print(insertItemName .. "-------is not enough")
            for i = 10, 1, -1 do
                print("Recheck after " .. i .. " seconds")
                os.sleep(1)
            end
        end
    end

    checkReactorChamberHeat()
end

-- 物品监测（需要监测DMG和不需要监测DMG）
local function checkItemDMG(project)
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChamberLenth = reactorChamber.count()
    local reactorChamberList = reactorChamber.getAll()

    for i = 1, #project do
        for index, slot in pairs(project[i].slot) do
            if project[i].dmg ~= -1 then
                if reactorChamberList[slot - 1].damage >= project[i].dmg then
                    removeAndInsert(slot, outPutBoxSide, project[i].name)
                end
            elseif project[i].dmg == -1 then
                -- print("reactorChamberList[slot - 1].name----->"..reactorChamberList[slot - 1].name)
                -- print("project[i].name---->"..project[i].name)
                -- print("project[i].changeName--->"..project[i].changeName)
                if reactorChamberList[slot - 1].name ~= project[i].name and
                    reactorChamberList[slot - 1].name == project[i].changeName then
                    removeAndInsert(slot, outPutDrawerSide, project[i].name)
                end
            end
        end
    end
end

-- 检查核电仓是否塞满
local function isReactorChamberFull()
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChamberList = reactorChamber.getAll()
    local reactorChamberLenth = reactorChamber.count()

    local sum = 0
    for slot, item in pairs(reactorChamberList) do
        if item ~= nil then
            sum = sum + 1
        end
    end
    if sum == reactorChamberLenth then
        return true
    else
        return false
    end
end

-- 核电仓运行时
local function reactorChamberRunTime(project)
    while true do
        checkReactorChamberHeat()
        checkItemDMG(project)
    end
end

-- 从配置文件启动
local function startWithConfig()
    local project = configSelect()
    local projectLenth = #project
    local whileFlag = true
    local isOK = 0

    while whileFlag do
        isOK = 0
        -- 判断并输出原材料箱中原材料是否满足
        for i = 1, projectLenth do
            if checkSourceBoxItems(project[i].name, project[i].count) then
                print(project[i].name .. "-------is ok")
                isOK = isOK + 1
            else
                print(project[i].name .. "-------is not enough")
            end
        end

        if isOK == projectLenth then
            whileFlag = false
            -- 向核电仓中转移原材料
            local status, retval = pcall(insertItemsIntoReactorChamber, project)
            -- 启动强冷核电
            if status then
                reactorChamberRunTime(project)
            else
                print(retval)
            end
        else
            for i = 10, 1, -1 do
                print("Recheck after " .. i .. " seconds")
                os.sleep(1)
            end
        end
    end
end

-- 直接启动
local function justStart()
    local project = configSelect()
    reactorChamberRunTime(project)
end

local function startSelect()
    stop()
    print("Please select start with config(0) or just start(1):")
    while true do
        local select = io.read()
        if select == "0" then
            startWithConfig()
            break
        elseif select == "1" then
            justStart()
            break
        elseif select == "-1" then
            os.exit(0)
        else
            print("Please enter [0]:start with config or [1]:just start:")
        end

    end
end

startSelect()
