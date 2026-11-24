local MainActRemasterActivaingBtn = class("MainActRemasterActivaingBtn", import(".MainActRemasterBtn"))

function MainActRemasterActivaingBtn:GetLinkConfig()
	local var_1_0 = pg.activity_re[getProxy(ActivityRemasterProxy).activeActID]
	local var_1_1 = "event_actremaster"
	local var_1_2 = "text_event_all"

	if var_1_0 then
		var_1_1 = var_1_0.link_button_pic
		var_1_2 = var_1_0.link_button_text
	end

	return {
		param = "0",
		name = "event_actremaster",
		type = 3,
		id = 1,
		group_id = 1,
		order = 1,
		pic = var_1_1,
		text_pic = var_1_2,
		time = {
			"default",
			51033
		}
	}
end

function MainActRemasterActivaingBtn:InShowTime()
	self.config = self:GetLinkConfig()

	return getProxy(ActivityRemasterProxy):IsShowTime()
end

function MainActRemasterActivaingBtn:Register()
	onButton(self, self._tf, function()
		local var_4_0 = getProxy(ActivityRemasterProxy):GetActivaingReamsterData()

		if not var_4_0 then
			self:emit(NewMainMediator.SKIP_ACTIVITY)
		else
			self:emit(NewMainMediator.SKIP_ACTIVITY, (var_4_0:GetFirstOpenActId()))
		end
	end, SFX_MAIN)
end

function MainActRemasterActivaingBtn:OnInit()
	local var_5_0 = getProxy(ActivityRemasterProxy).activeActID

	if not var_5_0 then
		setActive(self.tipTr.gameObject, false)

		return
	end

	local var_5_1 = pg.activity_re[var_5_0]
	local var_5_2

	if not pg.activity_re[var_5_0] then
		setActive(self.tipTr.gameObject, false)

		do return end

		var_5_2 = ""
	end

	for iter_5_0, iter_5_1 in ipairs((_.map(var_5_1.act_time, function(arg_6_0)
		return arg_6_0[1]
	end))) do
		if pg.activity_template[iter_5_1] and pg.activity_template[iter_5_1].page_core and pg.activity_template[iter_5_1].page_core ~= "" then
			var_5_2 = pg.activity_template[iter_5_1].page_core

			break
		end
	end

	if var_5_2 == "" then
		setActive(self.tipTr.gameObject, false)

		return
	end

	setActive(self.tipTr.gameObject, _.any(getProxy(ActivityProxy):getCorePanelActivities(var_5_2), function(arg_7_0)
		return arg_7_0:readyToAchieve()
	end))
end

return MainActRemasterActivaingBtn
