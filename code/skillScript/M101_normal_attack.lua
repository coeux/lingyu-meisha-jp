M101_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M101_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M101_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M101_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0081")
		PreLoadSound("g0081")
		PreLoadAvatar("xiongzhuazi")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
		effectScript:RegisterEvent( 14, "adad" )
		effectScript:RegisterEvent( 21, "ads" )
	end,

	asd = function( effectScript )
		SetAnimation(M101_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0081")
		PlaySound("g0081")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, M101_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 200), 2, 100, "xiongzhuazi")
	end,

	ads = function( effectScript )
			DamageEffect(M101_normal_attack.info_pool[effectScript.ID].Attacker, M101_normal_attack.info_pool[effectScript.ID].Targeter, M101_normal_attack.info_pool[effectScript.ID].AttackType, M101_normal_attack.info_pool[effectScript.ID].AttackDataList, M101_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
