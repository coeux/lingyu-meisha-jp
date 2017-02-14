Buff_517_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_517_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_517_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_517_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e517")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adaf" )
	end,

	adaf = function( effectScript )
			AttachBuffEffect( true, Buff_517_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "e517",  effectScript)
	end,

}
