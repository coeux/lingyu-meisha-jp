Buff_305_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_305_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_305_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_305_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e305")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aff" )
	end,

	aff = function( effectScript )
			AttachBuffEffect( false, Buff_305_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e305",  effectScript)
	end,

}
