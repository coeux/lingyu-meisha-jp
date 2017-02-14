local cor = nil

function timer_wait(time_, next_)
    cor = coroutine.create(function() 
        cpp:start_timer(time_)
        coroutine.yield()
        next_()
    end)
end

function timer_hanlde()
    coroutine.resume(cor)
end
