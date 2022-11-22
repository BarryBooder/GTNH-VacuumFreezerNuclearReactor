local computer = require('computer')
local component = require('component')
local JSON = (loadfile "JSON.lua")()
local itemConfig = io.open("config.json", "r")
local redstone = component.redstone
local transposer = component.transposer
local reactor_chamber = component.reactor_chamber
local sourceBoxSide = 3
local reactorChamberSide = 2
local outPutBoxSide = 5
local outPutDrawerSide = 0
local sum = 0

local function checkItemsCount(itemName, itemCount)
    local inventorySize = transposer.getInventorySize(sourceBoxSide)
    local inventoryItemCount = 0

    for i = 1, inventorySize, 1 do
        if transposer.getStackInSlot(sourceBoxSide, i) ~= nil then
            if transposer.getStackInSlot(sourceBoxSide, i).name == itemName then
                inventoryItemCount = inventoryItemCount + transposer.getSlotStackSize(sourceBoxSide, i)
            end
        end
    end
    if inventoryItemCount >= itemCount then
        return true
    else
        return false
    end
end

local function insertItemsIntoReactorChamber(ItemConfig_table)
    local inventorySize = transposer.getInventorySize(sourceBoxSide)
    for index, itemList in pairs(ItemConfig_table) do

        for i = 1, itemList.count, 1 do
            for j = 1, inventorySize, 1 do
                if transposer.getStackInSlot(sourceBoxSide, j) ~= nil then
                    if transposer.getStackInSlot(sourceBoxSide, j).name == itemList.name then
                        transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, j, itemList.slot[i])
                        break
                    end
                end
            end
        end
    end

end

local function preparatoryWork()
    if itemConfig then
        -- 读取物品配置文件并转换为表
        local ItemConfig_table = JSON:decode(itemConfig:read("*a"))

        -- 开始遍历配置文件中的配置项
        local isCanBuild = true
        for index, itemList in pairs(ItemConfig_table) do
            if (checkItemsCount(itemList.name, itemList.count)) then
                print(itemList.name .. "--------OK")
            else
                print(itemList.name .. "--------is not enough")
                isCanBuild = false
            end
        end

        -- 开始往核电仓中塞物品
        if isCanBuild then
            insertItemsIntoReactorChamber(ItemConfig_table)
        else
            os.exit(0)
        end
        itemConfig:close()
    else
        print("itemConfig.json not found!")
    end
end

local function checkNuclearBunkerHeat()
    -- print(reactor_chamber.getHeat())
    if (reactor_chamber.getHeat() >= 3000) then
        redstone.setOutput(reactorChamberSide, 0)
    elseif (reactor_chamber.getHeat() < 3000) then
        redstone.setOutput(reactorChamberSide, 14)
    end
end

local function is_item_exist(itemName)
    local temp = transposer.getAllStacks(sourceBoxSide).getAll()
    local item_is_exist = false
    for index, value in pairs(temp) do
        if value.name == itemName then
            item_is_exist = true
        end
    end
    return item_is_exist
end

local function checkReactorChamberItemsDMG()
    local inventorySize = transposer.getInventorySize(reactorChamberSide)
    local inventorySize_box = transposer.getInventorySize(outPutBoxSide)

    for i = 1, inventorySize, 1 do
        checkNuclearBunkerHeat()
        if transposer.getStackInSlot(reactorChamberSide, i) ~= nil then
            if transposer.getStackInSlot(reactorChamberSide, i).name == "gregtech:gt.360k_Helium_Coolantcell" then
                if transposer.getStackInSlot(reactorChamberSide, i).damage >= 10 then

                    -- 如果监测到有dmg符合条件的冷却剂，先暂停反应堆运行
                    redstone.setOutput(reactorChamberSide, 0)

                    for j = 1, inventorySize_box, 1 do
                        if transposer.getStackInSlot(outPutBoxSide, j) ~= nil then
                            sum = sum + 1
                        else

                            transposer.transferItem(reactorChamberSide, outPutBoxSide, 1, i, j)

                            if is_item_exist("gregtech:gt.360k_Helium_Coolantcell") then
                                for k = 1, inventorySize_box, 1 do
                                    if transposer.getStackInSlot(sourceBoxSide, k) ~= nil then
                                        if transposer.getStackInSlot(sourceBoxSide, k).name ==
                                            "gregtech:gt.360k_Helium_Coolantcell" then
                                            transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, k, i)
                                            break
                                        end
                                    end
                                end
                                redstone.setOutput(reactorChamberSide, 14)
                                break
                            else
                                print("gregtech:gt.360k_Helium_Coolantcell-------is not enough")
                                while true do
                                    if is_item_exist("gregtech:gt.360k_Helium_Coolantcell") then
                                        for l = 1, inventorySize_box, 1 do
                                            if transposer.getStackInSlot(sourceBoxSide, l) ~= nil then
                                                if transposer.getStackInSlot(sourceBoxSide, l).name ==
                                                    "gregtech:gt.360k_Helium_Coolantcell" then
                                                    transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, l, i)
                                                    break
                                                end
                                            end
                                        end
                                        break
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            elseif transposer.getStackInSlot(reactorChamberSide, i).name == "IC2:reactorUraniumQuaddepleted" then

                -- 如果监测到枯竭燃料棒，先暂停反应堆运行
                redstone.setOutput(reactorChamberSide, 0)

                transposer.transferItem(reactorChamberSide, outPutDrawerSide, 1, i, 1)

                if is_item_exist("gregtech:gt.reactorUraniumQuad") then
                    for k = 1, inventorySize_box, 1 do
                        if transposer.getStackInSlot(sourceBoxSide, k) ~= nil then
                            if transposer.getStackInSlot(sourceBoxSide, k).name ==
                                "gregtech:gt.reactorUraniumQuad" then
                                transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, k, i)
                                break
                            end
                        end
                    end
                    redstone.setOutput(reactorChamberSide, 14)
                    break
                else
                    print("gregtech:gt.reactorUraniumQuad-------is not enough")
                    while true do
                        if is_item_exist("gregtech:gt.reactorUraniumQuad") then
                            for l = 1, inventorySize_box, 1 do
                                if transposer.getStackInSlot(sourceBoxSide, l) ~= nil then
                                    if transposer.getStackInSlot(sourceBoxSide, l).name ==
                                        "gregtech:gt.reactorUraniumQuad" then
                                        transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, l, i)
                                        break
                                    end
                                end
                            end
                            break
                        end
                    end
                end

            end
        end
    end
end

local function main()
    preparatoryWork()
    while true do
        checkReactorChamberItemsDMG()
    end
end

main()

-- 北:2
-- x东:5
-- 西:4
-- z南:3
