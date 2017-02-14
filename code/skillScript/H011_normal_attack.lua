H011_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H011_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H011_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H011_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H011_normal_attack.info_pool[effectScript.ID].Effect1);H011_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H011_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01101")
		PreLoadAvatar("shifang")
		PreLoadSound("attack_01101")
		PreLoadAvatar("jjpugong")
		PreLoadAvatar("jjshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 24, "dd" )
		effectScript:RegisterEvent( 27, "f" )
		effectScript:RegisterEvent( 28, "g" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 30, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H011_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_01101")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H011_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 85), 2, 100, "shifang")
		PlaySound("attack_01101")
	end,

	f = function( effectScript )
		H011_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H011_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 60), 2, 1200, 300, 1.5, H011_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), "jjpugong", effectScript)
	end,

	g = function( effectScript )
		if H011_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H011_normal_attack.info_pool[effectScript.ID].Effect1);H011_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H011_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -3, 100, "jjshouji")
	end,

	ss = function( effectScript )
			DamageEffect(H011_normal_attack.info_pool[effectScript.ID].Attacker, H011_normal_attack.info_pool[effectScript.ID].Targeter, H011_normal_attack.info_pool[effectScript.ID].AttackType, H011_normal_attack.info_pool[effectScript.ID].AttackDataList, H011_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
