local LoveLetterSelectCharConfirmLayer = class("LoveLetterSelectCharConfirmLayer", import("view.base.BaseUI"))

function LoveLetterSelectCharConfirmLayer:getUIName()
	return "LoveLetterGroupSelectUI"
end

LoveLetterSelectCharConfirmLayer.optionsPath = {}

function LoveLetterSelectCharConfirmLayer:init()
	setText(self.btnCancel:Find("cancel"), i18n("text_cancel"))
	setText(self.btnConfirm:Find("confirm"), i18n("text_confirm"))
	onButton(self, self.btnCancel, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnConfirm, function()
		self:emit(LoveLetterSelectCharConfirmMediator.SELECT_CHAR, self.ll.groupId)
	end, SFX_CONFIRM)
	self:BlurPanel(self._tf)
end

function LoveLetterSelectCharConfirmLayer:SetLoveLetter(arg_5_1)
	self.ll = getProxy(LoveLetterProxy):GetGroupData(arg_5_1)
end

function LoveLetterSelectCharConfirmLayer:SetActivity(arg_6_1)
	self.activity = getProxy(ActivityProxy):getActivityById(arg_6_1)

	if self.contextData.isRepair then
		setText(self.textHelp, i18n("loveletter2018_ui_3"))
	else
		local var_6_0, var_6_1 = self.activity:GetChangeCount()

		setText(self.textHelp, i18n("loveactivity_ui_12", var_6_1 - var_6_0, var_6_1))
	end
end

function LoveLetterSelectCharConfirmLayer:didEnter()
	self:UpdateDisplay()
end

function LoveLetterSelectCharConfirmLayer:UpdateDisplay()
	self:UpdatePainting()

	if self.contextData.isRepair then
		setText(self.textInfo, i18n("loveletter2018_ui_2", self.ll:GetName()))
	else
		setText(self.textInfo, i18n("loveactivity_ui_11", setColorStr(self.ll:GetName(), "#f3709e")))
	end
end

function LoveLetterSelectCharConfirmLayer:UpdatePainting()
	local var_9_0 = self.ll:GetPainting()

	if self.paint == var_9_0 then
		return
	end

	if self.paint then
		retPaintingPrefab(self.rtPainting, self.paint)

		self.paint = nil
	end

	self.paint = var_9_0

	setPaintingPrefabAsync(self.rtPainting, self.paint, "biandui")
end

function LoveLetterSelectCharConfirmLayer:willExit()
	self:UnOverlayPanel(self._tf)

	if self.paint then
		retPaintingPrefab(self.rtPainting, self.paint)

		self.paint = nil
	end
end

return LoveLetterSelectCharConfirmLayer
