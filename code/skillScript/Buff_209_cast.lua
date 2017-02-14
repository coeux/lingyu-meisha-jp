Buff_209_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_209_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_209_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_209_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e209")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gfh" )
	end,

	gfh = function( effectScript )
			AttachBuffEffect( false, Buff_209_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e209",  effectScript)
	end,

}
