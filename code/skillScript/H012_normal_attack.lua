H012_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H012_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H012_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H012_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01201")
		PreLoadAvatar("H012_pugong_1")
		PreLoadSound("attack_01201")
		PreLoadSound("skill_01204")
		PreLoadSound("skill_01204")
		PreLoadAvatar("H012_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 19, "f" )
		effectScript:RegisterEvent( 20, "tuti" )
		effectScript:RegisterEvent( 23, "sfds" )
		effectScript:RegisterEvent( 25, "fdhgf" )
		effectScript:RegisterEvent( 27, "fsdh" )
		effectScript:RegisterEvent( 28, "g" )
		effectScript:RegisterEvent( 29, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H012_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_01201")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, H012_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H012_pugong_1")
	end,

	tuti = function( effectScript )
			PlaySound("attack_01201")
	end,

	sfds = function( effectScript )
			PlaySound("skill_01204")
	end,

	fdhgf = function( effectScript )
	end,

	fsdh = function( effectScript )
			PlaySound("skill_01204")
	end,

	g = function( effectScript )
		AttachAvatarPosEffect(false, H012_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.2, 100, "H012_pugong_2")
	end,

	ss = function( effectScript )
			DamageEffect(H012_normal_attack.info_pool[effectScript.ID].Attacker, H012_normal_attack.info_pool[effectScript.ID].Targeter, H012_normal_attack.info_pool[effectScript.ID].AttackType, H012_normal_attack.info_pool[effectScript.ID].AttackDataList, H012_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
