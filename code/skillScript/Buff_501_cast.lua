Buff_501_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_501_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_501_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_501_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e501")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "lian" )
	end,

	lian = function( effectScript )
			AttachBuffEffect( false, Buff_501_cast.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "e501",  effectScript)
	end,

}
