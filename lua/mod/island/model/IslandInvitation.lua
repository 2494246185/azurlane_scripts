local IslandInvitation = class("IslandInvitation", import(".IslandItem"))

function IslandInvitation:Ctor(arg_1_1)
	self.shipId = arg_1_1

	IslandInvitation.super.Ctor(self, {
		num = 1,
		time = 0,
		id = pg.island_chara_template[arg_1_1].invite_item
	})
end

function IslandInvitation:GetShipName()
	return pg.island_chara_template[self.shipId].name
end

return IslandInvitation
