S793_magic_H044_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S793_magic_H044_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S793_magic_H044_attack.info_pool[effectScript.ID].Attacker)
        
		S793_magic_H044_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S792_3")
		PreLoadSound("skill_04401")
		PreLoadAvatar("S792_2")
		PreLoadSound("skill_04402")
		PreLoadAvatar("S792_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdgfhjj" )
		effectScript:RegisterEvent( 11, "dsfdgfhj" )
		effectScript:RegisterEvent( 32, "dgfhgjghjhg" )
		effectScript:RegisterEvent( 34, "fdghfjhkj" )
		effectScript:RegisterEvent( 35, "sddfdh" )
	end,

	sdfdgfhjj = function( effectScript )
		SetAnimation(S793_magic_H044_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsfdgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S793_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 200), 1.5, 100, "S792_3")
		PlaySound("skill_04401")
	end,

	dgfhgjghjhg = function( effectScript )
		AttachAvatarPosEffect(false, S793_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 30), 1.5, 100, "S792_2")
		PlaySound("skill_04402")
	end,

	fdghfjhkj = function( effectScript )
		AttachAvatarPosEffect(false, S793_magic_H044_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S792_1")
	end,

	sddfdh = function( effectScript )
			DamageEffect(S793_magic_H044_attack.info_pool[effectScript.ID].Attacker, S793_magic_H044_attack.info_pool[effectScript.ID].Targeter, S793_magic_H044_attack.info_pool[effectScript.ID].AttackType, S793_magic_H044_attack.info_pool[effectScript.ID].AttackDataList, S793_magic_H044_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
