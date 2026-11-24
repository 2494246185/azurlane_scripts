local EasterEggView = class("EasterEggView", import("view.base.BasePanel"))

EasterEggView.ON_CLICK_EASTER_EGG = "EasterEggView::ON_CLICK_EASTER_EGG"

function EasterEggView:Ctor(arg_1_1, arg_1_2, arg_1_3)
	self._go = arg_1_1.gameObject

	EasterEggView.super.Ctor(self, self._go)

	self._parentClass = arg_1_2
	self.scene = arg_1_3

	self:attach(arg_1_2)
	self:Init()
end

function EasterEggView:Init()
	self.uiBtn = findTF(self._tf, "btn")

	local var_2_0 = EasterEggTools.GetActivity()
	local var_2_1 = EasterEggTools.GetTemplateCfgID(var_2_0, self.scene)
	local var_2_2 = pg.activity_secret_template[var_2_1]

	LoadAndInstantiateAsync("ui", pg.activity_secret_template[var_2_1].resource, function(arg_3_0)
		if not IsNil(self._go) then
			arg_3_0.transform:SetParent(self._tf, false)

			arg_3_0.transform.localPosition = Vector3(var_2_2.resource_transform[1][1], var_2_2.resource_transform[1][2], var_2_2.resource_transform[1][3])
			arg_3_0.transform.localEulerAngles = Vector3(var_2_2.resource_transform[2][1], var_2_2.resource_transform[2][2], var_2_2.resource_transform[2][3])
			arg_3_0.transform.localScale = Vector3(var_2_2.resource_transform[3][1], var_2_2.resource_transform[3][2], var_2_2.resource_transform[3][3])
			self.btnEffectGo = arg_3_0
		else
			Object.Destroy(arg_3_0)
		end
	end)

	local var_2_3 = tf(self.uiBtn)

	var_2_3.localPosition = Vector3(pg.activity_secret_template[var_2_1].resource_transform[1][1], pg.activity_secret_template[var_2_1].resource_transform[1][2], pg.activity_secret_template[var_2_1].resource_transform[1][3])
	var_2_3.localEulerAngles = Vector3(pg.activity_secret_template[var_2_1].resource_transform[2][1], pg.activity_secret_template[var_2_1].resource_transform[2][2], pg.activity_secret_template[var_2_1].resource_transform[2][3])
	var_2_3.localScale = Vector3(pg.activity_secret_template[var_2_1].resource_transform[3][1], pg.activity_secret_template[var_2_1].resource_transform[3][2], pg.activity_secret_template[var_2_1].resource_transform[3][3])

	onButton(self, self.uiBtn, function()
		local var_4_0 = {}

		table.insert(var_4_0, function(arg_5_0)
			self:emit(EasterEggView.ON_CLICK_EASTER_EGG, {
				actId = var_2_0.id,
				id = var_2_1,
				cmd = PuzzleActivity.CMD_ACTIVATE,
				callback = function(arg_6_0)
					self:HideClickBtn()

					if self.btnCallBack then
						existCall(self.btnCallBack, arg_6_0, arg_5_0)
					else
						arg_5_0()
					end
				end
			})
		end)

		if var_2_2.effect ~= "" then
			table.insert(var_4_0, function(arg_7_0)
				pg.UIMgr.GetInstance():LoadingOn(false)
				LoadAndInstantiateAsync("ui", var_2_2.effect, function(arg_8_0)
					if not IsNil(self._go) then
						arg_8_0.transform:SetParent(self._tf, false)

						arg_8_0.transform.localPosition = Vector3(var_2_2.effect_transform[1][1], var_2_2.effect_transform[1][2], var_2_2.effect_transform[1][3])
						arg_8_0.transform.localEulerAngles = Vector3(var_2_2.effect_transform[2][1], var_2_2.effect_transform[2][2], var_2_2.effect_transform[2][3])
						arg_8_0.transform.localScale = Vector3(var_2_2.effect_transform[3][1], var_2_2.effect_transform[3][2], var_2_2.effect_transform[3][3])
						self.btnEffectGo2 = arg_8_0

						self:AddHideEasterEggTimer(EasterEggTools.GetHideBtnTime(), function()
							setActive(self.btnEffectGo2, false)
							self:StopEasterEggTimer()
							pg.UIMgr.GetInstance():LoadingOff()
							arg_7_0()
						end)
					else
						Object.Destroy(arg_8_0)
					end
				end)
			end)
		end

		if var_2_2.story ~= "" then
			table.insert(var_4_0, function(arg_10_0)
				pg.NewStoryMgr.GetInstance():Play(var_2_2.story, function()
					existCall(self.storyCallBack, arg_10_0)
				end)
			end)
		else
			table.insert(var_4_0, function(arg_12_0)
				self:StopEasterEggTimer()
				existCall(self.storyCallBack, arg_12_0)
			end)
		end

		seriesAsync(var_4_0, function()
			self:HideEasterEgg()
			self:StopEasterEggTimer()
			self:emit(BaseUI.ON_ADD_SUBLAYER, Context.New({
				viewComponent = EasterEggPopScene,
				mediator = EasterEggPopMediator,
				data = {
					id = var_2_1
				}
			}))
		end)
	end, SFX_CONFIRM)
end

function EasterEggView:SetEasterEggCallBack(arg_14_1, arg_14_2)
	self.btnCallBack = arg_14_1
	self.storyCallBack = arg_14_2
end

function EasterEggView:ShowEasterEgg()
	local var_15_0 = EasterEggTools.IsEnabled(EasterEggTools.GetActivity(), EasterEggConst.EasterEggStoreHouseScene)

	if var_15_0 then
		setActive(self._go, var_15_0)
		self:AddHideEasterEggTimer(EasterEggTools.GetHideBtnTime(), function()
			setActive(self._go, false)
			self:StopEasterEggTimer()
		end)
	end
end

function EasterEggView:HideEasterEgg()
	setActive(self._go, false)
end

function EasterEggView:HideClickBtn()
	setActive(self.uiBtn, false)
	setActive(self.btnEffectGo, false)
end

function EasterEggView:AddHideEasterEggTimer(arg_19_1, arg_19_2)
	self:StopEasterEggTimer()

	self.easterEggTimer = Timer.New(function()
		arg_19_2()
	end, arg_19_1, 1)

	self.easterEggTimer:Start()
end

function EasterEggView:StopEasterEggTimer()
	if self.easterEggTimer then
		self.easterEggTimer:Stop()

		self.easterEggTimer = nil
	end
end

function EasterEggView:willExit()
	self:detach()
	self:StopEasterEggTimer()

	if self.btnEffectGo then
		Object.Destroy(self.btnEffectGo)

		self.btnEffectGo = nil
	end

	if self.btnEffectGo2 then
		Object.Destroy(self.btnEffectGo2)

		self.btnEffectGo2 = nil
	end
end

return EasterEggView
