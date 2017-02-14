collectgarbage('setpause', 100)
collectgarbage('setstepmul', 5000)

function start()
    local bag = ys_lua:get_bag_pt()

    print(" ")
    print("1,1,1,2")
    print(bag:add(1,1,1,2))
    bag:dump()

    print(" ")
    print("1,1,1,2")
    bag:set_size(1)
    print(bag:add(1,1,1,2))
    bag:dump()

    print(" ")
    print("1,1,1,2")
    print(bag:add(1,1,1,2))
    bag:dump()

    print(" ")
    print("1,1,1,2")
    bag:set_size(2)
    print(bag:add(1,1,1,2))
    bag:dump()

    print(" ")
    print("1,1,1,2")
    print(bag:add(1,1,1,2))
    bag:dump()

    print(" ")
    bag:set_size(3)
    print("2,2,1,1")
    print(bag:add(2,2,1,1))
    bag:dump()

    print(" ")
    print("2,2,99,1")
    print(bag:add(2,2,99,1))
    bag:dump()

    print(" ")
    print("2,2,98,1")
    print(bag:add(2,2,98,1))
    bag:dump()

    print(" ")
    bag:del(1,1,1,2)
    bag:dump()
end
