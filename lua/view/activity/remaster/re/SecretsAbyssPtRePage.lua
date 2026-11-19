local SecretsAbyssPtRePage = class("SecretsAbyssPtRePage", import("view.activity.CorePage.SecretsAbyss.SecretsAbyssPtPage"))

function SecretsAbyssPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	SecretsAbyssPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function SecretsAbyssPtRePage:OnFirstFlush()
	SecretsAbyssPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function SecretsAbyssPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return SecretsAbyssPtRePage
