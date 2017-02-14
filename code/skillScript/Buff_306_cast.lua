Buff_306_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_306_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_306_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_306_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e306")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdg" )
	end,

	fdg = function( effectScript )
			AttachBuffEffect( false, Buff_306_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e306",  effectScript)
	end,

}
