local EasterEggPopScene = class("EasterEggPopScene", import("view.base.BaseUI"))

function EasterEggPopScene:getUIName()
	return "EasterEggPopUI"
end

function EasterEggPopScene:init()
	onButton(self, self.uiCloseBtn, function()
		if self.canClose then
			self:closeView()
		end
	end, SFX_PANEL)

	self.aniEvent = self._tf:GetComponent(typeof(DftAniEvent))

	self.aniEvent:SetEndEvent(function()
		self.canClose = true
	end)
end

function EasterEggPopScene:didEnter()
	self:OverlayPanel(self._tf, {
		pbList = {
			self.uiBg
		}
	})
	setImageSprite(self.uiContentImage, GetSpriteFromAtlas(pg.activity_secret_template[self.contextData.id].desc[1], pg.activity_secret_template[self.contextData.id].desc[2]), true)
	self:PlayVoice(pg.activity_secret_template[self.contextData.id].voice)
end

function EasterEggPopScene:PlayVoice(arg_6_1)
	if arg_6_1 == "" then
		return
	end

	local var_6_0 = arg_6_1[math.random(1, #arg_6_1)]

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(var_6_0, function(arg_7_0)
		return
	end)

	self.cvPath = var_6_0
end

function EasterEggPopScene:StopVoice()
	if self.cvPath ~= nil then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self.cvPath)
	end
end

function EasterEggPopScene:willExit()
	self:StopVoice()
	self.aniEvent:SetEndEvent(nil)
	self:UnOverlayPanel(self._tf)
end

function EasterEggPopScene:onBackPressed()
	if self.canClose then
		EasterEggPopScene.super.onBackPressed(self)
	end
end

return EasterEggPopScene
