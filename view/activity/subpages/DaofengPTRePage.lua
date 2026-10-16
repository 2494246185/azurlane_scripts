local DaofengPTRePage = class("DaofengPTRePage", import(".TemplatePage.PtTemplatePage"))

function DaofengPTRePage:OnUpdateFlush()
	DaofengPTRePage.super.OnUpdateFlush(self)

	local var_1_0, var_1_1, var_1_2 = self.ptData:GetResProgress()

	setText(self.progress, setColorStr(var_1_0, "#915167") .. "/" .. var_1_1)
	LoadImageSpriteAsync(Drop.New(self.ptData:GetRes()):getIcon(), self._tf:Find("AD/icon"), false)
end

return DaofengPTRePage
