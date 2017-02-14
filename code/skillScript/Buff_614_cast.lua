Buff_614_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_614_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_614_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S614_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "S" )
	end,

	S = function( effectScript )
		AttachBuffEffect( false, Buff_614_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S614_1",  effectScript)
	end,

}
