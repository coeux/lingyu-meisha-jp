Buff_307_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_307_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_307_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_307_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e307")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ffds" )
	end,

	ffds = function( effectScript )
			AttachBuffEffect( false, Buff_307_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e307",  effectScript)
	end,

}
