Buff_616_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_616_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_616_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S616_3")
		PreLoadAvatar("S616_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "S" )
	end,

	S = function( effectScript )
		AttachBuffEffect( true, Buff_616_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S616_3",  effectScript)
	AttachBuffEffect( true, Buff_616_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S616_4",  effectScript)
	end,

}
