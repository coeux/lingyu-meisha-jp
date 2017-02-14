Buff_612_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_612_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_612_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S612")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
	end,

	A = function( effectScript )
		AttachBuffEffect( true, Buff_612_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S612",  effectScript)
	end,

}
