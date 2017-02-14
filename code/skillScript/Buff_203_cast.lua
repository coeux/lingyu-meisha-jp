Buff_203_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_203_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_203_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_203_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "wdads" )
	end,

	wdads = function( effectScript )
			AttachBuffEffect( false, Buff_203_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e203",  effectScript)
	end,

}
