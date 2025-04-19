local WeightedList = {}
WeightedList.__index = WeightedList

function WeightedList.new()
    return setmetatable({ items = {} }, WeightedList)
end

function WeightedList:add(item, weight)
    table.insert(self.items, { value = item, weight = weight })
end

function WeightedList:totalWeight()
    local total = 0
    for _, entry in ipairs(self.items) do
        total = total + entry.weight
    end
    return total
end

function WeightedList:pick()
    local total = self:totalWeight()
    local r = math.random() * total
    local sum = 0
    for _, entry in ipairs(self.items) do
        sum = sum + entry.weight
        if r <= sum then
            return entry.value
        end
    end
end

function WeightedList:getChances()
    local total = self:totalWeight()
    local chances = {}
    for _, entry in ipairs(self.items) do
        table.insert(chances, {
            value = entry.value,
            weight = entry.weight,
            percent = (entry.weight / total) * 100
        })
    end
    return chances
end
