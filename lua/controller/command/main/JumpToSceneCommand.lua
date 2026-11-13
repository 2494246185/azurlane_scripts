local JumpToSceneCommand = class("JumpToSceneCommand", pm.SimpleCommand)

function JumpToSceneCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()
	local var_1_1 = SCENE[var_1_0.sceneData[1]]
	local var_1_2 = var_1_0.sceneData[2]

	if var_1_0.activityID and var_1_0.activityID ~= 0 then
		local var_1_3 = getProxy(ActivityProxy):getActivityById(var_1_0.activityID)

		if not var_1_3 or var_1_3:isEnd() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("challenge_end_tip"))

			return
		end
	end

	switch(SCENE[var_1_0.sceneData[1]], {
		[SCENE.SHOP] = function()
			self:JumpToShop(var_1_1, var_1_2)
		end,
		[SCENE.LEVEL] = function()
			self:JumpToLevel(var_1_1, var_1_2)
		end,
		[SCENE.COLLECTSHIP] = function()
			self:JumpToCollectShip(var_1_1, var_1_2)
		end
	}, function()
		self:sendNotification(GAME.GO_SCENE, var_1_1, var_1_2)
	end)
end

function JumpToSceneCommand:JumpToShop(arg_6_1, arg_6_2)
	if arg_6_2.warp == NewShopsScene.TYPE_MILITARY_SHOP then
		if not pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getData().level, "MilitaryExerciseMediator") then
			pg.TipsMgr.GetInstance():ShowTips(i18n("military_shop_no_open_tip"))

			return
		end
	end

	self:sendNotification(GAME.GO_SCENE, arg_6_1, arg_6_2)
end

function JumpToSceneCommand:JumpToLevel(arg_7_1, arg_7_2)
	local var_7_0 = getProxy(ChapterProxy)
	local var_7_1 = var_7_0:getChapterById(arg_7_2.chapterid)

	if var_7_1:isUnlock() then
		local var_7_2 = var_7_0:getActiveChapter()

		if var_7_2 and var_7_2.id ~= arg_7_2.chapterid then
			self:ShowMsgBox({
				content = i18n("collect_chapter_is_activation"),
				onYes = function()
					self:sendNotification(GAME.CHAPTER_OP, {
						type = ChapterConst.OpRetreat
					})
				end
			})

			return
		else
			local var_7_3 = {
				mapIdx = var_7_1:getConfig("map")
			}

			if var_7_1.active then
				var_7_3.chapterId = var_7_1.id
			else
				var_7_3.openChapterId = arg_7_2.chapterid
			end

			self:sendNotification(GAME.GO_SCENE, SCENE.LEVEL, var_7_3)
		end
	else
		pg.TipsMgr.GetInstance():ShowTips(i18n("acquisitionmode_is_not_open"))

		return
	end
end

function JumpToSceneCommand:JumpToCollectShip(arg_9_1, arg_9_2)
	self:sendNotification(GAME.GO_SCENE, SCENE.COLLECTSHIP, {
		toggle = 2,
		displayGroupId = arg_9_2.shipGroupId
	})
end

return JumpToSceneCommand
