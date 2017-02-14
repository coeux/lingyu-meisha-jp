Buff_614_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_614_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_614_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S614_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "S" )
	end,

	S = function( effectScript )
		AttachBuffEffect( true, Buff_614_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S614_2",  effectScript)
	end,

}
