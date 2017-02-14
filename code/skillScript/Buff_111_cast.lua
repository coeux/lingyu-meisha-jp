Buff_111_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_111_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_111_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_111_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e111")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
	end,

	asd = function( effectScript )
			AttachBuffEffect( false, Buff_111_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e111",  effectScript)
	end,

}
