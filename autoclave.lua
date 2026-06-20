local AUTOCLAVE_ID = 4322

local AUTOCLAVE_ITEMS = {
    1262,
    1264,
    4314,
    4312,
    4318,
    4308,
    1260,
    1268,
    1258,
    4310,
    4316
}

local function count(id)
    return getBot():getInventory():findItem(id) or 0
end

local function findAutoclave()

    for _, tile in pairs(getTiles()) do
        if tile.fg == AUTOCLAVE_ID then
            return tile.x, tile.y
        end
    end

    return nil, nil
end

local function dropStitches()

    while count(1270) >= 200 do

        getBot():drop(1270, 200)

        print(
            string.format(
                "[AUTOCLAVE] Dropped 200 Stitches"
            )
        )

        sleep(1000)
    end
end

local function getHighestItem()

    local bestId = nil
    local bestCount = 0

    for _, id in ipairs(AUTOCLAVE_ITEMS) do

        local amount = count(id)

        if amount >= CONFIG.MIN_ITEM and amount > bestCount then
            bestId = id
            bestCount = amount
        end
    end

    return bestId, bestCount
end

local function refillTools()

    print("[AUTOCLAVE] Refill tools...")

    getBot():warp(
        CONFIG.STORAGE_WORLD,
        CONFIG.STORAGE_DOOR
    )

    sleep(CONFIG.REFILL_WAIT)

    getBot().auto_collect = true

    sleep(10000)

    getBot():warp(
        CONFIG.AUTOCLAVE_WORLD,
        CONFIG.AUTOCLAVE_DOOR
    )

    sleep(CONFIG.REFILL_WAIT)

    local x, y = findAutoclave()

    if x then
        getBot():findPath(x, y - 1)
        sleep(1000)
    end
end

local function autoclaveOnce(x, y, itemID)

    getBot():wrench(x, y)
    sleep(700)

    getBot():sendPacket(2,
        "action|dialog_return\n" ..
        "dialog_name|autoclave\n" ..
        "tilex|" .. x .. "|\n" ..
        "tiley|" .. y .. "|\n" ..
        "buttonClicked|tool" .. itemID
    )

    sleep(250)

    getBot():sendPacket(2,
        "action|dialog_return\n" ..
        "dialog_name|autoclave\n" ..
        "tilex|" .. x .. "|\n" ..
        "tiley|" .. y .. "|\n" ..
        "itemID|" .. itemID .. "|\n" ..
        "buttonClicked|verify"
    )

    sleep(1800)
end

local x, y = findAutoclave()

if not x then
    print("Autoclave tidak ditemukan.")
    return
end

getBot():findPath(x, y - 1)
sleep(1000)

while true do

    dropStitches()

    local itemID, amount = getHighestItem()

    if not itemID then

        refillTools()

        itemID, amount =
            getHighestItem()

        if not itemID then
            print("[AUTOCLAVE] Storage kosong.")
            break
        end
    end

    print(
        string.format(
            "[AUTOCLAVE] %d (%d)",
            itemID,
            amount
        )
    )

    autoclaveOnce(
        x,
        y,
        itemID
    )

    sleep(1000)
end