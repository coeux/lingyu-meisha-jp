Buff_519_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_519_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_519_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_519_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e519")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "saf" )
	end,

	saf = function( effectScript )
			AttachBuffEffect( true, Buff_519_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "e519",  effectScript)
	end,

}
