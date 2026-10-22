local ObjectBreakable = class("ObjectBreakable", import("view.miniGame.gameView.RyzaMiniGame.object.TargetObject"))

function ObjectBreakable:FirePassability()
	return 1
end

function ObjectBreakable:InitUI(arg_2_1)
	self._tf:Find("Image"):GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		self:TryDrop(arg_2_1.drop, "Drop")
		self:Destroy()
	end)
end

function ObjectBreakable:InitRegister(arg_4_1)
	self:Register("burn", function()
		self:Break()
	end, {
		{
			0,
			0
		}
	})
	self:Register("break", function()
		self:Break()
	end, {})
end

function ObjectBreakable:Break()
	self:DeregisterAll()
	self._tf:Find("Image"):GetComponent(typeof(Animator)):Play("Break")
end

return ObjectBreakable
