S912_magic_H056_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S912_magic_H056_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S912_magic_H056_attack.info_pool[effectScript.ID].Attacker)
        
		S912_magic_H056_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05603")
		PreLoadAvatar("H056_3_2")
		PreLoadSound("skill_05601")
		PreLoadSound("stalk_05601")
		PreLoadAvatar("H056_3_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjv" )
		effectScript:RegisterEvent( 18, "vbd" )
		effectScript:RegisterEvent( 19, "scv" )
		effectScript:RegisterEvent( 21, "cfvr" )
	end,

	hjv = function( effectScript )
		SetAnimation(S912_magic_H056_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_05603")
	end,

	vbd = function( effectScript )
		AttachAvatarPosEffect(false, S912_magic_H056_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 1.4, 100, "H056_3_2")
		PlaySound("skill_05601")
		PlaySound("stalk_05601")
	end,

	scv = function( effectScript )
		AttachAvatarPosEffect(false, S912_magic_H056_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.1, 100, "H056_3_1")
	end,

	cfvr = function( effectScript )
			DamageEffect(S912_magic_H056_attack.info_pool[effectScript.ID].Attacker, S912_magic_H056_attack.info_pool[effectScript.ID].Targeter, S912_magic_H056_attack.info_pool[effectScript.ID].AttackType, S912_magic_H056_attack.info_pool[effectScript.ID].AttackDataList, S912_magic_H056_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
