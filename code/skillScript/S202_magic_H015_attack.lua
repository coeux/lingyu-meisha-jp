S202_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H015_attack.info_pool[effectScript.ID].Attacker)
        
		S202_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01504")
		PreLoadSound("skill_01501")
		PreLoadSound("stalk_01501")
		PreLoadAvatar("S202_1")
		PreLoadSound("skill_01503")
		PreLoadAvatar("S202_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 8, "dfgdfh" )
		effectScript:RegisterEvent( 45, "B" )
		effectScript:RegisterEvent( 60, "dsgfdh" )
		effectScript:RegisterEvent( 64, "x" )
		effectScript:RegisterEvent( 65, "sdfdg" )
		effectScript:RegisterEvent( 67, "dsdgfg" )
		effectScript:RegisterEvent( 69, "v" )
	end,

	a = function( effectScript )
		SetAnimation(S202_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dfgdfh = function( effectScript )
			PlaySound("skill_01504")
	end,

	B = function( effectScript )
		SetAnimation(S202_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsgfdh = function( effectScript )
			PlaySound("skill_01501")
		PlaySound("stalk_01501")
	end,

	x = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H015_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 70), 1.2, 100, "S202_1")
	end,

	sdfdg = function( effectScript )
			PlaySound("skill_01503")
	end,

	dsdgfg = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H015_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S202_2")
	end,

	v = function( effectScript )
			DamageEffect(S202_magic_H015_attack.info_pool[effectScript.ID].Attacker, S202_magic_H015_attack.info_pool[effectScript.ID].Targeter, S202_magic_H015_attack.info_pool[effectScript.ID].AttackType, S202_magic_H015_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
