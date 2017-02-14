H056_auto915_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H056_auto915_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H056_auto915_attack.info_pool[effectScript.ID].Attacker)
        
		H056_auto915_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H056_3_2")
		PreLoadSound("stalk_05601")
		PreLoadSound("skill_05601")
		PreLoadAvatar("H056_3_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjv" )
		effectScript:RegisterEvent( 18, "vbd" )
		effectScript:RegisterEvent( 19, "scv" )
		effectScript:RegisterEvent( 21, "cfvr" )
	end,

	hjv = function( effectScript )
		SetAnimation(H056_auto915_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vbd = function( effectScript )
		AttachAvatarPosEffect(false, H056_auto915_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 1.4, 100, "H056_3_2")
		PlaySound("stalk_05601")
		PlaySound("skill_05601")
	end,

	scv = function( effectScript )
		AttachAvatarPosEffect(false, H056_auto915_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.1, 100, "H056_3_1")
	end,

	cfvr = function( effectScript )
			DamageEffect(H056_auto915_attack.info_pool[effectScript.ID].Attacker, H056_auto915_attack.info_pool[effectScript.ID].Targeter, H056_auto915_attack.info_pool[effectScript.ID].AttackType, H056_auto915_attack.info_pool[effectScript.ID].AttackDataList, H056_auto915_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
