Buff_616_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_616_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_616_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S616_1")
		PreLoadAvatar("S616_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
	end,

	A = function( effectScript )
		AttachBuffEffect( false, Buff_616_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S616_1",  effectScript)
	AttachBuffEffect( false, Buff_616_cast.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S616_2",  effectScript)
	end,

}
