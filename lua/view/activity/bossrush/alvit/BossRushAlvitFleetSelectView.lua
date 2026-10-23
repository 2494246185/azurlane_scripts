local BossRushAlvitFleetSelectView = class("BossRushAlvitFleetSelectView", import("view.activity.BossRush.BossRushFleetSelectView"))

function BossRushAlvitFleetSelectView:GetTextColor()
	return Color.NewHex("1C231F"), Color.NewHex("979A98")
end

function BossRushAlvitFleetSelectView:getUIName()
	return "BossRushAlvitFleetSelectUI"
end

function BossRushAlvitFleetSelectView:tempCache()
	return true
end

function BossRushAlvitFleetSelectView:didEnter()
	BossRushAlvitFleetSelectView.super.didEnter(self)
	removeOnButton(self._tf:Find("BG"))
	onButton(self, self._tf:Find("BG/close"), function()
		self:onCancelHard()
	end, SFX_CANCEL)

	self.anim = self._tf:GetComponent(typeof(Animation))
	self.animEvent = self.anim:GetComponent(typeof(DftAniEvent))

	self.animEvent:SetEndEvent(function()
		BossRushAlvitFleetSelectView.super.onCancelHard(self)
	end)
end

function BossRushAlvitFleetSelectView:onCancelHard()
	self.anim:Play("anim_kinder_fleetselect_out")
end

return BossRushAlvitFleetSelectView
