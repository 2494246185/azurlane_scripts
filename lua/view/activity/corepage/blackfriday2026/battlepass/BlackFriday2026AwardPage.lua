local BlackFriday2026AwardPage = class("BlackFriday2026AwardPage", import("view.activity.CorePage.PSS.Hei5.PSSHei5AwardPage"))

function BlackFriday2026AwardPage:getUIName()
	return "BlackFriday2026AwardPage"
end

function BlackFriday2026AwardPage:Flush(arg_2_1)
	self:Show()

	if arg_2_1 then
		self:UpdateActivity(arg_2_1)
	end

	self.scrollCom:SetTotalCount(#self.awardList)
	self:BuildPhaseAwardScrollPos()

	self.nextAwardIndex = nil

	local var_2_0 = #self.activity:GetHei5UnreceiveAward() > 0

	setGray(self.btnAll, not var_2_0)
	setActive(self.btnAll:Find("Image"), var_2_0)
	setTextColor(self.btnAll:Find("Text"), var_2_0 and Color.NewHex("#ffffff") or Color.NewHex("#7df39f"))
	setButtonEnabled(self.btnAll, var_2_0)
	self:UpdateNextAward(self.scrollCom.value)
end

function BlackFriday2026AwardPage:UpdateAwardInfo(arg_3_1, arg_3_2, arg_3_3)
	if arg_3_3.id < 10 then
		setText(arg_3_2:Find("Text"), "0" .. arg_3_3.id)
	else
		setText(arg_3_2:Find("Text"), arg_3_3.id)
	end

	local var_3_0 = arg_3_3.pt <= self.pt
	local var_3_1 = Drop.Create(arg_3_3.award)

	onButton(self, arg_3_2:Find("base"), function()
		self:emit(BaseUI.ON_NEW_STYLE_DROP, {
			drop = var_3_1
		})
	end, SFX_CONFIRM)
	setActive(arg_3_2:Find("base/lock"), not var_3_0)
	updateDrop(arg_3_2:Find("base/mask/IconTpl"), var_3_1)
	setActive(arg_3_2:Find("base/get"), var_3_0 and not self.awardDic[arg_3_3.pt])
	setActive(arg_3_2:Find("base/got"), self.awardDic[arg_3_3.pt])

	local var_3_2 = Drop.Create(arg_3_3.award_pay)

	onButton(self, arg_3_2:Find("pay"), function()
		self:emit(BaseUI.ON_NEW_STYLE_DROP, {
			drop = var_3_2
		})
	end, SFX_CONFIRM)
	updateDrop(arg_3_2:Find("pay/mask/IconTpl"), var_3_2)
	setActive(arg_3_2:Find("pay/no_pay"), not var_3_0 or not self.isPay)
	setActive(arg_3_2:Find("pay/get"), self.isPay and var_3_0 and not self.awardPayDic[arg_3_3.pt])
	setActive(arg_3_2:Find("pay/got"), self.awardPayDic[arg_3_3.pt])
end

return BlackFriday2026AwardPage
