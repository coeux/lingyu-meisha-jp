H014_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H014_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H014_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H014_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01401")
		PreLoadSound("atalk_01401")
		PreLoadAvatar("q_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "fdgh" )
		effectScript:RegisterEvent( 20, "saf" )
		effectScript:RegisterEvent( 24, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(H014_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdgh = function( effectScript )
			PlaySound("skill_01401")
		PlaySound("atalk_01401")
	end,

	saf = function( effectScript )
		AttachAvatarPosEffect(false, H014_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(180, 50), 2, 100, "q_pugong")
	end,

	aa = function( effectScript )
			DamageEffect(H014_normal_attack.info_pool[effectScript.ID].Attacker, H014_normal_attack.info_pool[effectScript.ID].Targeter, H014_normal_attack.info_pool[effectScript.ID].AttackType, H014_normal_attack.info_pool[effectScript.ID].AttackDataList, H014_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
