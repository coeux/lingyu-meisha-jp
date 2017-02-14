Buff_501_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_501_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_501_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_501_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e501")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adaf" )
	end,

	adaf = function( effectScript )
			AttachBuffEffect( true, Buff_501_fire.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1.5, 100, "e501",  effectScript)
	end,

}
