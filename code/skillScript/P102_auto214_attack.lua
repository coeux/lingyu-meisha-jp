P102_auto214_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_auto214_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_auto214_attack.info_pool[effectScript.ID].Attacker)
       	if P102_auto214_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(P102_auto214_attack.info_pool[effectScript.ID].Effect1);P102_auto214_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		P102_auto214_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0171")
		PreLoadAvatar("S212_3")
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "dsfdsf" )
		effectScript:RegisterEvent( 18, "adsad" )
		effectScript:RegisterEvent( 19, "dsfd" )
		effectScript:RegisterEvent( 20, "sfdf" )
		effectScript:RegisterEvent( 21, "s" )
	end,

	a = function( effectScript )
		SetAnimation(P102_auto214_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0171")
	end,

	dsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, P102_auto214_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 80), 1.5, 100, "S212_3")
	end,

	adsad = function( effectScript )
		P102_auto214_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P102_auto214_attack.info_pool[effectScript.ID].Attacker, Vector2(130, -30), 3, 1000, 300, 1.5, P102_auto214_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S212_1", effectScript)
	end,

	dsfd = function( effectScript )
		if P102_auto214_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(P102_auto214_attack.info_pool[effectScript.ID].Effect1);P102_auto214_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, P102_auto214_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S212_2")
	end,

	s = function( effectScript )
			DamageEffect(P102_auto214_attack.info_pool[effectScript.ID].Attacker, P102_auto214_attack.info_pool[effectScript.ID].Targeter, P102_auto214_attack.info_pool[effectScript.ID].AttackType, P102_auto214_attack.info_pool[effectScript.ID].AttackDataList, P102_auto214_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
