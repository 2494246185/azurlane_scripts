local MainBannerView = class("MainBannerView", import("...base.MainBaseView"))

function MainBannerView:Ctor(arg_1_1, arg_1_2)
	MainBannerView.super.Ctor(self, arg_1_1, arg_1_2)

	self.scrollSnap = BannerScrollRect.New(findTF(arg_1_1, "mask/content"), findTF(arg_1_1, "dots"))
	self.downloadmgr = BulletinBoardMgr.Inst
	self.rawImages = {}
	self.prefabCaches = {}
	self.imageTrs = {}
end

function MainBannerView:Init()
	local var_2_0 = getProxy(ActivityProxy):getBannerDisplays()

	self:UpdateItems(var_2_0)

	self.banners = var_2_0
end

function MainBannerView:Refresh()
	if #self.banners ~= #getProxy(ActivityProxy):getBannerDisplays() then
		self:Clear()
		self:Init()
	else
		self.scrollSnap:Resume()
	end
end

function MainBannerView:UpdateItems(arg_4_1)
	for iter_4_0 = 0, #arg_4_1 - 1 do
		local var_4_0 = arg_4_1[iter_4_0 + 1]
		local var_4_1 = self.scrollSnap:AddChild()

		self:UpdateItemImage(arg_4_1[iter_4_0 + 1], var_4_1)
		setActive(findTF(var_4_1, "red"), var_4_0.type == 3 and tonumber(var_4_0.param) == nil and getProxy(ActivityProxy):readyToAchieveByType(ActivityConst.ACTIVITY_TYPE_LEVELAWARD))
		onButton(self, var_4_1, function()
			self:Tracking(var_4_0.id)
			MainBaseActivityBtn.Skip(self, var_4_0)
		end, SFX_MAIN)
	end

	self.scrollSnap:SetUp()
end

function MainBannerView:GetItemPicPath(arg_6_1)
	if PLATFORM_CODE == PLATFORM_CH and HXSet.isHx() then
		local var_6_0 = pg.SdkMgr.GetInstance():GetChannelUIDIncludeHarmony()
		local var_6_1 = arg_6_1.pic_hx or {}

		if #var_6_1 <= 0 then
			return arg_6_1.pic
		end

		local var_6_2 = _.detect(var_6_1, function(arg_7_0)
			return arg_7_0[1] == var_6_0
		end)

		if not var_6_2 then
			return arg_6_1.pic
		end

		do return var_6_2[2] or arg_6_1.pic end
		return
	end

	return arg_6_1.pic
end

function MainBannerView:UpdateItemImage(arg_8_1, arg_8_2)
	local var_8_0 = arg_8_2:Find("texture")
	local var_8_1 = arg_8_2:Find("image")
	local var_8_2 = self:GetItemPicPath(arg_8_1)
	local var_8_3 = StringStartsWith(var_8_2, "https://") or StringStartsWith(var_8_2, "http://")

	setActive(var_8_0, var_8_3)
	setActive(var_8_1, not var_8_3)

	if var_8_3 then
		self.downloadmgr:GetTexture("main_banner", "1", var_8_2, UnityEngine.Events.UnityAction_UnityEngine_Texture(function(arg_9_0)
			if self.exited or IsNil(var_8_0) then
				return
			end

			local var_9_0 = var_8_0:GetComponent(typeof(RawImage))

			var_9_0.texture = arg_9_0

			table.insert(self.rawImages, var_9_0)
		end))
	else
		self:ReturnItemPrefabCache(var_8_1)
		pg.PoolMgr.GetInstance():GetPrefab("MainUIBanner/" .. var_8_2, "", true, function(arg_10_0)
			setParent(arg_10_0.transform, var_8_1)
			onNextTick(function()
				self:LayoutBannerItem(arg_10_0)
			end)

			local var_10_0 = arg_10_0.transform:Find("Text")

			setText(var_10_0, self:GetBannerShowTimeStr(arg_8_1, (self:IsImpactFont(var_10_0))))

			self.prefabCaches[arg_10_0] = var_8_2
		end)
	end

	self.imageTrs[var_8_1] = true
end

function MainBannerView:IsImpactFont(arg_12_1)
	return arg_12_1:GetComponent(typeof(Text)).font.name == pg.FontMgr.FONT_NAME_IMPACT
end

function MainBannerView:LayoutBannerItem(arg_13_1)
	arg_13_1.transform.localScale = Vector3(1, 1, 1)
	arg_13_1.transform.anchorMin = Vector2.zero
	arg_13_1.transform.anchorMax = Vector2.one
	arg_13_1.transform.offsetMin = Vector2.zero
	arg_13_1.transform.offsetMax = Vector2.zero
end

function MainBannerView:WhenRecycleBanner(arg_14_1)
	return
end

function MainBannerView:ReturnItemPrefabCache(arg_15_1)
	if IsNil(arg_15_1) then
		return
	end

	eachChild(arg_15_1, function(arg_16_0)
		if self.prefabCaches[arg_16_0.gameObject] then
			self:WhenRecycleBanner(arg_16_0.gameObject)
			pg.PoolMgr.GetInstance():ReturnPrefab("MainUIBanner/" .. self.prefabCaches[arg_16_0.gameObject], "", arg_16_0.gameObject)

			self.prefabCaches[arg_16_0.gameObject] = nil
		else
			Destroy(arg_16_0.gameObject)
		end
	end)
end

local function var_0_1(arg_17_0)
	if arg_17_0.time == "stop" then
		return true
	end

	if arg_17_0.param[1] == "scene get boat" and arg_17_0.param[2].projectName == "new" then
		return true
	end

	if arg_17_0.param[1] == "scene charge" and arg_17_0.param[2].wrap == 2 then
		return true
	end

	if arg_17_0.param[1] == "scene shop" and arg_17_0.param[2].wrap == "shopstreet" then
		return true
	end

	return false
end

function MainBannerView:GetBannerShowTimeStr(arg_18_1, arg_18_2)
	local var_18_0 = ""

	if var_0_1(arg_18_1) then
		local var_18_1 = getProxy(ActivityRemasterProxy):GetActivaingReamsterData()

		if var_18_1 then
			var_18_0 = var_18_1:GetActivityTimeDescByBanner(arg_18_1.id, arg_18_2)
		end
	end

	return var_18_0
end

function MainBannerView:Tracking(arg_19_1)
	pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildTouchBanner(arg_19_1))
end

function MainBannerView:GetDirection()
	return Vector2(1, 0)
end

function MainBannerView:Disable()
	self.scrollSnap:Pause()
end

function MainBannerView:Clear()
	self.scrollSnap:Reset()
end

function MainBannerView:Dispose()
	MainBannerView.super.Dispose(self)

	for iter_23_0, iter_23_1 in ipairs(self.rawImages) do
		iter_23_1.texture = nil
	end

	self.rawImages = nil

	for iter_23_2, iter_23_3 in pairs(self.imageTrs) do
		self:ReturnItemPrefabCache(iter_23_2)
	end

	self.imageTrs = nil

	self:Clear()
	self.scrollSnap:Dispose()

	self.scrollSnap = nil
	self.exited = true
	self.downloadmgr = nil
end

return MainBannerView
