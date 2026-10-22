local QiShengLitUI = class("QiShengLitUI", import(".MainPaintingLitUI"))
local var_0_1 = {
	["Particle System_1"] = {
		translate = true,
		max_particle = 20
	},
	["Particle System_2"] = {
		translate = false,
		max_particle = 20
	}
}

function QiShengLitUI:initLitUI(arg_1_1)
	QiShengLitUI.super.initLitUI(self, arg_1_1)

	self._particleTable = {}

	for iter_1_0, iter_1_1 in pairs(var_0_1) do
		self._particleTable[iter_1_0] = GetComponent(findTF(self._tf, "ad/effect/" .. iter_1_0), "ParticleSystem")
	end
end

function QiShengLitUI:UpdateLit()
	QiShengLitUI.super.UpdateLit(self)
	self:updateEffect()
end

function QiShengLitUI:updateEffect()
	for iter_3_0, iter_3_1 in pairs(var_0_1) do
		local var_3_0 = iter_3_1.translate and iter_3_1.max_particle * (1 - SpinePaintingConst.painting_lit_value) or iter_3_1.max_particle * SpinePaintingConst.painting_lit_value

		if var_3_0 then
			self._particleTable[iter_3_0].main.maxParticles = var_3_0
		end
	end
end

return QiShengLitUI
