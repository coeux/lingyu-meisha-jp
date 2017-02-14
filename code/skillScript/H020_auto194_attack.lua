H020_auto194_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H020_auto194_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H020_auto194_attack.info_pool[effectScript.ID].Attacker)
        
		H020_auto194_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02001")
		PreLoadSound("stalk_02001")
		PreLoadAvatar("S192_1")
		PreLoadAvatar("S192_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 11, "dsfrf" )
		effectScript:RegisterEvent( 43, "aaaa" )
		effectScript:RegisterEvent( 44, "asff" )
		effectScript:RegisterEvent( 45, "aaa" )
	end,

	aa = function( effectScript )
		SetAnimation(H020_auto194_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_02001")
		PlaySound("stalk_02001")
	end,

	dsfrf = function( effectScript )
		AttachAvatarPosEffect(false, H020_auto194_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -25), 2.2, -100, "S192_1")
	end,

	aaaa = function( effectScript )
			DamageEffect(H020_auto194_attack.info_pool[effectScript.ID].Attacker, H020_auto194_attack.info_pool[effectScript.ID].Targeter, H020_auto194_attack.info_pool[effectScript.ID].AttackType, H020_auto194_attack.info_pool[effectScript.ID].AttackDataList, H020_auto194_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asff = function( effectScript )
		AttachAvatarPosEffect(false, H020_auto194_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S192_2")
	end,

	aaa = function( effectScript )
		CameraShake()
	end,

}
