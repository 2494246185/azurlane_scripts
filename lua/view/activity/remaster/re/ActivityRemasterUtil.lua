local ActivityRemasterUtil = class("ActivityRemasterUtil")

function ActivityRemasterUtil:AdapterCoreScene(arg_1_1, arg_1_2, arg_1_3)
	if isa(self, BaseActivityPage) then
		local var_1_0 = CoreActivityPage.New(arg_1_1, arg_1_2, arg_1_3)

		setmetatable(self, {
			__index = function(arg_2_0, arg_2_1)
				local var_2_0 = rawget(arg_2_0, "class")

				return (var_2_0[arg_2_1] or nil) and (var_2_0[arg_2_1] or var_1_0[arg_2_1])
			end
		})
	end
end

function ActivityRemasterUtil:UpdateTime()
	local var_3_0, var_3_1 = getProxy(ActivityRemasterProxy):InActTime()

	if var_3_1 > 0 then
		local var_3_4 = string.format("%s.%s-%s.%s", pg.activity_re_timer[var_3_1].timer[2][1][2], pg.activity_re_timer[var_3_1].timer[2][1][3], pg.activity_re_timer[var_3_1].timer[3][1][2], pg.activity_re_timer[var_3_1].timer[3][1][3])

		setText(self.time.transform:Find("Text"), var_3_4)
		setText(self.time.transform:Find("label"), i18n("act_remaster_tip_2", ""))

		local var_3_5 = self.time.transform:Find("Text_1")

		if not IsNil(var_3_5) then
			setText(var_3_5, var_3_4)
		end
	end

	local var_3_6 = self.time.transform:Find("label_1")

	if not IsNil(var_3_6) then
		setText(var_3_6, i18n("act_remaster_tip_2", ""))
	end

	local var_3_7 = self.time.transform:Find("extend_time")

	if not IsNil(var_3_7) and self.activity then
		local var_3_8 = pg.TimeMgr.GetInstance():STimeDescS(self.activity.stopTime, "*t")

		setText(var_3_7, i18n("act_remaster_extend_time", var_3_8.hour == 0 and string.format("%04d.%02d.%02d %02d:%02d:%02d", var_3_8.year, var_3_8.month, var_3_8.day - 1, 23, 59, 59) or string.format("%04d.%02d.%02d %02d:%02d:%02d", var_3_8.year, var_3_8.month, var_3_8.day, var_3_8.hour, var_3_8.min, var_3_8.sec)))
	end
end

return ActivityRemasterUtil
