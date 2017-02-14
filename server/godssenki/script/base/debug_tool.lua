local print = print
local debug = debug
local string = string
local io    = io
local type  = type
local pairs = pairs

module "dt"

function bt()
	local dinfo = debug.getinfo(2)
	local func_line = dinfo.linedefined
	local filename = dinfo.short_src
	local func_name  = dinfo.name or "main"
	print ("func_line:", func_line, filename, func_name)

	local a = 1
	local var_tb = {}
	while true do
		local name, value = debug.getlocal(2, a)
		if not name then break end

		var_tb[name] = value
		print(string.format("%s=", name), value)
		a = a + 1
	end

	while true
	do
		io.write(string.format(">>"))
		local cmd = io.read()
		if cmd == "c" or cmd == "n" or cmd == "go" or cmd == "g"
		then
			break
		end

		local b = string.find(cmd, " ")
		if b == nil
		then
			print ("usage p + var")
		else
			local sub_cmd = string.sub(cmd, 1, b-1)
			if sub_cmd == "p" or sub_cmd == "print"
				or sub_cmd =="dump" or sub_cmd =="d"
			then
				local sub_var = string.sub(cmd, b + 1)
				local value = var_tb[sub_var]
				print(string.format("%s=", sub_var), value)

				if type(value) == "table"
				then
					for k, v in pairs(value)
					do
						print("", k , v)
					end
				end
			else
				print ("usage p + var", sub_cmd)
			end
		end
	end
end

-- bt()
-- print("debug tool load end...")
