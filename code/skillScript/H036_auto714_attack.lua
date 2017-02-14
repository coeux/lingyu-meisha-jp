H036_auto714_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H036_auto714_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H036_auto714_attack.info_pool[effectScript.ID].Attacker)
        
		H036_auto714_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H036_xuli_1")
		PreLoadSound("skill_03601")
		PreLoadAvatar("H036_xuli_2")
		PreLoadSound("skill_03602")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "guygiu" )
		effectScript:RegisterEvent( 11, "uygigiu" )
		effectScript:RegisterEvent( 29, "tytfuf" )
		effectScript:RegisterEvent( 32, "fguggigig" )
	end,

	guygiu = function( effectScript )
		SetAnimation(H036_auto714_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	uygigiu = function( effectScript )
		AttachAvatarPosEffect(false, H036_auto714_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 90), 1.2, 100, "H036_xuli_1")
		PlaySound("skill_03601")
	end,

	tytfuf = function( effectScript )
		AttachAvatarPosEffect(false, H036_auto714_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 70), 1.8, 100, "H036_xuli_2")
		PlaySound("skill_03602")
	end,

	fguggigig = function( effectScript )
			DamageEffect(H036_auto714_attack.info_pool[effectScript.ID].Attacker, H036_auto714_attack.info_pool[effectScript.ID].Targeter, H036_auto714_attack.info_pool[effectScript.ID].AttackType, H036_auto714_attack.info_pool[effectScript.ID].AttackDataList, H036_auto714_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
