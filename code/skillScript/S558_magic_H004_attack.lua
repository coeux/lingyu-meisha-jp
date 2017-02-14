S558_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S558_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S558_magic_H004_attack.info_pool[effectScript.ID].Attacker)
        
		S558_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0401")
		PreLoadSound("skill_0401")
		PreLoadSound("skill_0402")
		PreLoadAvatar("S310")
		PreLoadSound("skill_0402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safvzx" )
		effectScript:RegisterEvent( 21, "sfdh" )
		effectScript:RegisterEvent( 27, "dgfdjh" )
		effectScript:RegisterEvent( 28, "sfdg" )
		effectScript:RegisterEvent( 30, "s" )
		effectScript:RegisterEvent( 32, "dsfdh" )
		effectScript:RegisterEvent( 34, "dsgdfhg" )
	end,

	safvzx = function( effectScript )
		SetAnimation(S558_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0401")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_0401")
	end,

	dgfdjh = function( effectScript )
			PlaySound("skill_0402")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S558_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 200), 1.5, 100, "S310")
	end,

	s = function( effectScript )
			DamageEffect(S558_magic_H004_attack.info_pool[effectScript.ID].Attacker, S558_magic_H004_attack.info_pool[effectScript.ID].Targeter, S558_magic_H004_attack.info_pool[effectScript.ID].AttackType, S558_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S558_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_0402")
	end,

	dsgdfhg = function( effectScript )
			DamageEffect(S558_magic_H004_attack.info_pool[effectScript.ID].Attacker, S558_magic_H004_attack.info_pool[effectScript.ID].Targeter, S558_magic_H004_attack.info_pool[effectScript.ID].AttackType, S558_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S558_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
