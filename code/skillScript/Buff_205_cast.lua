Buff_205_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_205_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_205_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_205_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e205")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awd" )
	end,

	awd = function( effectScript )
			AttachBuffEffect( false, Buff_205_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e205",  effectScript)
	end,

}
