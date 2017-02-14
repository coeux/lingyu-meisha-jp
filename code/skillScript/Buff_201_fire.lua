Buff_201_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_201_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_201_fire.info_pool[effectScript.ID].Attacker)
		Buff_201_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e207")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asf" )
	end,

	asf = function( effectScript )
			AttachBuffEffect( false, Buff_201_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "e207",  effectScript)
	end,

}
