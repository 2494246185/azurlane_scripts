local UIAnim = class("UIAnim", import("...BaseEntity"))

UIAnim.Fields = {
	playing = "boolean",
	aniEvent = "userdata",
	onEnd = "function",
	transform = "userdata",
	prefab = "string",
	onTrigger = "function",
	onStart = "function"
}
UIAnim.EventLoaded = "UIAnim.EventLoaded"

function UIAnim:Setup(arg_1_1)
	self.prefab = arg_1_1
end

function UIAnim:Dispose()
	self:Unload()
	self:Clear()
end

function UIAnim:Load()
	local var_3_0 = self.prefab
	local var_3_1 = PoolMgr.GetInstance()

	var_3_1:GetUI(self.prefab, true, function(arg_4_0)
		if var_3_0 == self.prefab then
			self.transform = arg_4_0.transform

			self:Init()
			self:DispatchEvent(UIAnim.EventLoaded)
		else
			var_3_1:ReturnUI(var_3_0, arg_4_0)
		end
	end)
end

function UIAnim:Unload()
	if self.prefab and self.transform then
		PoolMgr.GetInstance():ReturnUI(self.prefab, self.transform.gameObject)
	end

	self.prefab = nil
	self.transform = nil
end

function UIAnim:Play(arg_6_1)
	self.playing = true
	self.onStart = nil
	self.onTrigger = nil
	self.onEnd = arg_6_1

	self:Update()
end

function UIAnim:Stop()
	self.playing = false

	self:Update()
end

function UIAnim:Init()
	setActive(self.transform, false)

	self.aniEvent = self.transform:GetComponent("DftAniEvent")

	self:Update()
end

function UIAnim:Update()
	if self.aniEvent then
		setActive(self.transform, self.playing)

		if self.playing then
			self.aniEvent:SetStartEvent(function()
				if self.onStart then
					self.onStart()
				end
			end)
			self.aniEvent:SetTriggerEvent(function()
				if self.onTrigger then
					self.onTrigger()
				end
			end)
			self.aniEvent:SetEndEvent(function(arg_12_0)
				self:Stop()

				if self.onEnd then
					self.onEnd()
				end
			end)
		end
	end
end

return UIAnim
