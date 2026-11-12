local Dorm3dRoomMediator = class("Dorm3dRoomMediator", import("view.dorm3d.Core.Dorm3dBaseMediator"))

Dorm3dRoomMediator.TRIGGER_FAVOR = "Dorm3dRoomMediator.TRIGGER_FAVOR"
Dorm3dRoomMediator.FAVOR_LEVEL_UP = "Dorm3dRoomMediator.FAVOR_LEVEL_UP"
Dorm3dRoomMediator.TALKING_EVENT_FINISH = "Dorm3dRoomMediator.TALKING_EVENT_FINISH"
Dorm3dRoomMediator.DO_TALK = "Dorm3dRoomMediator.DO_TALK"
Dorm3dRoomMediator.COLLECTION_ITEM = "Dorm3dRoomMediator.COLLECTION_ITEM"
Dorm3dRoomMediator.OPEN_FURNITURE_SELECT = "Dorm3dRoomMediator.OPEN_FURNITURE_SELECT"
Dorm3dRoomMediator.OPEN_LEVEL_LAYER = "Dorm3dRoomMediator.OPEN_LEVEL_LAYER"
Dorm3dRoomMediator.OPEN_GIFT_LAYER = "Dorm3dRoomMediator.OPEN_GIFT_LAYER"
Dorm3dRoomMediator.OPEN_CAMERA_LAYER = "Dorm3dRoomMediator.OPEN_CAMERA_LAYER"
Dorm3dRoomMediator.OPEN_DROP_LAYER = "Dorm3dRoomMediator.OPEN_DROP_LAYER"
Dorm3dRoomMediator.OPEN_COLLECTION_LAYER = "Dorm3dRoomMediator.OPEN_COLLECTION_LAYER"
Dorm3dRoomMediator.OPEN_INVITE_WINDOW = "Dorm3dRoomMediator.OPEN_INVITE_WINDOW"
Dorm3dRoomMediator.OPEN_ACCOMPANY_WINDOW = "Dorm3dRoomMediator.OPEN_ACCOMPANY_WINDOW"
Dorm3dRoomMediator.OPEN_MINIGAME_WINDOW = "Dorm3dRoomMediator.OPEN_MINIGAME_WINDOW"
Dorm3dRoomMediator.OPEN_SKIN_SELECT_LAYER = "Dorm3dRoomMediator.OPEN_SKIN_SELECT_LAYER"
Dorm3dRoomMediator.OPEN_SETTING_LAYER = "Dorm3dRoomMediator.OPEN_SETTING_LAYER"
Dorm3dRoomMediator.ON_LEVEL_UP_FINISH = "Dorm3dRoomMediator.ON_LEVEL_UP_FINISH"
Dorm3dRoomMediator.ON_CLICK_FURNITURE_SLOT = "Dorm3dRoomMediator.ON_CLICK_FURNITURE_SLOT"
Dorm3dRoomMediator.OTHER_DO_TALK = "Dorm3dRoomMediator.OTHER_DO_TALK"
Dorm3dRoomMediator.OTHER_POP_UNLOCK = "Dorm3dRoomMediator.OTHER_POP_UNLOCK"
Dorm3dRoomMediator.CHAMGE_TIME_RELOAD_SCENE = "Dorm3dRoomMediator.CHAMGE_TIME_RELOAD_SCENE"
Dorm3dRoomMediator.GUIDE_CLICK_LADY = "Dorm3dRoomMediator.GUIDE_CLICK_LADY"
Dorm3dRoomMediator.GUIDE_CHECK_GUIDE = "Dorm3dRoomMediator.GUIDE_CHECK_GUIDE"
Dorm3dRoomMediator.GUIDE_CHECK_LEVEL_UP = "Dorm3dRoomMediator.GUIDE_CHECK_LEVEL_UP"
Dorm3dRoomMediator.Camera_Pinch_Value_Change = "Dorm3dRoomMediator.Camera_Pinch_Value_Change"
Dorm3dRoomMediator.ENTER_VOLLEYBALL = "Dorm3dRoomMediator.ENTER_VOLLEYBALL"
Dorm3dRoomMediator.ENTER_DANCE = "Dorm3dRoomMediator.ENTER_DANCE"
Dorm3dRoomMediator.ENTER_CARWASH = "Dorm3dRoomMediator.ENTER_CARWASH"
Dorm3dRoomMediator.ON_DROP_CLIENT = "Dorm3dRoomMediator.ON_DROP_CLIENT"
Dorm3dRoomMediator.UPDATE_FAVOR_DISPLAY = "Dorm3dRoomMediator.UPDATE_FAVOR_DISPLAY"
Dorm3dRoomMediator.ADD_EXTRA_SYSTEM_FURNITURE_SLIDE = "Dorm3dRoomMediator.ADD_EXTRA_SYSTEM_FURNITURE_SLIDE"
Dorm3dRoomMediator.REMOVE_EXTRA_SYSTEM = "Dorm3dRoomMediator.REMOVE_EXTRA_SYSTEM"

function Dorm3dRoomMediator:register()
	self:bind(Dorm3dRoomMediator.TRIGGER_FAVOR, function(arg_2_0, arg_2_1, arg_2_2)
		self:sendNotification(GAME.APARTMENT_TRIGGER_FAVOR, {
			groupId = arg_2_1,
			triggerId = arg_2_2
		})
	end)
	self:bind(Dorm3dRoomMediator.FAVOR_LEVEL_UP, function(arg_3_0, arg_3_1)
		self:sendNotification(GAME.APARTMENT_LEVEL_UP, {
			groupId = arg_3_1
		})
	end)
	self:bind(Dorm3dRoomMediator.TALKING_EVENT_FINISH, function(arg_4_0, arg_4_1, arg_4_2)
		self:sendNotification(arg_4_1, arg_4_2)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_FURNITURE_SELECT, function(arg_5_0, arg_5_1, arg_5_2)
		self:addSubLayers(Context.New({
			mediator = Dorm3dFurnitureSelectMediator,
			viewComponent = Dorm3dFurnitureSelectLayer,
			data = arg_5_1,
			onRemoved = function()
				self.viewComponent:InitExtraSystem({
					SlideExtraSystem
				})
				self.viewComponent:TempHideUI(false, arg_5_2)

				self.viewComponent.isInFurnitureSelect = false
			end
		}), nil, function()
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.ON_CLICK_FURNITURE_SLOT, function(arg_8_0, arg_8_1)
		self:sendNotification(arg_8_0, arg_8_1)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_LEVEL_LAYER, function(arg_9_0, arg_9_1, arg_9_2)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dLevelLayer,
			mediator = Dorm3dLevelMediator,
			data = arg_9_1,
			onRemoved = function()
				self.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				self.viewComponent:TempHideUI(false, arg_9_2)
			end
		}), nil, function()
			self.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_GIFT_LAYER, function(arg_12_0, arg_12_1, arg_12_2)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dGiftLayer,
			mediator = Dorm3dGiftMediator,
			data = arg_12_1,
			onRemoved = function()
				self.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				self.viewComponent:TempHideUI(false, arg_12_2)
			end
		}), nil, function()
			self.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_CAMERA_LAYER, function(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dPhotoLayer,
			mediator = Dorm3dPhotoMediator,
			data = {
				groupId = arg_15_2,
				view = arg_15_1
			}
		}))
	end)
	self:bind(Dorm3dRoomMediator.OPEN_DROP_LAYER, function(arg_16_0, arg_16_1, arg_16_2)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dAwardInfoLayer,
			mediator = Dorm3dAwardInfoMediator,
			data = {
				items = arg_16_1
			},
			onRemoved = arg_16_2
		}))
	end)
	self:bind(Dorm3dRoomMediator.OPEN_COLLECTION_LAYER, function(arg_17_0, arg_17_1)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dCollectionLayer,
			mediator = Dorm3dCollectionMediator,
			data = {
				roomId = arg_17_1
			}
		}))
	end)
	self:bind(Dorm3dRoomMediator.OPEN_INVITE_WINDOW, function(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dInviteLayer,
			mediator = Dorm3dInviteMediator,
			data = {
				roomId = arg_18_1,
				groupIds = arg_18_2
			},
			onRemoved = function()
				self.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				self.viewComponent:TempHideUI(false, arg_18_3)
			end
		}), nil, function()
			self.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_SKIN_SELECT_LAYER, function(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dSkinSelectLayer,
			mediator = Dorm3dSkinSelectMediator,
			data = {
				groupId = arg_21_1,
				ladyEnv = arg_21_2,
				onSwitchSkin = arg_21_3
			},
			onRemoved = arg_21_5 and arg_21_4 or function()
				self.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				self.viewComponent:TempHideUI(false, arg_21_4)
			end
		}), nil, not arg_21_5 and function()
			self.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_ACCOMPANY_WINDOW, function(arg_24_0, arg_24_1, arg_24_2)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dAccompanyLayer,
			mediator = Dorm3dAccompanyMediator,
			data = arg_24_1,
			onRemoved = function()
				self.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				self.viewComponent:TempHideUI(false, arg_24_2)
			end
		}), nil, function()
			self.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
			self.viewComponent:TempHideUI(true)
		end)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_MINIGAME_WINDOW, function(arg_27_0, arg_27_1, arg_27_2)
		self:addSubLayers(Context.New({
			viewComponent = switch(arg_27_1.minigameId, {
				[67] = function()
					return EatFoodLayer
				end,
				[70] = function()
					return NengDaiScheduleGameView
				end,
				[75] = function()
					return RPSGameLayer
				end
			}, function()
				assert(false, "without dorm minigame config in id:" .. arg_27_1.minigameId)
			end),
			mediator = Dorm3dMiniGameMediator,
			data = arg_27_1,
			onRemoved = arg_27_2
		}))
	end)
	self:bind(Dorm3dRoomMediator.ADD_EXTRA_SYSTEM_FURNITURE_SLIDE, function(arg_32_0, arg_32_1)
		self:addSubLayers(Context.New({
			viewComponent = FurnitureSlideExtraLayer,
			mediator = FurnitureSlideExtraMediator,
			data = arg_32_1
		}))
	end)
	self:bind(Dorm3dRoomMediator.REMOVE_EXTRA_SYSTEM, function(arg_33_0, arg_33_1)
		self:removeSubLayers(arg_33_1)
	end)
	self:bind(Dorm3dRoomMediator.DO_TALK, function(arg_34_0, arg_34_1, arg_34_2)
		self:sendNotification(GAME.APARTMENT_DO_TALK, {
			talkId = arg_34_1,
			callback = arg_34_2
		})
	end)
	self:bind(Dorm3dRoomMediator.COLLECTION_ITEM, function(arg_35_0, arg_35_1)
		self:sendNotification(GAME.APARTMENT_COLLECTION_ITEM, arg_35_1)
	end)
	self:bind(Dorm3dRoomMediator.Camera_Pinch_Value_Change, function(arg_36_0, arg_36_1)
		self:sendNotification(Dorm3dPhotoMediator.Camera_Pinch_Value_Change, {
			value = arg_36_1
		})
	end)
	self:bind(Dorm3dPhotoMediator.CAMERA_LIFT_CHANGED, function(arg_37_0, arg_37_1)
		self:sendNotification(Dorm3dPhotoMediator.CAMERA_LIFT_CHANGED, {
			value = arg_37_1
		})
	end)
	self:bind(Dorm3dPhotoMediator.CAMERA_STICK_MOVE, function(arg_38_0, arg_38_1)
		self:sendNotification(Dorm3dPhotoMediator.CAMERA_STICK_MOVE, arg_38_1)
	end)
	self:bind(Dorm3dRoomMediator.ENTER_VOLLEYBALL, function(arg_39_0, arg_39_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.DORM3D_VOLLEYBALL, {
			groupId = arg_39_1
		})
	end)
	self:bind(Dorm3dRoomMediator.ENTER_DANCE, function(arg_40_0, arg_40_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.DORM3D_DANCE, {
			groupId = arg_40_1
		})
	end)
	self:bind(Dorm3dRoomMediator.ENTER_CARWASH, function(arg_41_0, arg_41_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.DORM3D_CAR_WASH, {
			groupId = arg_41_1
		})
	end)
	self:bind(Dorm3dRoomMediator.ON_DROP_CLIENT, function(arg_42_0, arg_42_1)
		pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_DROP_CLIENT, arg_42_1)
	end)
	self:bind(Dorm3dRoomMediator.OPEN_SETTING_LAYER, function(arg_43_0)
		self:addSubLayers(Context.New({
			viewComponent = Dorm3dSettingScene,
			mediator = NewSettingsMediator
		}))
	end)
	self.viewComponent:SetRoom(getProxy(ApartmentProxy):getRoom(self.contextData.roomId))

	if self.viewComponent.room:isPersonalRoom() then
		self.viewComponent:SetApartment((getProxy(ApartmentProxy):getApartment(self.contextData.groupIds[1])))
	end

	Dorm3dFurniture.RecordLastTimelimitShopFurniture()
end

function Dorm3dRoomMediator:initNotificationHandleDic()
	self.handleDic = {
		[GAME.APARTMENT_TRIGGER_FAVOR_DONE] = function(arg_45_0, arg_45_1)
			arg_45_0.viewComponent:PopFavorTrigger((arg_45_1:getBody()))
		end,
		[GAME.APARTMENT_LEVEL_UP_DONE] = function(arg_46_0, arg_46_1)
			local var_46_0 = arg_46_1:getBody()

			seriesAsync({
				function(arg_47_0)
					arg_46_0.viewComponent:SetAllBlackbloardValue("inLockLayer", true)
					arg_46_0.viewComponent:PopFavorLevelUp(var_46_0.apartment, var_46_0.award, arg_47_0)
				end
			}, function()
				arg_46_0.viewComponent:SetAllBlackbloardValue("inLockLayer", false)
				arg_46_0.viewComponent:CheckQueue()
				arg_46_0:sendNotification(Dorm3dRoomMediator.ON_LEVEL_UP_FINISH)
			end)
		end,
		[STORY_EVENT.TEST] = function(arg_49_0, arg_49_1)
			arg_49_0.viewComponent:TalkingEventHandle((arg_49_1:getBody()))
		end,
		[ApartmentProxy.UPDATE_APARTMENT] = function(arg_50_0, arg_50_1)
			local var_50_0 = arg_50_1:getBody()

			if arg_50_0.viewComponent.apartment and arg_50_0.viewComponent.apartment:GetConfigID() == var_50_0:GetConfigID() then
				arg_50_0.viewComponent:SetApartment(var_50_0)
			end
		end,
		[Dorm3dRoomMediator.OTHER_DO_TALK] = function(arg_51_0, arg_51_1)
			local var_51_0 = arg_51_1:getBody()

			arg_51_0.viewComponent.inReplayTalk = true

			arg_51_0.viewComponent:DoTalk(var_51_0.talkId, function()
				arg_51_0.viewComponent.inReplayTalk = false

				existCall(var_51_0.callback)
			end)
		end,
		[Dorm3dRoomMediator.OTHER_POP_UNLOCK] = function(arg_53_0, arg_53_1)
			arg_53_0.viewComponent:AddUnlockDisplay((arg_53_1:getBody()))
		end,
		[GAME.APARTMENT_DO_TALK_DONE] = function(arg_54_0, arg_54_1)
			arg_54_0.viewComponent:UpdateBtnState()
		end,
		[GAME.APARTMENT_COLLECTION_ITEM_DONE] = function(arg_55_0, arg_55_1)
			local var_55_0 = arg_55_1:getBody()

			arg_55_0:addSubLayers(Context.New({
				viewComponent = Dorm3dCollectAwardLayer,
				mediator = Dorm3dCollectAwardMediator,
				data = {
					itemId = var_55_0.itemId,
					isNew = var_55_0.isNew
				}
			}))
			arg_55_0.viewComponent:UpdateBtnState()
		end,
		[Dorm3dRoomMediator.CHAMGE_TIME_RELOAD_SCENE] = function(arg_56_0, arg_56_1)
			arg_56_0.contextData.timeIndex = arg_56_1:getBody().timeIndex

			arg_56_0.viewComponent:SwitchDayNight(arg_56_0.contextData.timeIndex)
			onNextTick(function()
				arg_56_0.viewComponent:RefreshSlots()
			end)
			arg_56_0.viewComponent:emit(CollectionSystem.UPDATE_CONTACT_STATE, arg_56_0.contextData.timeIndex)
		end,
		[GAME.APARTMENT_GIVE_GIFT_DONE] = function(arg_58_0, arg_58_1)
			local var_58_0 = arg_58_1:getBody()

			arg_58_0.viewComponent:PlayHeartFX(var_58_0.groupId)
			arg_58_0.viewComponent:UpdateBtnState()
			getProxy(Dorm3dChatProxy):TriggerEvent({
				{
					value = 1,
					event_type = arg_58_0.contextData.timeIndex == 1 and 113 or 118,
					ship_id = var_58_0.groupId
				}
			})
		end,
		[Dorm3dRoomMediator.GUIDE_CLICK_LADY] = function(arg_59_0, arg_59_1)
			warning("this.GUIDE_CLICK_LADY")
			arg_59_0.viewComponent:EnterWatchMode()
		end,
		[Dorm3dRoomMediator.GUIDE_CHECK_GUIDE] = function(arg_60_0, arg_60_1)
			arg_60_0.viewComponent:CheckGuide()
		end,
		[Dorm3dRoomMediator.GUIDE_CHECK_LEVEL_UP] = function(arg_61_0, arg_61_1)
			arg_61_0.viewComponent:CheckLevelUp()
		end,
		[ApartmentProxy.UPDATE_ROOM] = function(arg_62_0, arg_62_1)
			local var_62_0 = arg_62_1:getBody()

			if var_62_0:GetConfigID() == arg_62_0.viewComponent.room:GetConfigID() then
				arg_62_0.viewComponent:SetRoom(var_62_0)
			end
		end,
		[Dorm3dInviteMediator.ON_DORM] = function(arg_63_0, arg_63_1)
			arg_63_0:sendNotification(GAME.CHANGE_SCENE, SCENE.DORM3D_ROOM, (arg_63_1:getBody()))
		end,
		[Dorm3dMiniGameMediator.OPERATION] = function(arg_64_0, arg_64_1)
			arg_64_0.viewComponent:HandleGameNotification(Dorm3dMiniGameMediator.OPERATION, (arg_64_1:getBody()))
		end,
		[ApartmentProxy.ZERO_HOUR_REFRESH] = function(arg_65_0, arg_65_1)
			local var_65_0 = arg_65_1:getBody()

			arg_65_0.viewComponent:UpdateFavorDisplay()
		end,
		[Dorm3dRoomMediator.UPDATE_FAVOR_DISPLAY] = function(arg_66_0, arg_66_1)
			arg_66_0.viewComponent:UpdateFavorDisplay()
		end,
		[ApartmentProxy.UPDATE_ROOM_INVITE_LIST] = function(arg_67_0, arg_67_1)
			local var_67_0 = arg_67_1:getBody()

			for iter_67_0, iter_67_1 in ipairs(var_67_0.addIds) do
				table.insert(arg_67_0.contextData.groupIds, iter_67_1)
			end

			arg_67_0.viewComponent:LoadCharacterAdditionally(var_67_0.addIds, var_67_0.callback)
		end
	}
end

function Dorm3dRoomMediator:remove()
	return
end

return Dorm3dRoomMediator
