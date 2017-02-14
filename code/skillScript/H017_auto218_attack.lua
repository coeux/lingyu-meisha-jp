H017_auto218_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H017_auto218_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H017_auto218_attack.info_pool[effectScript.ID].Attacker)
        
		H017_auto218_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01701")
		PreLoadSound("skill_01703")
		PreLoadAvatar("H005_xuli")
		PreLoadSound("skill_01703")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 9, "fhfgj" )
		effectScript:RegisterEvent( 16, "gjhkjhl" )
		effectScript:RegisterEvent( 23, "dsgdfh" )
		effectScript:RegisterEvent( 35, "uiyiuo" )
	end,

	a = function( effectScript )
		SetAnimation(H017_auto218_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01701")
	end,

	fhfgj = function( effectScript )
			PlaySound("skill_01703")
	end,

	gjhkjhl = function( effectScript )
		AttachAvatarPosEffect(false, H017_auto218_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H005_xuli")
	end,

	dsgdfh = function( effectScript )
			PlaySound("skill_01703")
	end,

	uiyiuo = function( effectScript )
			DamageEffect(H017_auto218_attack.info_pool[effectScript.ID].Attacker, H017_auto218_attack.info_pool[effectScript.ID].Targeter, H017_auto218_attack.info_pool[effectScript.ID].AttackType, H017_auto218_attack.info_pool[effectScript.ID].AttackDataList, H017_auto218_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
