Buff_318_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_318_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_318_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_318_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e318")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdh" )
	end,

	sfdh = function( effectScript )
			AttachBuffEffect( false, Buff_318_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e318",  effectScript)
	end,

}
