import '../models/quiz_model.dart';
import '../models/game_state.dart';

/// Banco de preguntas centralizado para todos los biomas.
/// Cada bioma tiene 5 preguntas educativas sobre ecosistemas de México.
class QuestionBank {
  static const String _mascotImage = 'assets/images/eco_ajolote_mascot.png';
  static const String _jaguarImage = 'assets/images/quiz_jaguar_1778457575331.png';
  static const String _turtleImage = 'assets/images/quiz_turtle_1778463514370.png';
  static const String _butterflyImage = 'assets/images/quiz_butterfly_1778463527262.png';
  static const String _toucanImage = 'assets/images/quiz_toucan_1778462119800.png';
  static const String _foxImage = 'assets/images/quiz_fox_1778463541718.png';

  /// Devuelve las preguntas para un bioma dado por su ID.
  /// Los biomas 0-5 son los originales. Para IDs mayores, se buscan las
  /// preguntas personalizadas del profesor en GameState.
  static List<QuizQuestion> getForBiome(int biomeId) {
    switch (biomeId) {
      case 0:
        return _ciudadQuestions;
      case 1:
        return _manglarQuestions;
      case 2:
        return _arrecifeQuestions;
      case 3:
        return _bosqueQuestions;
      case 4:
        return _selvaQuestions;
      case 5:
        return _desiertoQuestions;
      default:
        // Buscar preguntas personalizadas del profesor
        return _getCustomOrGeneric(biomeId);
    }
  }

  /// Busca las preguntas del nivel personalizado en GameState.
  /// Si el profesor no creó preguntas, devuelve las genéricas.
  static List<QuizQuestion> _getCustomOrGeneric(int biomeId) {
    final levels = GameState.instance.levels.value;
    final matchIndex = levels.indexWhere((l) => l.id == biomeId);
    if (matchIndex != -1 && levels[matchIndex].questions.isNotEmpty) {
      return levels[matchIndex].questions;
    }
    return _genericQuestions(biomeId);
  }


  // ── Bioma 0: Ciudad y Medio Ambiente ──────────────────────────────
  static final List<QuizQuestion> _ciudadQuestions = [
    QuizQuestion(
      questionText: '¿Cuál es la regla de las 3 R para cuidar el medio ambiente?',
      imageAssetPath: _mascotImage,
      options: ['Robar, Romper, Reír', 'Reducir, Reutilizar, Reciclar', 'Rápido, Ruidoso, Raro'],
      correctOptionIndex: 1,
      hint: 'Son acciones para generar menos basura.',
      funFact: 'Reciclar una lata de aluminio ahorra suficiente energía para encender una TV por 3 horas.',
    ),
    QuizQuestion(
      questionText: '¿Cuánto tarda en degradarse una botella de plástico en la naturaleza?',
      imageAssetPath: _mascotImage,
      options: ['1 mes', '10 años', 'Hasta 500 años'],
      correctOptionIndex: 2,
      hint: 'Es muchísimo tiempo... más que la vida de tus abuelos.',
      funFact: 'Cada año se producen 500 mil millones de botellas de plástico en el mundo. ¡Usa tu botella reutilizable!',
    ),
    QuizQuestion(
      questionText: '¿Qué tipo de energía producen los paneles solares?',
      imageAssetPath: _mascotImage,
      options: ['Energía del viento', 'Energía limpia del Sol', 'Energía de la basura'],
      correctOptionIndex: 1,
      hint: 'Tienen que ver con la estrella más brillante del cielo.',
      funFact: 'México es uno de los países con más radiación solar del mundo. ¡En el desierto de Sonora hay enormes parques solares!',
    ),
    QuizQuestion(
      questionText: '¿Qué es la contaminación del aire que se ve como una nube gris sobre la ciudad?',
      imageAssetPath: _mascotImage,
      options: ['Niebla marina', 'Smog', 'Vapor de agua'],
      correctOptionIndex: 1,
      hint: 'Su nombre combina las palabras "smoke" (humo) y "fog" (niebla) en inglés.',
      funFact: 'La Ciudad de México fue una de las ciudades más contaminadas del mundo, pero gracias a programas como "Hoy No Circula" ha mejorado mucho.',
    ),
    QuizQuestion(
      questionText: '¿Cuál es la mejor manera de ahorrar agua en casa?',
      imageAssetPath: _mascotImage,
      options: ['Dejar la llave abierta', 'Cerrar la llave mientras te lavas los dientes', 'Usar más agua caliente'],
      correctOptionIndex: 1,
      hint: 'Piensa en lo que haces cuando te cepillas los dientes por la mañana.',
      funFact: 'Si cierras la llave mientras te lavas los dientes, ahorras hasta 12 litros de agua cada vez. ¡Eso llena 24 botellas!',
    ),
  ];

  // ── Bioma 1: Manglar ──────────────────────────────────────────────
  static final List<QuizQuestion> _manglarQuestions = [
    QuizQuestion(
      questionText: '¿Qué característica especial tienen los árboles del manglar?',
      imageAssetPath: _mascotImage,
      options: ['Crecen en la nieve', 'Sus raíces crecen en agua salada', 'No necesitan agua'],
      correctOptionIndex: 1,
      hint: 'Viven donde se junta el río con el mar.',
      funFact: 'Los manglares protegen las costas de los huracanes como si fueran escudos naturales.',
    ),
    QuizQuestion(
      questionText: '¿Qué ave de color rosa vive en los manglares de Yucatán?',
      imageAssetPath: _mascotImage,
      options: ['Colibrí', 'Flamenco', 'Loro'],
      correctOptionIndex: 1,
      hint: 'Su color se debe a los camarones que come.',
      funFact: 'Los flamencos del Caribe obtienen su color rosa de los pigmentos de los pequeños camarones que comen. ¡Si dejaran de comerlos se volverían blancos!',
    ),
    QuizQuestion(
      questionText: '¿Por qué los manglares son tan importantes para los peces?',
      imageAssetPath: _mascotImage,
      options: ['Les dan sombra del sol', 'Son la guardería donde nacen y crecen', 'Los pintan de colores'],
      correctOptionIndex: 1,
      hint: 'Muchos peces bebés crecen protegidos entre las raíces.',
      funFact: 'El 75% de los peces que se pescan en México pasaron su infancia en un manglar. ¡Sin manglares no habría pesca!',
    ),
    QuizQuestion(
      questionText: '¿Qué reptil grande vive en los manglares de Veracruz y Tabasco?',
      imageAssetPath: _mascotImage,
      options: ['Iguana marina', 'Cocodrilo', 'Tortuga gigante'],
      correctOptionIndex: 1,
      hint: 'Es un reptil con una mordida muy poderosa y muchos dientes.',
      funFact: 'El cocodrilo de pantano mexicano puede medir hasta 3.5 metros. A pesar de su tamaño, es muy importante para mantener sanos los manglares.',
    ),
    QuizQuestion(
      questionText: '¿Qué pasa cuando se destruye un manglar?',
      imageAssetPath: _mascotImage,
      options: ['No pasa nada', 'Las costas quedan desprotegidas de tormentas', 'Llueve más'],
      correctOptionIndex: 1,
      hint: 'Los manglares funcionan como un muro natural contra el mar.',
      funFact: 'México ha perdido más del 10% de sus manglares. Por eso existen leyes que los protegen como ecosistemas prioritarios.',
    ),
  ];

  // ── Bioma 2: Arrecife de Coral ────────────────────────────────────
  static final List<QuizQuestion> _arrecifeQuestions = [
    QuizQuestion(
      questionText: '¿Los corales del arrecife son plantas o animales?',
      imageAssetPath: _turtleImage,
      options: ['Plantas', 'Animales', 'Piedras de colores'],
      correctOptionIndex: 1,
      hint: 'Aunque no se mueven de lugar, están vivos y comen plancton.',
      funFact: 'Los corales son en realidad animales diminutos llamados pólipos que construyen grandes esqueletos de calcio.',
    ),
    QuizQuestion(
      questionText: '¿Cuál es el arrecife de coral más grande de México?',
      imageAssetPath: _turtleImage,
      options: ['Arrecife de Cozumel', 'Arrecife Mesoamericano', 'Arrecife del Pacífico'],
      correctOptionIndex: 1,
      hint: 'Se extiende desde Quintana Roo hasta Honduras.',
      funFact: 'El Arrecife Mesoamericano es el segundo más grande del mundo, después de la Gran Barrera de Coral de Australia. ¡Mide más de 1,000 km!',
    ),
    QuizQuestion(
      questionText: '¿Cuál es el pez más grande del mundo que visita los arrecifes de México?',
      imageAssetPath: _turtleImage,
      options: ['Delfín', 'Tiburón ballena', 'Pez payaso'],
      correctOptionIndex: 1,
      hint: 'Tiene el nombre de dos animales juntos y es enorme pero inofensivo.',
      funFact: 'El tiburón ballena puede medir hasta 12 metros, ¡como un camión! A pesar de su tamaño, solo come plancton y es totalmente inofensivo.',
    ),
    QuizQuestion(
      questionText: '¿Qué le pasa a los corales cuando el agua del mar se calienta demasiado?',
      imageAssetPath: _turtleImage,
      options: ['Crecen más rápido', 'Se ponen blancos y pueden morir', 'Se vuelven más fuertes'],
      correctOptionIndex: 1,
      hint: 'El calentamiento global es un problema para ellos.',
      funFact: 'Cuando los corales se estresan por el calor, expulsan las algas que les dan color y se ponen blancos. Esto se llama "blanqueamiento" y puede matarlos.',
    ),
    QuizQuestion(
      questionText: '¿Qué tortuga marina pone sus huevos en las playas de Quintana Roo?',
      imageAssetPath: _turtleImage,
      options: ['Tortuga caguama', 'Tortuga mordedora', 'Tortuga de orejas rojas'],
      correctOptionIndex: 0,
      hint: 'Es una tortuga marina que viaja miles de kilómetros para volver a la playa donde nació.',
      funFact: 'Las tortugas caguama pueden viajar más de 12,000 km para volver a la misma playa donde nacieron. ¡Tienen un GPS natural en su cerebro!',
    ),
  ];

  // ── Bioma 3: Bosque de Pinos ──────────────────────────────────────
  static final List<QuizQuestion> _bosqueQuestions = [
    QuizQuestion(
      questionText: '¿Qué asombroso animal migra miles de kilómetros hacia los bosques de México?',
      imageAssetPath: _butterflyImage,
      options: ['Oso pardo', 'Mariposa Monarca', 'Pingüino Emperador'],
      correctOptionIndex: 1,
      hint: 'Es un insecto volador de color naranja y negro.',
      funFact: 'La mariposa monarca viaja desde Canadá hasta los bosques de Michoacán cada invierno. ¡Recorre más de 4,000 km!',
    ),
    QuizQuestion(
      questionText: '¿En qué estado de México llegan las mariposas monarca cada invierno?',
      imageAssetPath: _butterflyImage,
      options: ['Sonora', 'Michoacán', 'Quintana Roo'],
      correctOptionIndex: 1,
      hint: 'Es famoso por sus bosques de oyamel y su deliciosa gastronomía.',
      funFact: 'Los bosques de oyamel en Michoacán se llenan de millones de mariposas monarca entre noviembre y marzo. ¡Los árboles se ven completamente anaranjados!',
    ),
    QuizQuestion(
      questionText: '¿Qué producen los bosques que nosotros necesitamos para respirar?',
      imageAssetPath: _butterflyImage,
      options: ['Dióxido de carbono', 'Oxígeno', 'Humo'],
      correctOptionIndex: 1,
      hint: 'Los árboles absorben CO₂ y liberan algo que respiramos.',
      funFact: 'Un solo árbol grande produce suficiente oxígeno para que respiren 4 personas durante un año entero.',
    ),
    QuizQuestion(
      questionText: '¿Qué animal único en el mundo vive en los lagos de Xochimilco, México?',
      imageAssetPath: _mascotImage,
      options: ['Ajolote', 'Delfín rosa', 'Pez globo'],
      correctOptionIndex: 0,
      hint: '¡Es la mascota de EcoQuiz! Tiene branquias externas como plumas en su cabeza.',
      funFact: 'El ajolote puede regenerar sus patas, cola, corazón e incluso partes de su cerebro. ¡Los científicos lo estudian para aprender sobre la regeneración!',
    ),
    QuizQuestion(
      questionText: '¿Qué tipo de árboles predominan en los bosques templados de México?',
      imageAssetPath: _butterflyImage,
      options: ['Palmeras', 'Pinos y encinos', 'Cactus gigantes'],
      correctOptionIndex: 1,
      hint: 'Son árboles que no pierden sus hojas en invierno y huelen muy bien.',
      funFact: 'México tiene más de 50 especies de pinos, más que cualquier otro país del mundo. ¡Somos la capital mundial de los pinos!',
    ),
  ];

  // ── Bioma 4: Selva Tropical ───────────────────────────────────────
  static final List<QuizQuestion> _selvaQuestions = [
    QuizQuestion(
      questionText: '¿Cuál de estos felinos vive en la selva mexicana y sabe nadar muy bien?',
      imageAssetPath: _jaguarImage,
      options: ['Jaguar', 'León africano', 'Gato doméstico'],
      correctOptionIndex: 0,
      hint: 'Tiene hermosas manchas llamadas rosetas en su piel.',
      funFact: 'El jaguar es el felino más grande de toda América y el tercero más grande del mundo, después del tigre y el león.',
    ),
    QuizQuestion(
      questionText: '¿Qué ave de la selva tiene un pico enorme y muy colorido?',
      imageAssetPath: _toucanImage,
      options: ['Águila real', 'Tucán', 'Golondrina'],
      correctOptionIndex: 1,
      hint: 'Su pico puede ser tan largo como su cuerpo y tiene colores brillantes.',
      funFact: 'El pico del tucán es hueco por dentro y le sirve para regular su temperatura corporal. ¡Es como un radiador natural!',
    ),
    QuizQuestion(
      questionText: '¿Qué ave sagrada de los mayas tiene plumas verdes brillantes?',
      imageAssetPath: _mascotImage,
      options: ['Colibrí', 'Quetzal', 'Guacamaya'],
      correctOptionIndex: 1,
      hint: 'Los mayas la consideraban el ave más hermosa y sagrada de todas.',
      funFact: 'El quetzal era tan importante para los mayas que usaban sus plumas como moneda. Arrancárselas era un crimen castigado con la muerte.',
    ),
    QuizQuestion(
      questionText: '¿Por qué llueve tanto en la selva tropical?',
      imageAssetPath: _jaguarImage,
      options: ['Porque tiene muchos ríos', 'Por el calor y la humedad que forman nubes', 'Porque está cerca del polo norte'],
      correctOptionIndex: 1,
      hint: 'El aire caliente sube y forma muchas nubes de lluvia.',
      funFact: 'La Selva Lacandona de Chiapas recibe hasta 3,000 mm de lluvia al año. ¡Eso es como llenar una alberca de 3 metros de profundidad!',
    ),
    QuizQuestion(
      questionText: '¿Qué árbol gigante es conocido como el "árbol de la vida" en la selva maya?',
      imageAssetPath: _mascotImage,
      options: ['Manzano', 'Ceiba', 'Sauce llorón'],
      correctOptionIndex: 1,
      hint: 'Los mayas creían que conectaba el cielo con el inframundo.',
      funFact: 'La ceiba puede crecer hasta 70 metros de alto. Los mayas la consideraban sagrada y jamás la cortaban. ¡Es el árbol nacional de Guatemala!',
    ),
  ];

  // ── Bioma 5: Desierto ─────────────────────────────────────────────
  static final List<QuizQuestion> _desiertoQuestions = [
    QuizQuestion(
      questionText: '¿Dónde almacenan el agua los cactus para sobrevivir en el desierto?',
      imageAssetPath: _foxImage,
      options: ['En sus flores', 'En sus raíces', 'En sus gruesos tallos verdes'],
      correctOptionIndex: 2,
      hint: 'Es la parte grande, verde y carnosa de la planta.',
      funFact: '¡Un cactus gigante llamado Saguaro puede almacenar hasta 5,000 litros de agua en su interior!',
    ),
    QuizQuestion(
      questionText: '¿Por qué muchos animales del desierto salen de noche y duermen de día?',
      imageAssetPath: _foxImage,
      options: ['Porque les gusta la luna', 'Para evitar el calor extremo del día', 'Porque son tímidos'],
      correctOptionIndex: 1,
      hint: 'Durante el día la temperatura puede llegar a más de 50°C.',
      funFact: 'En el desierto de Sonora, la temperatura puede llegar a 50°C de día y bajar hasta 0°C en la noche. ¡Una diferencia de 50 grados!',
    ),
    QuizQuestion(
      questionText: '¿Qué ave aparece en el escudo de la bandera de México?',
      imageAssetPath: _mascotImage,
      options: ['Colibrí', 'Águila real', 'Halcón peregrino'],
      correctOptionIndex: 1,
      hint: 'Está parada sobre un nopal devorando una serpiente.',
      funFact: 'El águila real puede volar a velocidades de hasta 300 km/h cuando se lanza en picada. ¡Es una de las aves más rápidas del mundo!',
    ),
    QuizQuestion(
      questionText: '¿Cómo se protege el armadillo cuando se siente en peligro?',
      imageAssetPath: _mascotImage,
      options: ['Corre muy rápido', 'Se enrolla en una bola con su caparazón', 'Escupe veneno'],
      correctOptionIndex: 1,
      hint: 'Tiene una armadura natural hecha de placas duras.',
      funFact: 'El armadillo de nueve bandas es el único animal además del humano que puede contraer lepra. ¡Por eso los científicos los estudian para encontrar curas!',
    ),
    QuizQuestion(
      questionText: '¿Qué es un oasis en el desierto?',
      imageAssetPath: _foxImage,
      options: ['Una tormenta de arena', 'Un lugar con agua y vegetación en medio del desierto', 'Un tipo de cactus'],
      correctOptionIndex: 1,
      hint: 'Es como un pequeño paraíso verde donde los viajeros pueden beber agua.',
      funFact: 'En Baja California Sur existe un oasis real llamado San Ignacio con más de 80,000 palmeras. ¡Los misioneros lo descubrieron hace 300 años!',
    ),
  ];

  /// Preguntas genéricas para niveles dinámicos creados por el maestro.
  static List<QuizQuestion> _genericQuestions(int biomeId) {
    return [
      const QuizQuestion(
        questionText: '¿Qué son los ecosistemas?',
        imageAssetPath: _mascotImage,
        options: ['Tipos de robots', 'Comunidades de seres vivos y su entorno', 'Ciudades grandes'],
        correctOptionIndex: 1,
        hint: 'Incluyen a todos los seres vivos y el lugar donde habitan.',
        funFact: 'México es uno de los 17 países megadiversos del mundo. ¡Tenemos casi todos los tipos de ecosistemas que existen!',
      ),
      const QuizQuestion(
        questionText: '¿Qué significa que un animal esté en peligro de extinción?',
        imageAssetPath: _mascotImage,
        options: ['Que es muy peligroso', 'Que quedan muy pocos y podrían desaparecer', 'Que vive en un zoológico'],
        correctOptionIndex: 1,
        hint: 'Es una situación muy seria para la especie.',
        funFact: 'México tiene más de 2,500 especies en alguna categoría de riesgo. El ajolote, el jaguar y la vaquita marina son algunas de ellas.',
      ),
      const QuizQuestion(
        questionText: '¿Qué es la biodiversidad?',
        imageAssetPath: _mascotImage,
        options: ['Un tipo de planta', 'La variedad de seres vivos en un lugar', 'Una marca de ropa'],
        correctOptionIndex: 1,
        hint: '"Bio" significa vida y "diversidad" significa variedad.',
        funFact: 'México ocupa el 5° lugar mundial en biodiversidad. ¡Tenemos más de 200,000 especies diferentes de plantas y animales!',
      ),
      const QuizQuestion(
        questionText: '¿Cuál es la cadena alimenticia correcta?',
        imageAssetPath: _mascotImage,
        options: ['Águila → Ratón → Pasto', 'Pasto → Ratón → Águila', 'Ratón → Águila → Pasto'],
        correctOptionIndex: 1,
        hint: 'Empieza con las plantas que producen su propio alimento.',
        funFact: 'Si desaparece un eslabón de la cadena alimenticia, todos los demás se ven afectados. ¡Por eso cada especie es importante!',
      ),
      const QuizQuestion(
        questionText: '¿Qué podemos hacer para cuidar los ecosistemas de México?',
        imageAssetPath: _mascotImage,
        options: ['No tirar basura en la naturaleza', 'Construir más edificios', 'Cazar animales salvajes'],
        correctOptionIndex: 0,
        hint: 'Es la acción más sencilla que puedes hacer todos los días.',
        funFact: 'Cada mexicano produce en promedio 1.2 kg de basura al día. Si todos recicláramos, salvaríamos miles de árboles y animales cada año.',
      ),
    ];
  }
}
