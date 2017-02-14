Buff_202_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_202_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_202_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_202_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e202")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awdw" )
	end,

	awdw = function( effectScript )
			AttachBuffEffect( false, Buff_202_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e202",  effectScript)
	end,

}
