otype = type

type = function(obj)
	local mt, o

    o  = otype(obj)
    mt = o == "table" and getmetatable(obj) or nil

	return mt and (otype(mt.__type) == "function" and mt.__type(obj) or mt.__type) or o
end