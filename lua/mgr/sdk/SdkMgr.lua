pg = pg or {}
pg.SdkMgr = singletonClass("SdkMgr")

local var_0_0 = pg.SdkMgr

function var_0_0:Ctor()
	if PLATFORM_CODE == PLATFORM_CH then
		self.instance = require("Mgr.Sdk.BiliSDKMgr")
	elseif PLATFORM_CODE == PLATFORM_JP then
		self.instance = require("Mgr.Sdk.YoStarMgr")

		self.instance.InitJP()
	elseif PLATFORM_CODE == PLATFORM_KR then
		self.instance = require("Mgr.Sdk.TxwyKrSDKMgr")
	elseif PLATFORM_CODE == PLATFORM_US then
		self.instance = require("Mgr.Sdk.YoStarMgr")

		self.instance.InitUS()
	elseif PLATFORM_CODE == PLATFORM_CHT then
		self.instance = require("Mgr.Sdk.YongshiSdkMgr")
	end

	self.pcode = self:GetPlatformCode(Application.identifier)
end

function var_0_0:Call(arg_2_1, ...)
	assert(self.instance)

	if self.instance[arg_2_1] then
		self.instance[arg_2_1](...)
	end
end

function var_0_0:Get(arg_3_1, ...)
	assert(self.instance)
	assert(self.instance[arg_3_1], "func should exist " .. arg_3_1)

	return self.instance[arg_3_1](...)
end

function EnterMultiWindow(arg_4_0)
	originalPrint(".......EnterMultiWindow")
end

function ExitMultiWindow(arg_5_0)
	originalPrint(".......ExitMultiWindow")
end

function var_0_0:InitSDK()
	self:Call("InitSDK")
end

function var_0_0:GoSDkLoginScene()
	self:Call("GoSDkLoginScene")
end

function var_0_0:LoginSdk(arg_8_1)
	self:Call("LoginSdk", arg_8_1)
end

function var_0_0:TryLoginSdk()
	self:Call("TryLoginSdk")
end

function var_0_0:CreateRole(arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
	self:Call("CreateRole", arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
end

function var_0_0:EnterServer(arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7)
	self:Call("EnterServer", arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7)
end

function var_0_0:ChooseServer(arg_12_1, arg_12_2)
	self:Call("ChooseServer", arg_12_1, arg_12_2)
end

function var_0_0:SdkGateWayLogined()
	self:Call("SdkGateWayLogined")
end

function var_0_0:SdkLoginGetaWayFailed()
	self:Call("SdkLoginGetaWayFailed")
end

function var_0_0:SdkLevelUp()
	self:Call("SdkLevelUp")
end

function var_0_0:SdkPay(arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10)
	self:Call("SdkPay", arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10)
end

function var_0_0:LogoutSDK(arg_17_1)
	self:Call("LogoutSDK", arg_17_1)
end

function var_0_0:BindCPU()
	self:Call("BindCPU")
end

function var_0_0:OnAndoridBackPress()
	self:Call("OnAndoridBackPress")
end

function var_0_0:DeleteAccount()
	self:Call("DeleteAccount")
end

function var_0_0:GetChannelUID()
	local var_21_0 = self:Get("GetChannelUID")

	if var_21_0 == "" then
		var_21_0 = PLATFORM_LOCAL
	end

	return var_21_0
end

function var_0_0.IsTestServer(arg_22_0)
	return NetConst.getwayType == 2
end

function var_0_0:GetChannelUIDIncludeHarmony()
	local function var_23_0()
		local var_24_0 = self:GetChannelUID()

		if var_24_0 == "harmony" then
			return 9999
		else
			local var_24_1 = tonumber(var_24_0)

			if var_24_1 then
				return var_24_1
			else
				return var_24_0 or 0
			end
		end
	end

	if self:IsTestServer() or IsUnityEditor then
		local var_23_1 = IsUnityEditor and PathMgr.getAssetBundle("../localization.txt") or Application.persistentDataPath .. "/localization.txt"

		if not PathMgr.FileExists(var_23_1) then
			return var_23_0()
		end

		local var_23_2 = PathMgr.ReadAllLines(var_23_1)
		local var_23_3

		if var_23_2.Length > 2 then
			var_23_3 = var_23_2[2] or ""

			if not var_23_3 or var_23_3 == "" then
				return var_23_0()
			end
		end

		local var_23_4 = tonumber((var_23_3:match("^%s*ChannelUID%s*=%s*(%d+)")))

		if var_23_4 then
			return var_23_4
		else
			return var_23_0()
		end
	else
		return var_23_0()
	end
end

function var_0_0:GetLoginType()
	if PathMgr.FileExists(Application.persistentDataPath .. "/server_config.txt") then
		return LoginType.PLATFORM_INNER
	end

	if string.match(NetConst.GATEWAY_HOST, "^10%.0") then
		return LoginType.PLATFORM_INNER
	end

	return self:Get("GetLoginType")
end

function var_0_0:GetIsPlatform()
	return self:Get("GetIsPlatform")
end

function var_0_0.EnterLoginScene(arg_27_0)
	arg_27_0.inLoginScene = true
end

function var_0_0.ExitLoginScene(arg_28_0)
	arg_28_0.inLoginScene = false
end

function var_0_0:IsInLoginScene()
	return self.inLoginScene
end

function var_0_0:IsYunPackage()
	return PLATFORM_CODE == PLATFORM_CH and self:GetChannelUID() == "yun"
end

function var_0_0:Service()
	self:Call("Service")
end

function var_0_0:Survey(arg_32_1)
	self:Call("Survey", arg_32_1)
end

function var_0_0:IsHuaweiPackage()
	return PLATFORM_CODE == PLATFORM_CH and self:Get("IsHuaweiPackage")
end

function var_0_0:CheckAudit()
	if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
		return self:Get("CheckAudit")
	else
		return false
	end
end

function var_0_0:CheckPreAudit()
	if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
		return self:Get("CheckPreAudit")
	else
		return false
	end
end

function var_0_0:CheckPretest()
	return self:Get("CheckPretest")
end

function var_0_0:CheckGoogleSimulator()
	return self:Get("CheckGoogleSimulator")
end

function var_0_0:CheckWorldTest()
	if PLATFORM_CODE == PLATFORM_CH then
		return self:Get("CheckWorldTest")
	else
		return false
	end
end

function var_0_0:OnAppPauseForSDK(arg_39_1)
	self:Call("OnAppPauseForSDK", arg_39_1)
end

function var_0_0:UserEventUpload(arg_40_1)
	self:Call("UserEventUpload", arg_40_1)
end

function var_0_0:GameShare(arg_41_1, arg_41_2)
	self:Call("GameShare", arg_41_1, arg_41_2)
end

if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
	(function()
		function var_0_0:YoStarLoginSDK()
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				self:Call("Login")
			end
		end

		function var_0_0:YoStarPay(arg_44_1, arg_44_2, arg_44_3)
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				self:Call("Pay", arg_44_1, arg_44_2, arg_44_3)
			end
		end

		function var_0_0:GameShare(arg_45_1, arg_45_2)
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				self:Call("SystemShare", arg_45_1, arg_45_2)
			end
		end

		function var_0_0:YostarOpenAiHelp()
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				self:Call("ShowAihelp")
			end
		end

		function var_0_0:OnAppPauseForSDK(arg_47_1)
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				self:Call("OnAppPauseForSDK", arg_47_1)
			end
		end

		function var_0_0:YoStarShowSurvey(arg_48_1, arg_48_2)
			if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
				return self:Call("ShowSurvey", arg_48_1, arg_48_2)
			end
		end

		function var_0_0:YoStarCheckCanBuy()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("CheckYoStarCanBuy")
			end
		end

		function var_0_0:YoStarCheckHadAccountCache()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("CheckHadAccountCache")
			end
		end

		function var_0_0:YoStarShowUserCenter()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("ShowUserCenter")
			end
		end

		function var_0_0:YoStarRoleInfoUpload()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("RoleInfoUpload")
			end
		end

		function var_0_0:YoStarShowSwitchAccount()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("ShowSwitchAccount")
			end
		end

		function var_0_0:YoStarShowAccountCenter()
			if PLATFORM_CODE == PLATFORM_US or PLATFORM_CODE == PLATFORM_JP then
				return self:Get("ShowAccountCenter")
			end
		end

		function var_0_0:UserEventUpload(arg_55_1)
			self:Call("UserEventUpload", arg_55_1)
		end
	end)()
end

function var_0_0:UserCenter()
	self:Call("UserCenter")
end

function var_0_0:BugReport()
	self:Call("BugReport")
end

function var_0_0:StoreReview()
	self:Call("StoreReview")
end

function var_0_0:QueryWithProduct()
	self:Call("QueryWithProduct")
end

function var_0_0:QueryPendingTransaction()
	self:Call("QueryPendingTransaction")
end

function var_0_0:ShareImg(arg_61_1, arg_61_2)
	self:Call("ShareImg", arg_61_1, arg_61_2)
end

function var_0_0:SwitchAccount()
	self:Call("SwitchAccount")
end

function var_0_0:EventTrack(arg_63_1)
	self:Call("EventTrack", arg_63_1)
end

function var_0_0:EventTrack(arg_64_1)
	self:Call("EventTrack", arg_64_1)
end

function var_0_0:IsBindFaceBook()
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("IsBindFaceBook")
	end
end

function var_0_0:IsBindApple()
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("IsBindApple")
	end
end

function var_0_0:IsBindGoogle()
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("IsBindGoogle")
	end
end

function var_0_0:IsBindPhone()
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("IsBindPhone")
	end
end

function var_0_0.IsBindGameCenter(arg_69_0)
	if PLATFORM_CODE == PLATFORM_CHT then
		return false
	end
end

function var_0_0:CanTriggerDeepLinking()
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("CanTriggerDeepLinking")
	else
		return false
	end
end

function var_0_0:TriggerDeepLinking()
	self:Call("TriggerDeepLinking")
end

function var_0_0:BindSocial(arg_72_1)
	if arg_72_1 == 1 then
		self:BindFaceBook()
	elseif arg_72_1 == 2 then
		self:BindGoogle()
	elseif arg_72_1 == 3 then
		self:BindPhone()
	elseif arg_72_1 == 4 then
		-- block empty
	elseif arg_72_1 == 5 then
		self:BindApple()
	end
end

function var_0_0:UnbindSocial(arg_73_1)
	if arg_73_1 == 1 then
		self:UnBindFaceBook()
	elseif arg_73_1 == 2 then
		self:UnBindGoogle()
	elseif arg_73_1 == 3 then
		self:UnBindPhone()
	elseif arg_73_1 == 4 then
		-- block empty
	end
end

function var_0_0:BindFaceBook()
	self:Call("BindFaceBook")
end

function var_0_0:BindApple()
	self:Call("BindApple")
end

function var_0_0:BindGoogle()
	self:Call("BindGoogle")
end

function var_0_0:BindPhone()
	self:Call("BindPhone")
end

function var_0_0:UnBindFaceBook()
	self:Call("UnBindFaceBook")
end

function var_0_0:UnBindGoogle()
	self:Call("UnBindGoogle")
end

function var_0_0:UnBindPhone()
	self:Call("UnBindPhone")
end

function var_0_0:ShowLicence()
	self:Call("ShowLicence")
end

function var_0_0:ShowPrivate()
	self:Call("ShowPrivate")
end

function var_0_0:OpenMiniProgram()
	self:Call("OpenMiniProgram")
end

function var_0_0:GetProduct(arg_84_1)
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("GetProduct", arg_84_1)
	end
end

function var_0_0:GetDeviceId()
	if PLATFORM_CODE == PLATFORM_JP or PLATFORM_CODE == PLATFORM_US then
		return self:Get("GetDeviceId")
	elseif PLATFORM_CODE == PLATFORM_KR then
		return self:Get("GetDeviceModel")
	elseif PLATFORM_CODE == PLATFORM_CHT then
		return SystemInfo.deviceUniqueIdentifier
	else
		return ""
	end
end

function InLoginScene()
	if pg.SdkMgr.GetInstance():IsInLoginScene() and not (function()
		return getProxy(UserProxy):GetLoginedFlag()
	end)() then
		return true
	end

	return false
end

function var_0_0:GetPlatformCode(arg_88_1)
	if PLATFORM_CODE == PLATFORM_CHT then
		return self:Get("GetPackageCode", arg_88_1)
	else
		return nil
	end
end

function var_0_0:IgnorePlatform(arg_89_1)
	local var_89_0 = self.pcode

	if self.pcode and arg_89_1 and #arg_89_1 > 0 and _.any(arg_89_1, function(arg_90_0)
		return tostring(arg_90_0) == var_89_0
	end) then
		return true
	end

	return false
end
