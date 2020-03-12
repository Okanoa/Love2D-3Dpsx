function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		local min_dt = 1/30 --fp
	  local next_time = love.timer.getTime()
		next_time = next_time + min_dt

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			--love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
		  next_time = cur_time
		end
		if love.timer then love.timer.sleep(next_time - cur_time) end
	end
end
