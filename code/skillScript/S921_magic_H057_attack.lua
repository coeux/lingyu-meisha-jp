S921_magic_H057_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S921_magic_H057_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S921_magic_H057_attack.info_pool[effectScript.ID].Attacker)
        
		S921_magic_H057_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05701")
		PreLoadAvatar("H057_3_1")
		PreLoadSound("skill_05701")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjki" )
		effectScript:RegisterEvent( 25, "gh" )
		effectScript:RegisterEvent( 58, "fgy" )
		effectScript:RegisterEvent( 60, "ui" )
	end,

	hjki = function( effectScript )
		SetAnimation(S921_magic_H057_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05701")
	end,

	gh = function( effectScript )
		SetAnimation(S921_magic_H057_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	fgy = function( effectScript )
		AttachAvatarPosEffect(false, S921_magic_H057_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H057_3_1")
		PlaySound("skill_05701")
	end,

	ui = function( effectScript )
			DamageEffect(S921_magic_H057_attack.info_pool[effectScript.ID].Attacker, S921_magic_H057_attack.info_pool[effectScript.ID].Targeter, S921_magic_H057_attack.info_pool[effectScript.ID].AttackType, S921_magic_H057_attack.info_pool[effectScript.ID].AttackDataList, S921_magic_H057_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
