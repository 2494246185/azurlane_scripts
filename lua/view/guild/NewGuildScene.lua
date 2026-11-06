local NewGuildScene = class("NewGuildScene", import("..base.BaseUI"))

function NewGuildScene:getUIName()
	return "NewGuildUI"
end

function NewGuildScene:getResource()
	return table.insertto({
		"commonbg/camp_bg",
		"clutter/blhx_icon",
		"clutter/cszz_icon"
	}, NewGuildScene.super.getResource(self))
end

function NewGuildScene:ResUISettings()
	return true
end

function NewGuildScene:setPlayer(arg_4_1)
	self.playerVO = arg_4_1
end

function NewGuildScene:init()
	self.createPanel = self._tf:Find("create_panel")
	self.factionPanel = self._tf:Find("faction_panel")
	self.createBtn = self._tf:Find("create_panel/frame/create_btn")
	self.joinBtn = self._tf:Find("create_panel/frame/join_btn")
	self.topPanel = self._tf:Find("blur_panel/adapt/top")
	self.publicGuildBtn = self._tf:Find("create_panel/frame/public_btn")
	self.backBtn = self.topPanel:Find("back")

	setActive(self.factionPanel, false)

	self.mask = self._tf:Find("mask")

	SetActive(self.mask, false)

	self.mainRedPage = NewGuildMainRedPage.New(self._tf, self.event)
	self.mainBluePage = NewGuildMainBluePage.New(self._tf, self.event)
end

function NewGuildScene:didEnter()
	self:startCreate()
	onButton(self, self.createBtn, function()
		self:createGuild()
	end, SFX_PANEL)
	onButton(self, self.joinBtn, function()
		self:emit(NewGuildMediator.OPEN_GUILD_LIST)
	end, SFX_PANEL)
	onButton(self, self.createPanel, function()
		self:emit(NewGuildScene.ON_BACK)
	end, SOUND_BACK)
	onButton(self, self.publicGuildBtn, function()
		self:emit(NewGuildMediator.OPEN_PUBLIC_GUILD)
	end, SOUND_BACK)
	onButton(self, self.backBtn, function()
		if go(self.createPanel).activeSelf then
			self:emit(NewGuildScene.ON_BACK)
		end
	end, SFX_CANCEL)
end

function NewGuildScene:startCreate()
	setActive(self.createPanel, true)
end

function NewGuildScene:createGuild()
	setActive(self.createPanel, false)
	setActive(self.factionPanel, false)

	self.createProcess = coroutine.wrap(function()
		setActive(self.createPanel, false)

		local var_14_0 = Guild.New({})

		self:selectFaction(var_14_0, self.createProcess)
		coroutine.yield()
		self:setDescInfo(var_14_0)
	end)

	self.createProcess()
end

function NewGuildScene:selectFaction(arg_15_1, arg_15_2)
	local function var_15_0(arg_16_0, arg_16_1)
		self.isPlaying = true

		local var_16_0 = arg_16_0:Find("bg")

		setActive(var_16_0, true)

		local var_16_1 = var_16_0:GetComponent("CanvasGroup")

		LeanTween.value(go(var_16_0), 1, 3, 0.5):setOnUpdate(System.Action_float(function(arg_17_0)
			var_16_0.localScale = Vector3(arg_17_0, arg_17_0, 1)
			var_16_1.alpha = 1 - arg_17_0 / 3
		end)):setOnComplete(System.Action(function()
			setActive(var_16_0, false)

			var_16_0.localScale = Vector3(1, 1, 1)
			self.isPlaying = false

			arg_16_1()
		end))
	end

	setActive(self.factionPanel, true)

	local var_15_1 = self.factionPanel:Find("panel")
	local var_15_2 = var_15_1:Find("blhx")
	local var_15_3 = var_15_1:Find("cszz")

	if not self.isInitFaction then
		setImageSprite(var_15_1:Find("bg"), GetSpriteFromAtlas("commonbg/camp_bg", ""))
		setImageSprite(var_15_2:Find("bg"), GetSpriteFromAtlas("clutter/blhx_icon", ""))
		setImageSprite(var_15_3:Find("bg"), GetSpriteFromAtlas("clutter/cszz_icon", ""))
		setActive(var_15_2:Find("bg"), false)
		setActive(var_15_3:Find("bg"), false)

		self.isInitFaction = true
	end

	onButton(self, var_15_2, function()
		if self.isPlaying then
			return
		end

		arg_15_1:setFaction(GuildConst.FACTION_TYPE_BLHX)

		if arg_15_2 then
			arg_15_2()
		else
			return
		end

		var_15_0(var_15_2, function()
			arg_15_2 = nil
		end)
	end, SFX_PANEL)
	onButton(self, var_15_3, function()
		if self.isPlaying then
			return
		end

		arg_15_1:setFaction(GuildConst.FACTION_TYPE_CSZZ)

		if arg_15_2 then
			arg_15_2()
		else
			return
		end

		var_15_0(var_15_3, function()
			arg_15_2 = nil
		end)
	end)
	onButton(self, self.backBtn, function()
		if self.isPlaying then
			return
		end

		self.createProcess = nil

		setActive(self.createPanel, true)
		setActive(self.factionPanel, false)
		onButton(self, self.backBtn, function()
			self:emit(NewGuildScene.ON_BACK)
		end, SFX_CANCEL)
	end, SFX_CANCEL)
	setActive(self.topPanel, true)
end

function NewGuildScene:setDescInfo(arg_25_1)
	local var_25_0 = arg_25_1:getFaction()

	if var_25_0 == GuildConst.FACTION_TYPE_BLHX then
		self.mainPage = self.mainBluePage
	elseif var_25_0 == GuildConst.FACTION_TYPE_CSZZ then
		self.mainPage = self.mainRedPage
	end

	local function var_25_1()
		if not self.mainPage:GetLoaded() or self.mainPage:IsPlaying() then
			return
		end

		self.createProcess = nil

		self:createGuild()
		self.mainPage:Hide()
	end

	self.mainPage:ExecuteAction("Show", arg_25_1, self.playerVO, function()
		setActive(self.factionPanel, false)
	end, var_25_1)
	onButton(self, self.backBtn, var_25_1, SFX_CANCEL)
end

function NewGuildScene:ClosePage()
	if self.page and self.page:GetLoaded() and self.page:isShowing() then
		self.page:Hide()
	end
end

function NewGuildScene:onBackPressed()
	if self.createProcess ~= nil then
		triggerButton(self.backBtn)
	else
		triggerButton(self.createPanel)
	end
end

function NewGuildScene:willExit()
	self.mainRedPage:Destroy()
	self.mainBluePage:Destroy()
end

return NewGuildScene
