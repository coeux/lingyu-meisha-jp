--algorithms.lua

--[[
获取数组的长度
--]]
function getArrayLengthInner( array )
    local n = 0;
    while array[n+1] do
        n = n + 1
    end
    return n;
end

--[[
冒泡排序
    array 需要排序的数字
    compareFunc 比较函数
--]]
function bubbleSort( array, compareFunc )
    local len = getArrayLengthInner(array)
    local i = len
    while i > 0 do
        j = 1
        while j < len do
            if compareFunc(array[j], array[j+1]) then
                array[j], array[j+1] = array[j+1], array[j]
            end
            j = j + 1
        end
        i = i - 1
    end
end

--[[
选择排序算法
    array 需要排序的数字
    compareFunc 比较函数
--]]
function selectSort( array, compareFunc )
    local len = getArrayLengthInner(array)
    local i = 1
    while i <= len do
        local j = i + 1
        while j <= len do
            if compareFunc(array[i], array[j]) then
                array[i], array[j] = array[j], array[i]
            end
            j = j + 1
        end
        i = i + 1
    end
end

--[[
快速排序方便统一调用
    array 需要排序的数字
    compareFunc 比较函数
--]]
function quickSort( array, compareFunc )
    quickInner(array, 1, getArrayLengthInner(array), compareFunc)
end

--[[
快速排序
    array 需要排序的数字
    left  左边已经完成比较的数组下标
    right 右边已经完成比较的数组下标
    compareFunc 比较函数
--]]
function quickInner( array, left, right, compareFunc )
    if left < right then
        local index = partionInner(array,left,right,compareFunc)
        quickInner(array, left, index - 1, compareFunc)
        quickInner(array, index + 1, right, compareFunc)
    end
end

--[[
快速排序的一趟排序
    array 需要排序的数字
    left  左边已经完成比较的数组下标
    right 右边已经完成比较的数组下标
    compareFunc 比较函数
--]]
function partionInner( array, left, right, compareFunc )
    local key = array[left] -- 哨兵  一趟排序的比较基准
    local index = left
    array[index], array[right] = array[right], array[index]	--与最后一个元素交换
    local i = left
    while i < right do
        if compareFunc( key, array[i]) then
            array[index], array[i] = array[i], array[index]	--发现不符合规则 进行交换
            index = index + 1
        end
        i = i + 1
    end
    array[right], array[index] = array[index], array[right]	--把哨兵放回
    return index;
end
