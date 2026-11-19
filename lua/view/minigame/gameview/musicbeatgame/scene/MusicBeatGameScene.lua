local MusicBeatGameScene = class("MusicBeatGameScene")

function MusicBeatGameScene:Ctor(arg_1_1, arg_1_2, arg_1_3)
	self._tf = arg_1_1
	self._event = arg_1_2
	self._gameVo = arg_1_3
	self.sceneMask = findTF(self._tf, "sceneMask")
	self.sceneContainer = findTF(self._tf, "sceneMask/sceneContainer")

	self:showContainer(false)

	self.bgmController = MusicBeatBgmCtrl.New(self._event)
	self.mapController = MusicBeatMapCtrl.New(self.sceneContainer, self._event)
	self.noteController = MusicBeatNoteCtrl.New(self.sceneContainer, self._event)

	self.bgmController:setGameVo(self._gameVo)
	self.mapController:setGameVo(self._gameVo)
	self.noteController:setGameVo(self._gameVo)
end

function MusicBeatGameScene:readyStart()
	self:showContainer(true)
	self.bgmController:readyStart()
	self.mapController:readyStart()
	self.noteController:readyStart()
end

function MusicBeatGameScene:start()
	self.bgmController:start()
	self.mapController:start()
	self.noteController:start()
end

function MusicBeatGameScene:step(arg_4_1)
	self.bgmController:step(arg_4_1)
	self.mapController:step(arg_4_1)
	self.noteController:step(arg_4_1)
end

function MusicBeatGameScene:clear()
	self.bgmController:clear()
	self.mapController:clear()
	self.noteController:clear()
end

function MusicBeatGameScene:stop()
	self.bgmController:stop()
	self.mapController:stop()
	self.noteController:stop()
end

function MusicBeatGameScene:resume()
	self.bgmController:resume()
	self.mapController:resume()
	self.noteController:resume()
end

function MusicBeatGameScene:dispose()
	self.bgmController:dispose()
	self.mapController:dispose()
	self.noteController:dispose()
end

function MusicBeatGameScene:showContainer(arg_9_1)
	setActive(self.sceneMask, arg_9_1)
end

return MusicBeatGameScene
