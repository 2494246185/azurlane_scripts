local IslandPhotoMainPage = class("IslandPhotoMainPage", import("...base.IslandBasePage"))

function IslandPhotoMainPage:getUIName()
	return "IslandMainPhotoUI"
end

function IslandPhotoMainPage:OnLoaded()
	self.centerPanel = self._tf:Find("Center")
	self.normalPanel = self._tf:Find("Center/Normal")

	setActive(self.normalPanel, true)

	self.btnHideUI = self._tf:Find("Center/HideUI")
	self.btnReset = self._tf:Find("Center/Reset")
	self.btnFreeze = self._tf:Find("Center/Freeze")
	self.RightTopTf = self._tf:Find("RightTop")
	self.FilmTf = self._tf:Find("RightTop/Film")
	self.ShotTf = self._tf:Find("RightTop/Shot")
	self.btnFilm = self._tf:Find("RightTop/Film/Film")
	self.filmTime = self._tf:Find("RightTop/FilmTime")

	setActive(self.filmTime, false)

	self.btnShoot = self._tf:Find("RightTop/Shot/Shot")
	self.hideuiMask = self._tf:Find("Mask")

	setActive(self.hideuiMask, false)

	self.ysScreenShoter = self._tf:Find("Shoter"):GetComponent(typeof(YSTool.YSScreenShoter))
	self.stopRecTf = self._tf:Find("stopRec")
	self.stopRecBtn = self._tf:Find("stopRec/stopRec")
	self.videoTipPanel = self._tf:Find("videoTipPanel")

	setActive(self.videoTipPanel, false)

	self.photoModel = self._tf:Find("Center/photoModel")
	self.unselectBgTF = self.photoModel:Find("un_select_bg")
	self.select_bgTF = self.photoModel:Find("select_bg")
	self.firstModelTF = self.photoModel:Find("first")
	self.thirdModelTF = self.photoModel:Find("third")
	self.mainCamera = IslandCameraMgr.instance._mainCamera
	self.takeModelTFDic = {
		[IslandConst.TakePhotoModel.First] = self.firstModelTF,
		[IslandConst.TakePhotoModel.Third] = self.thirdModelTF
	}
	self.sliderZoom = self.normalPanel:Find("Zoom/Slider")
	self.fpsCamera = IslandCameraMgr.instance:GetVirtualCamera(IslandConst.FIRST_PERSON_TAKE_PHOTO_CAMERA_NAME)
	self.tpsCamera = IslandCameraMgr.instance:GetVirtualCamera(IslandConst.Third_PERSON_TAKE_PHOTO_CAMERA_NAME)
	self.fpsHeight = pg.island_set.island_photohight_FPS.key_value_varchar
	self.tpsHeight = pg.island_set.island_photohight_TPS.key_value_varchar
end

function IslandPhotoMainPage:AddListeners()
	return
end

function IslandPhotoMainPage:RemoveListeners()
	return
end

function IslandPhotoMainPage:OnInit()
	onButton(self, self._tf:Find("Center/Normal/Back/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.island_help_photo.tip
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Center/Normal/Back"), function()
		self:Hide()
	end, SFX_CANCEL)
	setActive(self.ShotTf, true)
	setActive(self.FilmTf, false)
	onButton(self, self._tf:Find("RightTop/Shot/Switch"), function()
		setActive(self.ShotTf, false)
		setActive(self.FilmTf, true)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("RightTop/Film/Switch"), function()
		setActive(self.ShotTf, true)
		setActive(self.FilmTf, false)
	end, SFX_PANEL)
	onButton(self, self.btnShoot, function()
		pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildIslandTakeThoto(2))
		BLHX.Rendering.HotUpdate.ScreenShooterPass.TakePhoto(self.mainCamera, function(arg_12_0)
			warning("截图结果：" .. tostring(true))
			self:OpenPage(IslandPhotoSharePage, Tex2DExtension.EncodeToJPG(arg_12_0), arg_12_0)
			IslandTaskHelper.UpdateClientTaskProgress(IslandTaskTargetType.TAKE_PHOTO, 0)
			IslandAchievementHelper.OnTakePhoto(0)
		end)
	end, SFX_PANEL)
	onButton(self, self.photoModel:Find("left_btn"), function()
		self:LeftSelectBtnHandle()
	end, SFX_PANEL)
	onButton(self, self.select_bgTF:Find("left_btn"), function()
		self:RightSelectBtnHandle()
	end, SFX_PANEL)
	onButton(self, self.firstModelTF, function()
		self:ChangeTakePhotoModel(IslandConst.TakePhotoModel.First)
		self:RightSelectBtnHandle()
	end, SFX_PANEL)
	onButton(self, self.thirdModelTF, function()
		self:ChangeTakePhotoModel(IslandConst.TakePhotoModel.Third)
		self:RightSelectBtnHandle()
	end, SFX_PANEL)
	onSlider(self, self.sliderZoom, function(arg_17_0)
		self:ChangeSliderValue(arg_17_0)
	end)

	self.hideUI = false

	onButton(self, self.btnHideUI, function()
		if self.hideUI then
			return
		end

		setActive(self.hideuiMask, true)
		setActive(self.centerPanel, false)

		self.RightTopTf:GetComponent("CanvasGroup").alpha = 0
		self.RightTopTf:GetComponent("CanvasGroup").blocksRaycasts = false
		self.hideUI = true

		self:emitCore(ISLAND_EVT.SetOpMoveBtnActve, false)
	end, SFX_PANEL)
	onButton(self, self.btnReset, function()
		local var_19_0

		if self.takePhotoModel == 2 then
			var_19_0 = (self.fpsHeight[1] - self.fpsHeight[2]) / (self.fpsHeight[3] - self.fpsHeight[2])
		else
			var_19_0 = (self.tpsHeight[1] - self.tpsHeight[2]) / (self.tpsHeight[3] - self.tpsHeight[2])

			self:emitCore(ISLAND_EVT.Change_TakePhoto_Model, self.takePhotoModel)
		end

		setSlider(self.sliderZoom, 0, 1, var_19_0)
	end, SFX_PANEL)
	onButton(self, self.hideuiMask, function()
		if not self.hideUI then
			return
		end

		setActive(self.centerPanel, true)
		setActive(self.hideuiMask, false)

		self.RightTopTf:GetComponent("CanvasGroup").alpha = 1
		self.RightTopTf:GetComponent("CanvasGroup").blocksRaycasts = true
		self.hideUI = false

		self:emitCore(ISLAND_EVT.SetOpMoveBtnActve, true)
	end)

	self.recordState = false

	onButton(self, self.btnFilm, function()
		pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildIslandTakeThoto(3))

		local function var_21_0(arg_22_0)
			setActive(self.centerPanel, arg_22_0)

			self._tf:Find("RightTop"):GetComponent("CanvasGroup").alpha = arg_22_0 and 1 or 0

			self:emitCore(ISLAND_EVT.SetOpMoveBtnActve, arg_22_0, true)
		end

		if not self.recordState then
			local function var_21_1(arg_23_0)
				if not arg_23_0 then
					var_21_0(true)

					self.recordState = false

					LeanTween.moveX(self.stopRecBtn, self.stopRecBtn.rect.width, 0.15)
				else
					self.recordState = true
				end
			end

			local function var_21_2()
				setActive(self.stopRecTf, true)
				LeanTween.moveX(self.stopRecBtn, 0, 0.15):setOnComplete(System.Action(function()
					IslandPhotoMainPage.SetMute(true)

					self.recordFilePath = YSNormalTool.RecordTool.GenRecordFilePath()

					YSNormalTool.RecordTool.StartRecording(var_21_1, self.recordFilePath)
				end))
			end

			seriesAsync({
				function(arg_26_0)
					PermissionHelper.Request3DDorm(arg_26_0, nil)
				end,
				function(arg_27_0)
					var_21_0(false)

					local var_27_0 = PlayerPrefs.GetInt("hadShowForVideoTipDorm", 0)

					if not var_27_0 or var_27_0 <= 0 then
						PlayerPrefs.SetInt("hadShowForVideoTipDorm", 1)

						self.videoTipPanel:Find("Text"):GetComponent("Text").text = i18n("word_take_video_tip")

						onButton(self, self.videoTipPanel, function()
							setActive(self.videoTipPanel, false)
							var_21_2()
						end)
						setActive(self.videoTipPanel, true)
					else
						var_21_2()
					end
				end
			})
		end
	end, SFX_PANEL)
	onButton(self, self.stopRecBtn, function()
		self.recordState = false

		local function var_29_0(arg_30_0)
			if arg_30_0 and PLATFORM == PLATFORM_ANDROID then
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("word_save_video"),
					onNo = function()
						if System.IO.File.Exists(self.recordFilePath) then
							System.IO.File.Delete(self.recordFilePath)
						end
					end,
					onYes = function()
						YSNormalTool.MediaTool.SaveVideoToAlbum(self.recordFilePath, function(arg_33_0, arg_33_1)
							if arg_33_0 then
								pg.TipsMgr.GetInstance():ShowTips(i18n("word_save_ok"))

								if System.IO.File.Exists(self.recordFilePath) then
									System.IO.File.Delete(self.recordFilePath)
								end
							end
						end)
					end
				})
			end

			self.recordState = false
		end

		local function var_29_1(arg_34_0)
			setActive(self.centerPanel, arg_34_0)

			self._tf:Find("RightTop"):GetComponent("CanvasGroup").alpha = arg_34_0 and 1 or 0
		end

		if not LeanTween.isTweening(go(self.stopRecBtn)) then
			LeanTween.moveX(self.stopRecBtn, self.stopRecBtn.rect.width, 0.15):setOnComplete(System.Action(function()
				setActive(self.stopRecTf, false)
				seriesAsync({
					function(arg_36_0)
						YSNormalTool.RecordTool.StopRecording(var_29_0)
						var_29_1(true)
						IslandPhotoMainPage.SetMute(false)
					end
				})
			end))
		end
	end)
	setActive(self.stopRecTf, false)
end

function IslandPhotoMainPage:ChangeSliderValue(arg_37_1)
	local var_37_0
	local var_37_1

	if self.takePhotoModel == 2 then
		var_37_0 = self.fpsCamera.gameObject:GetComponent(typeof(CameraPovLook))
		var_37_1 = arg_37_1 * (self.fpsHeight[3] - self.fpsHeight[2]) + self.fpsHeight[2]
	else
		var_37_0 = self.tpsCamera.gameObject:GetComponent(typeof(CameraPovLook))
		var_37_1 = arg_37_1 * (self.tpsHeight[3] - self.tpsHeight[2]) + self.tpsHeight[2]

		self:emitCore(ISLAND_EVT.Change_Photo_Height, self.takePhotoModel, arg_37_1 * (self.tpsHeight[3] - self.tpsHeight[2]) + self.tpsHeight[2])
	end

	var_37_0:SetTargetOffsetY(var_37_1)
end

function IslandPhotoMainPage:RightSelectBtnHandle()
	setActive(self.unselectBgTF, true)
	setActive(self.select_bgTF, false)
	setActive(self.photoModel:Find("left_btn"), true)

	for iter_38_0, iter_38_1 in pairs(self.takeModelTFDic) do
		if self.takePhotoModel == iter_38_0 then
			setActive(iter_38_1:Find("select"), true)
			setActive(iter_38_1:Find("unSelect"), false)
			setActive(iter_38_1, true)
			setAnchoredPosition(iter_38_1, {
				x = 0
			})
		else
			setActive(iter_38_1:Find("unSelect"), true)
			setActive(iter_38_1:Find("select"), false)
			setActive(iter_38_1, false)
		end
	end
end

function IslandPhotoMainPage:LeftSelectBtnHandle()
	setActive(self.unselectBgTF, false)
	setActive(self.select_bgTF, true)
	setActive(self.photoModel:Find("left_btn"), false)

	for iter_39_0, iter_39_1 in pairs(self.takeModelTFDic) do
		setActive(iter_39_1, true)

		if self.takePhotoModel == iter_39_0 then
			setAnchoredPosition(iter_39_1, {
				x = 0
			})
		else
			setAnchoredPosition(iter_39_1, {
				x = -66 * 1
			})
		end
	end
end

function IslandPhotoMainPage:ChangeTakePhotoModel(arg_40_1)
	if self.takePhotoModel == arg_40_1 then
		return
	end

	if self.takePhotoModel then
		setActive(self.takeModelTFDic[self.takePhotoModel]:Find("select"), false)
		setActive(self.takeModelTFDic[self.takePhotoModel]:Find("unSelect"), true)
	end

	self.takePhotoModel = arg_40_1

	setActive(self.takeModelTFDic[self.takePhotoModel]:Find("select"), true)
	setActive(self.takeModelTFDic[self.takePhotoModel]:Find("unSelect"), false)

	local var_40_0
	local var_40_1

	if self.takePhotoModel == 2 then
		var_40_0 = self.fpsCamera.gameObject:GetComponent(typeof(CameraPovZoom))
		var_40_1 = (self.fpsHeight[1] - self.fpsHeight[2]) / (self.fpsHeight[3] - self.fpsHeight[2])
	else
		var_40_0 = self.tpsCamera.gameObject:GetComponent(typeof(CameraPovZoom))
		var_40_1 = (self.tpsHeight[1] - self.tpsHeight[2]) / (self.tpsHeight[3] - self.tpsHeight[2])
	end

	setSlider(self.sliderZoom, 0, 1, var_40_1)
	var_40_0:SetCurrentZoom(50)
	self:emitCore(ISLAND_EVT.Change_TakePhoto_Model, self.takePhotoModel)
end

function IslandPhotoMainPage:OnShow()
	pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildIslandTakeThoto(1))
	self:ChangeTakePhotoModel(IslandConst.TakePhotoModel.First)
	self:RightSelectBtnHandle()
end

function IslandPhotoMainPage:OnDisable()
	self:OnHide()
end

function IslandPhotoMainPage:OnHide()
	if self.recordState then
		triggerButton(self.btnFilm)

		return
	end
end

function IslandPhotoMainPage:OnExit()
	self.takePhotoModel = nil

	self:emitCore(ISLAND_EVT.Change_TakePhoto_Model, IslandConst.TakePhotoModel.None, (self.islandScene.sceneMgr:IsAllPageClose()))
end

function IslandPhotoMainPage:SetMute()
	if self then
		pg.CriMgr.GetInstance():MuteAllVolume()
	else
		pg.CriMgr.GetInstance():ResetAllVolume()
	end
end

function IslandPhotoMainPage:OnDestroy()
	return
end

return IslandPhotoMainPage
