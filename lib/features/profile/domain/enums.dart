//todo Escalar emocionalmente acá. mantener actualizado. este el core emocional de la app, y es importante que esté bien definido.
//Regla general: los $1 de las tuplas del onboarding screen son exactamente lo que se guarda en Supabase,
// y deben coincidir carácter a carácter con los case del parser — sin tildes si el parser no las tiene, y viceversa. 
//Elige una convención (yo recomiendo sin tildes, todo lowercase) y aplícala en ambos lados.
enum EmotionalState {
  abrumado,
  nublado,
  agotado,
  inspirado,
}

enum PainPoint {
  estres,
  vacio,
  confusion,
  cansancio,
}

enum HopefulGoal {
  paz,
  orden,
  companero,
  crecimiento,
}
