local FuncBuffer = class("FuncBuffer")

function FuncBuffer:Ctor()
	self.buffers = {}
	self.notifier = false
end

function FuncBuffer:SetNotifier(arg_2_1)
	self.notifier = defaultValue(arg_2_1, false)
end

function FuncBuffer:IsEmpty()
	return #self.buffers <= 0
end

function FuncBuffer:Pop()
	return table.remove(self.buffers, 1)
end

function FuncBuffer:Push(arg_5_1, ...)
	table.insert(self.buffers, {
		funcName = arg_5_1,
		params = {
			...
		},
		paramLength = select("#", ...)
	})
	self:ExcuteAll()
end

function FuncBuffer:ExcuteAll()
	if self.notifier then
		while not self:IsEmpty() do
			local var_6_0 = self:Pop()

			self.notifier[var_6_0.funcName](self.notifier, unpack(var_6_0.params, 1, var_6_0.paramLength))
		end
	end
end

function FuncBuffer:Clear()
	table.clear(self.buffers)
end

function FuncBuffer:__index(arg_8_1)
	return rawget(self, arg_8_1) or FuncBuffer[arg_8_1] or function(arg_9_0, ...)
		self:Push(arg_8_1, ...)
	end
end

return FuncBuffer
