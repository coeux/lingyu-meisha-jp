H015_auto597_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H015_auto597_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H015_auto597_attack.info_pool[effectScript.ID].Attacker)
        
		H015_auto597_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01501")
		PreLoadSound("stalk_01501")
		PreLoadAvatar("S202_1")
		PreLoadSound("skill_01503")
		PreLoadAvatar("S202_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "B" )
		effectScript:RegisterEvent( 16, "fdhgfj" )
		effectScript:RegisterEvent( 19, "x" )
		effectScript:RegisterEvent( 20, "gfdh" )
		effectScript:RegisterEvent( 22, "dsdgfg" )
		effectScript:RegisterEvent( 24, "v" )
	end,

	B = function( effectScript )
		SetAnimation(H015_auto597_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdhgfj = function( effectScript )
			PlaySound("skill_01501")
		PlaySound("stalk_01501")
	end,

	x = function( effectScript )
		AttachAvatarPosEffect(false, H015_auto597_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 70), 1.2, 100, "S202_1")
	end,

	gfdh = function( effectScript )
			PlaySound("skill_01503")
	end,

	dsdgfg = function( effectScript )
		AttachAvatarPosEffect(false, H015_auto597_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S202_2")
	end,

	v = function( effectScript )
			DamageEffect(H015_auto597_attack.info_pool[effectScript.ID].Attacker, H015_auto597_attack.info_pool[effectScript.ID].Targeter, H015_auto597_attack.info_pool[effectScript.ID].AttackType, H015_auto597_attack.info_pool[effectScript.ID].AttackDataList, H015_auto597_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
