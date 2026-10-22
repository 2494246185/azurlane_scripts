local NewYearShrineBuffView = class("NewYearShrineBuffView", import(".ShrineBuffView"))

function NewYearShrineBuffView:getUIName()
	return "NewYearShrineBuff"
end

function NewYearShrineBuffView:initUI()
	NewYearShrineBuffView.super.initUI(self)

	self.dft = GetComponent(self._tf, "DftAniEvent")

	self.dft:SetStartEvent(function()
		setButtonEnabled(self.backBtn, false)
	end)
	self.dft:SetEndEvent(function()
		setButtonEnabled(self.backBtn, true)
	end)
end

return NewYearShrineBuffView
