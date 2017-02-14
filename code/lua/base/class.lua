--class.lua

--========================================================================
--类定义

local _class={}

function class(super)
	local class_type={}
	class_type.constructor=false
	class_type.__super=super
	class_type.new=function(...)
			local obj={}
			
			do
				local create;
				create = function(c,...)
					if c.__super then
						create(c.__super,...)
					end
					if c.constructor then
						setmetatable(obj, { __index=c })
						c.constructor(obj,...)
					end
				end
 
				create(class_type,...)
			end

			setmetatable(obj, { __index=class_type })
			return obj
		end

	local vtbl={}
	_class[class_type]=vtbl

	if super then
		setmetatable(class_type,{__index=
			function(t,k)
				local ret = vtbl[k];
				if ret == nil then
					ret = super[k];
					vtbl[k] = ret;
				end

				return ret;
			end
		})
	end
 
	return class_type
end
