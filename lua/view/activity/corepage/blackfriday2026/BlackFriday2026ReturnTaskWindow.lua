local BlackFriday2026ReturnTaskWindow = class("BlackFriday2026ReturnTaskWindow", import("view.activity.CorePage.OutPost.OutPostOmenTaskWindow"))

function BlackFriday2026ReturnTaskWindow:getUIName()
	return "BlackFriday2026ReturnTaskWindow"
end

function BlackFriday2026ReturnTaskWindow:UpdateListItem(arg_2_1, arg_2_2)
	local var_2_0 = findTF(arg_2_2, "default")
	local var_2_1 = findTF(arg_2_2, "lock")
	local var_2_2 = findTF(var_2_1, "desc")
	local var_2_3 = arg_2_1 + 1

	LoadImageSpriteAtlasAsync("ui/blackfriday2026returnpage_atlas", "day_" .. arg_2_1 + 1, findTF(var_2_0, "day/dayimage"), true)
	self:UpdateTaskItem(arg_2_1 + 1, (findTF(findTF(var_2_0, "tasks"), "item_1")))

	local var_2_4 = self:isTaskLock(arg_2_1 + 1)
	local var_2_5 = var_2_4 ~= 0

	setActive(var_2_1, var_2_4 ~= 0)

	GetOrAddComponent(var_2_0, typeof(CanvasGroup)).alpha = var_2_5 and 0.5 or 1

	switch(var_2_4, {
		function()
			local var_3_0, var_3_1 = self:getDate(self.month, self.day + var_2_3 - self.nday)

			setText(var_2_2, i18n("OutPostOmenPage_task_tip1", var_3_0, var_3_1))
		end,
		function()
			setText(var_2_2, i18n("OutPostOmenPage_task_tip2"))
		end
	})
end

function BlackFriday2026ReturnTaskWindow:UpdateTaskItem(arg_5_1, arg_5_2)
	local var_5_0 = arg_5_2:Find("item")
	local var_5_1 = self.taskProxy:getTaskById(self.taskGroup[arg_5_1][1]) or self.taskProxy:getFinishTaskById(self.taskGroup[arg_5_1][1])
	local var_5_2 = pg.task_data_template[self.taskGroup[arg_5_1][1]]
	local var_5_3 = Drop.Create(pg.task_data_template[self.taskGroup[arg_5_1][1]].award_display[1])

	updateDrop(var_5_0, var_5_3)
	onButton(self, var_5_0, function()
		self:emit(BaseUI.ON_DROP, var_5_3)
	end, SFX_PANEL)

	local var_5_4 = var_5_1 and var_5_1:getProgress() or 0
	local var_5_5 = var_5_2.target_num

	setText(arg_5_2:Find("mask/description"), var_5_2.desc)
	setSlider(arg_5_2:Find("progress"), 0, var_5_5, var_5_4)
	setText(arg_5_2:Find("progressText"), var_5_4 .. "/" .. var_5_5)
	setActive(arg_5_2:Find("got"), var_5_1 and var_5_1:getTaskStatus() == 2 or false)
end

return BlackFriday2026ReturnTaskWindow
