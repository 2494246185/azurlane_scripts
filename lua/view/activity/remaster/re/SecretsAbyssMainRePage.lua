local SecretsAbyssMainRePage = class("SecretsAbyssMainRePage", import("view.activity.CorePage.SecretsAbyss.SecretsAbyssMainPage"))

function SecretsAbyssMainRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	SecretsAbyssMainRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function SecretsAbyssMainRePage:OnFirstFlush()
	SecretsAbyssMainRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function SecretsAbyssMainRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return SecretsAbyssMainRePage
