S810_magic_H046_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S810_magic_H046_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S810_magic_H046_attack.info_pool[effectScript.ID].Attacker)
        
		S810_magic_H046_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S810_1")
		PreLoadSound("skill_04602")
		PreLoadAvatar("S810_2")
		PreLoadSound("skill_04601")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgfdhh" )
		effectScript:RegisterEvent( 11, "dgfdgfjh" )
		effectScript:RegisterEvent( 29, "fdgfjkk" )
		effectScript:RegisterEvent( 31, "sdfdhfhj" )
	end,

	dsgfdhh = function( effectScript )
		SetAnimation(S810_magic_H046_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dgfdgfjh = function( effectScript )
		AttachAvatarPosEffect(false, S810_magic_H046_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 122), 1.2, 100, "S810_1")
		PlaySound("skill_04602")
	end,

	fdgfjkk = function( effectScript )
		AttachAvatarPosEffect(false, S810_magic_H046_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 65), -1.3, 100, "S810_2")
		PlaySound("skill_04601")
	end,

	sdfdhfhj = function( effectScript )
			DamageEffect(S810_magic_H046_attack.info_pool[effectScript.ID].Attacker, S810_magic_H046_attack.info_pool[effectScript.ID].Targeter, S810_magic_H046_attack.info_pool[effectScript.ID].AttackType, S810_magic_H046_attack.info_pool[effectScript.ID].AttackDataList, S810_magic_H046_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
