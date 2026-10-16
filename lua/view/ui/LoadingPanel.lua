local LoadingPanel = class("LoadingPanel", import("..base.BaseUI"))

function LoadingPanel:Ctor(arg_1_1)
	LoadingPanel.super.Ctor(self)
	seriesAsync({
		function(arg_2_0)
			self:preload(arg_2_0)
		end
	}, function()
		PoolMgr.GetInstance():GetUI("Loading", true, function(arg_4_0)
			arg_4_0.transform:SetParent(GameObject.Find("Overlay/UIOverlay").transform, false)
			arg_4_0:SetActive(false)
			self:onUILoaded(arg_4_0)
			arg_1_1()
		end)
	end)
end

function LoadingPanel:getResource()
	local var_5_0
	local var_5_1, var_5_2 = getLoginConfig()

	if var_5_1 then
		var_5_0 = {
			"effect/" .. var_5_2
		}
	else
		local var_5_3 = LOGIN_HX

		if LOGIN_HX then
			if PlayerProxy.GetDeviceMaxPlayerLevel() > pg.gameset.LOGIN_HX_LV.key_value then
				var_5_3 = false
			end

			local var_5_4

			do
				var_5_3 = true
				var_5_4 = {}
			end
		end

		var_5_4[1] = (var_5_3 and "loadingbg_hx/" or "loadingbg/") .. var_5_2
		var_5_0 = var_5_4
	end

	return table.insertto(var_5_0, LoadingPanel.super.getResource(self))
end

function LoadingPanel:preload(arg_6_1)
	self.isCri, self.bgPath = getLoginConfig()

	if self.isCri then
		LoadAndInstantiateAsync("effect", self.bgPath, function(arg_7_0)
			self.criBgGo = arg_7_0

			if arg_6_1 then
				arg_6_1()
			end
		end)
	else
		local var_6_0 = LOGIN_HX

		if LOGIN_HX then
			if PlayerProxy.GetDeviceMaxPlayerLevel() > pg.gameset.LOGIN_HX_LV.key_value then
				var_6_0 = false
			end

			local var_6_1

			do
				var_6_0 = true
				var_6_1 = LoadSpriteAsync
			end
		end

		var_6_1((var_6_0 and "loadingbg_hx/" or "loadingbg/") .. self.bgPath, function(arg_8_0)
			self.staticBgSprite = arg_8_0

			if arg_6_1 then
				arg_6_1()
			end
		end)
	end
end

function LoadingPanel:init()
	self.infos = self._tf:Find("infos")
	self.infoTpl = self:getTpl("infos/info_tpl")
	self.indicator = self._tf:Find("load")
	self.bg = self._tf:Find("BG")

	self:displayBG(true)
end

function LoadingPanel:appendInfo(arg_10_1)
	local var_10_0 = cloneTplTo(self.infoTpl, self.infos)

	setText(var_10_0, arg_10_1)

	local var_10_1 = LeanTween.alphaCanvas(GetOrAddComponent(var_10_0, "CanvasGroup"), 0, 0.3)

	var_10_1:setDelay(1.5)
	var_10_1:setOnComplete(System.Action(function()
		destroy(var_10_0)
	end))
end

function LoadingPanel:onLoading()
	return self._go.activeInHierarchy
end

local var_0_1 = 0

function LoadingPanel:on(arg_13_1)
	self.displayIndicator = defaultValue(self.displayIndicator, true) and defaultValue(arg_13_1, true)

	setImageAlpha(self._tf, arg_13_1 and 0.01 or 0)

	if not self.displayIndicator then
		setActive(self.indicator, arg_13_1)

		if self.delayTimer then
			pg.TimeMgr.GetInstance():RemoveTimer(self.delayTimer)

			self.delayTimer = nil
		end
	else
		self.delayTimer = self.delayTimer or pg.TimeMgr.GetInstance():AddTimer("loading", 1, 0, function()
			setImageAlpha(self._tf, 0.2)
			setActive(self.indicator, true)
		end)
	end

	if var_0_1 * (var_0_1 + 1) == 0 then
		setActive(self._go, true)
		self._go.transform:SetAsLastSibling()
	end

	var_0_1 = var_0_1 + 1
end

function LoadingPanel:off()
	if var_0_1 * (var_0_1 - 1) == 0 then
		setActive(self._go, false)
		setActive(self.indicator, false)

		self.displayIndicator = true

		if self.delayTimer then
			pg.TimeMgr.GetInstance():RemoveTimer(self.delayTimer)

			self.delayTimer = nil
		end
	end

	var_0_1 = var_0_1 - 1

	assert(var_0_1 >= 0)
end

function LoadingPanel:displayBG(arg_16_1)
	setActive(self.bg, arg_16_1)

	local var_16_0 = GetComponent(self.bg, "Image")

	if arg_16_1 then
		if not self.isCri then
			if IsNil(var_16_0.sprite) then
				var_16_0.sprite = self.staticBgSprite
			end
		elseif self.bg.childCount == 0 then
			var_16_0.enabled = false

			self.criBgGo.transform:SetParent(self.bg.transform, false)
			self.criBgGo.transform:SetAsFirstSibling()

			local var_16_1 = self.criBgGo:GetComponent("AspectRatioFitter")

			if var_16_1 then
				var_16_1.enabled = true
			end
		end
	else
		if not self.isCri then
			var_16_0.sprite = nil
		else
			removeAllChildren(self.bg)
		end

		self.criBgGo = nil
		self.staticBgSprite = nil
	end
end

function LoadingPanel:getRetainCount()
	return var_0_1
end

return LoadingPanel
