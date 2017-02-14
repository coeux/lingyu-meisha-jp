Buff_514_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_514_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_514_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_514_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e514")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "add" )
	end,

	add = function( effectScript )
			AttachBuffEffect( false, Buff_514_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "e514",  effectScript)
	end,

}
