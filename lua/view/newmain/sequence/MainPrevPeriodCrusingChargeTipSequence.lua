local MainPrevPeriodCrusingChargeTipSequence = class("MainPrevPeriodCrusingChargeTipSequence")

MainPrevPeriodCrusingChargeTipSequence.TIP = true

function MainPrevPeriodCrusingChargeTipSequence:Execute(arg_1_1)
	if not PrevPeriodCrusingActivity.StaticExistPrevPeriodCrusingActivity() then
		arg_1_1()

		return
	end

	if not MainPrevPeriodCrusingChargeTipSequence.TIP then
		arg_1_1()

		return
	end

	self.callback = arg_1_1

	self:ShowMsgBox()
end

function MainPrevPeriodCrusingChargeTipSequence:ShowMsgBox()
	self.mediator = MainPrevPeriodCrusingChargeTipMeidator.New(self)

	local var_2_0 = PrevPeriodCrusingChargeTipPage.New(pg.UIMgr.GetInstance().OverlayMain)

	var_2_0:ExecuteAction("Show", function()
		self:OnClose()
	end)

	self.chargeTipPage = var_2_0
	MainPrevPeriodCrusingChargeTipSequence.TIP = false
end

function MainPrevPeriodCrusingChargeTipSequence:OnClose()
	if self.callback then
		self.callback()
	end

	self.callback = nil

	if self.mediator then
		self.mediator:Dispose()

		self.mediator = nil
	end
end

function MainPrevPeriodCrusingChargeTipSequence:OnChargeSuccess(arg_5_1)
	local var_5_0 = Goods.Create({
		shop_id = arg_5_1.shopId
	}, Goods.TYPE_CHARGE)

	if not var_5_0:isPassItem() then
		return
	end

	seriesAsync({
		function(arg_6_0)
			self.chargeTipPage:OnChargeScene(var_5_0, arg_6_0)
		end,
		function(arg_7_0)
			MainFetchPrevPeriodCrusingSequence.New():Execute(arg_7_0)
		end
	}, function()
		if self.chargeTipPage and self.chargeTipPage:GetLoaded() then
			self.chargeTipPage:Destroy()

			self.chargeTipPage = nil
		end
	end)
end

function MainPrevPeriodCrusingChargeTipSequence:GetCurrentCrusingAct()
	local var_9_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_9_0 and not var_9_0:isEnd() then
		return var_9_0
	end

	return nil
end

return MainPrevPeriodCrusingChargeTipSequence
