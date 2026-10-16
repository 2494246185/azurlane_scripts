local AsyncExcutionRequestPackage = class("AsyncExcutionRequestPackage", import(".RequestPackage"))

function AsyncExcutionRequestPackage:__call(...)
	if self.stopped then
		return
	end

	if not self.funcs or #self.funcs == 0 then
		return
	end

	self:Excute(...)
end

function AsyncExcutionRequestPackage:Resume()
	self.suspended = nil

	if self.ready then
		if self.resume then
			self.resume = nil

			self:Excute(unpack(self.resume.params, self.resume.paramLength))
		else
			self:Excute()
		end
	end
end

function AsyncExcutionRequestPackage:Suspend()
	self.suspended = true
end

function AsyncExcutionRequestPackage:Ctor(arg_4_1)
	self.ready = true
	self.funcs = arg_4_1
	self.suspended = nil
	self.resume = nil
end

function AsyncExcutionRequestPackage:Insert(arg_5_1)
	table.insert(self.funcs, arg_5_1)
end

function AsyncExcutionRequestPackage:Excute(...)
	assert(self.ready)

	if not self.ready then
		return
	end

	local function var_6_1(...)
		if self.stopped then
			return
		end

		if self.suspended or not self.funcs or #self.funcs <= 0 then
			self.resume = {
				params = {
					...
				},
				paramLength = select("#", ...)
			}
			self.ready = true

			return
		end

		self.ready = nil

		table.remove(self.funcs, 1)(var_6_1, ...)
	end

	;(nil)(...)
end

return AsyncExcutionRequestPackage
