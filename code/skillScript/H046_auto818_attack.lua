H046_auto818_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H046_auto818_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H046_auto818_attack.info_pool[effectScript.ID].Attacker)
        
		H046_auto818_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H046_xuli_1")
		PreLoadSound("attack_04602")
		PreLoadAvatar("H046_xuli_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgfh" )
		effectScript:RegisterEvent( 10, "dsfdgfh" )
		effectScript:RegisterEvent( 14, "sdfdh" )
		effectScript:RegisterEvent( 21, "fdgfhj" )
	end,

	sfdgfh = function( effectScript )
		SetAnimation(H046_auto818_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H046_auto818_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, -100, "H046_xuli_1")
		PlaySound("attack_04602")
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, H046_auto818_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, -20), 1.2, 100, "H046_xuli_2")
	end,

	fdgfhj = function( effectScript )
			DamageEffect(H046_auto818_attack.info_pool[effectScript.ID].Attacker, H046_auto818_attack.info_pool[effectScript.ID].Targeter, H046_auto818_attack.info_pool[effectScript.ID].AttackType, H046_auto818_attack.info_pool[effectScript.ID].AttackDataList, H046_auto818_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
