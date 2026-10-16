local MonopolyCar2024BubblePage = class("MonopolyCar2024BubblePage")

function MonopolyCar2024BubblePage:Ctor(arg_1_1, arg_1_2)
	self.event = arg_1_2
	self._tf = arg_1_1
	self.head = findTF(arg_1_1, "head"):GetComponent(typeof(Image))
	self.content = findTF(arg_1_1, "chat/Text"):GetComponent(typeof(Text))
	self.anim = self._tf:GetComponent(typeof(Animation))
	self.animEvent = self.anim:GetComponent(typeof(DftAniEvent))

	self.animEvent:SetEndEvent(function()
		setActive(self._tf, false)
	end)

	self.showTime = pg.gameset.monopoly2024_bubble_time.key_value

	setActive(self._tf, false)
end

function MonopolyCar2024BubblePage:GetUiAtlas()
	return "ui/MonopolyCar2024_atlas"
end

function MonopolyCar2024BubblePage:emit(...)
	self.event:emit(...)
end

function MonopolyCar2024BubblePage:Show(arg_5_1, arg_5_2, arg_5_3)
	setActive(self._tf, true)
	self.anim:Play("anim_monopolycar_bubble_show")

	self.head.sprite = GetSpriteFromAtlas(self:GetUiAtlas(), arg_5_2)

	self.head:SetNativeSize()

	self.content.text = pg.activity_event_monopoly_dialogue[arg_5_3].dialogue

	self:AddTimer()
	self:emit(MonopolyCar2024Mediator.ON_DIALOGUE, arg_5_1, arg_5_3)
end

function MonopolyCar2024BubblePage:AddTimer()
	self:RemoveTimer()

	self.timer = Timer.New(function()
		self:RemoveTimer()
		self:Hide()
	end, self.showTime, 1)

	self.timer:Start()
end

function MonopolyCar2024BubblePage:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function MonopolyCar2024BubblePage:Hide()
	self.anim:Play("anim_monopolycar_bubble_hide")
end

function MonopolyCar2024BubblePage:Dispose()
	self:RemoveTimer()
end

return MonopolyCar2024BubblePage
