M101_auto546_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M101_auto546_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M101_auto546_attack.info_pool[effectScript.ID].Attacker)
        
		M101_auto546_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0081")
		PreLoadSound("g0081")
		PreLoadAvatar("weipugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
		effectScript:RegisterEvent( 21, "adad" )
		effectScript:RegisterEvent( 23, "ads" )
	end,

	asd = function( effectScript )
		SetAnimation(M101_auto546_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0081")
		PlaySound("g0081")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, M101_auto546_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, -20), 4, 100, "weipugong")
	end,

	ads = function( effectScript )
			DamageEffect(M101_auto546_attack.info_pool[effectScript.ID].Attacker, M101_auto546_attack.info_pool[effectScript.ID].Targeter, M101_auto546_attack.info_pool[effectScript.ID].AttackType, M101_auto546_attack.info_pool[effectScript.ID].AttackDataList, M101_auto546_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
