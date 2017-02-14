H013_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H013_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H013_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H013_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01301")
		PreLoadSound("attack_01301")
		PreLoadAvatar("jiu_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "fdg" )
		effectScript:RegisterEvent( 14, "defd" )
		effectScript:RegisterEvent( 16, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(H013_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_01301")
	end,

	fdg = function( effectScript )
			PlaySound("attack_01301")
	end,

	defd = function( effectScript )
		AttachAvatarPosEffect(false, H013_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-70, 140), 2, 100, "jiu_pugong")
	end,

	aa = function( effectScript )
			DamageEffect(H013_normal_attack.info_pool[effectScript.ID].Attacker, H013_normal_attack.info_pool[effectScript.ID].Targeter, H013_normal_attack.info_pool[effectScript.ID].AttackType, H013_normal_attack.info_pool[effectScript.ID].AttackDataList, H013_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
