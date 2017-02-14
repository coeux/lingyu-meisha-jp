S723_magic_H037_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S723_magic_H037_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S723_magic_H037_attack.info_pool[effectScript.ID].Attacker)
        
		S723_magic_H037_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S722_1")
		PreLoadSound("skill_03704")
		PreLoadAvatar("S722_2")
		PreLoadSound("skill_03703")
		PreLoadSound("stalk_03701")
		PreLoadAvatar("S722_3")
		PreLoadAvatar("S722_4")
		PreLoadSound("skill_03702")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgfhjh" )
		effectScript:RegisterEvent( 11, "sfdsg" )
		effectScript:RegisterEvent( 23, "dgfhjj" )
		effectScript:RegisterEvent( 33, "sfsghhh" )
		effectScript:RegisterEvent( 38, "dfggg" )
		effectScript:RegisterEvent( 39, "dfgggs" )
	end,

	ddgfhjh = function( effectScript )
		SetAnimation(S723_magic_H037_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	sfdsg = function( effectScript )
		AttachAvatarPosEffect(false, S723_magic_H037_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S722_1")
		PlaySound("skill_03704")
	end,

	dgfhjj = function( effectScript )
		AttachAvatarPosEffect(false, S723_magic_H037_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -10), 1, 100, "S722_2")
		PlaySound("skill_03703")
		PlaySound("stalk_03701")
	end,

	sfsghhh = function( effectScript )
		AttachAvatarPosEffect(false, S723_magic_H037_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S722_3")
	end,

	dfggg = function( effectScript )
		AttachAvatarPosEffect(false, S723_magic_H037_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S722_4")
		PlaySound("skill_03702")
	end,

	dfgggs = function( effectScript )
			DamageEffect(S723_magic_H037_attack.info_pool[effectScript.ID].Attacker, S723_magic_H037_attack.info_pool[effectScript.ID].Targeter, S723_magic_H037_attack.info_pool[effectScript.ID].AttackType, S723_magic_H037_attack.info_pool[effectScript.ID].AttackDataList, S723_magic_H037_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
