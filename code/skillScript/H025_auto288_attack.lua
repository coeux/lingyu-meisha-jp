H025_auto288_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H025_auto288_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H025_auto288_attack.info_pool[effectScript.ID].Attacker)
        
		H025_auto288_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H025_xuli")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgh" )
		effectScript:RegisterEvent( 24, "gfjhfgj" )
	end,

	sfdgh = function( effectScript )
		SetAnimation(H025_auto288_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	gfjhfgj = function( effectScript )
		AttachAvatarPosEffect(false, H025_auto288_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H025_xuli")
	end,

}
