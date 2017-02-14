S547_magic_M101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S547_magic_M101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S547_magic_M101_attack.info_pool[effectScript.ID].Attacker)
        
		S547_magic_M101_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(S547_magic_M101_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0081")
		PlaySound("g0081")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, S547_magic_M101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, -20), 4, 100, "weipugong")
	end,

	ads = function( effectScript )
			DamageEffect(S547_magic_M101_attack.info_pool[effectScript.ID].Attacker, S547_magic_M101_attack.info_pool[effectScript.ID].Targeter, S547_magic_M101_attack.info_pool[effectScript.ID].AttackType, S547_magic_M101_attack.info_pool[effectScript.ID].AttackDataList, S547_magic_M101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
