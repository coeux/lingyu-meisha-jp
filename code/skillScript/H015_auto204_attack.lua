H015_auto204_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H015_auto204_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H015_auto204_attack.info_pool[effectScript.ID].Attacker)
        
		H015_auto204_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01501")
		PreLoadSound("skill_01501")
		PreLoadSound("skill_01502")
		PreLoadAvatar("S200_1")
		PreLoadAvatar("S200")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 21, "gfdhf" )
		effectScript:RegisterEvent( 24, "dsgdfh" )
		effectScript:RegisterEvent( 25, "fasfsdf" )
		effectScript:RegisterEvent( 26, "s" )
		effectScript:RegisterEvent( 27, "d" )
	end,

	b = function( effectScript )
		SetAnimation(H015_auto204_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01501")
	end,

	gfdhf = function( effectScript )
			PlaySound("skill_01501")
	end,

	dsgdfh = function( effectScript )
			PlaySound("skill_01502")
	end,

	fasfsdf = function( effectScript )
		AttachAvatarPosEffect(false, H015_auto204_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 10), 1.2, 100, "S200_1")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, H015_auto204_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S200")
	end,

	d = function( effectScript )
			DamageEffect(H015_auto204_attack.info_pool[effectScript.ID].Attacker, H015_auto204_attack.info_pool[effectScript.ID].Targeter, H015_auto204_attack.info_pool[effectScript.ID].AttackType, H015_auto204_attack.info_pool[effectScript.ID].AttackDataList, H015_auto204_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
