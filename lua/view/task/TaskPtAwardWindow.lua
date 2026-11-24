local TaskPtAwardWindow = class("TaskPtAwardWindow", import("..activity.Panels.PtAwardWindow"))

function TaskPtAwardWindow:UpdateList(arg_1_1, arg_1_2, arg_1_3)
	assert(#arg_1_1 == #arg_1_2)
	self.UIlist:make(function(arg_2_0, arg_2_1, arg_2_2)
		if arg_2_0 == UIItemList.EventUpdate then
			self:UpdateDrop(arg_2_2:Find("award"), arg_1_1[arg_2_1 + 1][1])
			self:UpdateDrop(arg_2_2:Find("award1"), arg_1_1[arg_2_1 + 1][2])
			setText(arg_2_2:Find("title/Text"), "PHASE " .. arg_2_1 + 1)
			setText(arg_2_2:Find("target/Text"), arg_1_2[arg_2_1 + 1])
			setText(arg_2_2:Find("target/title"), self.resTitle)
			setActive(arg_2_2:Find("award/mask"), arg_2_1 + 1 <= arg_1_3)
			setActive(arg_2_2:Find("award1/mask"), arg_2_1 + 1 <= arg_1_3)

			if arg_2_2:Find("target/icon") then
				if self.resIcon == "" then
					self.resIcon = nil
				end

				if self.resIcon then
					LoadImageSpriteAsync(self.resIcon, arg_2_2:Find("target/icon"), false)
				end

				setActive(arg_2_2:Find("target/icon"), self.resIcon)
				setActive(arg_2_2:Find("target/mark"), self.resIcon)
			end
		end
	end)
	self.UIlist:align(#arg_1_1)
end

function TaskPtAwardWindow:Show(arg_3_1)
	TaskPtAwardWindow.super.Show(self, arg_3_1)
	setActive(self.getBtn, false)
end

function TaskPtAwardWindow:UpdateDrop(arg_4_1, arg_4_2)
	if arg_4_2 then
		setActive(arg_4_1, true)

		local var_4_0 = {
			type = arg_4_2[1],
			id = arg_4_2[2],
			count = arg_4_2[3]
		}

		updateDrop(arg_4_1, var_4_0, {
			hideName = true
		})
		onButton(self.binder, arg_4_1, function()
			self.binder:emit(BaseUI.ON_DROP, var_4_0)
		end, SFX_PANEL)
	else
		setActive(arg_4_1, false)
	end
end

return TaskPtAwardWindow
