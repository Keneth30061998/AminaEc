import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/user.dart';

class PdfService {
  static Future<File> generatePdfWithSignature({
    required Uint8List signatureBytes,
    required User user,
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(signatureBytes);

    const String longText = '''
Mediante la inscripción a AMINA y/o asistiendo a clases, eventos, actividades y otros programas, así como por el uso de las instalaciones y el equipo ("Clases" y/o "Instalaciones") de MARIA VERONICA NAVAS FLORES con RUC 1722856745001, por la presente reconozco que existen ciertos riesgos y peligros inherentes al uso y práctica de cualquier ejercicio físico y en específico en este caso, a la práctica de fuerza, cardio y flexibilidad. Conozco la naturaleza de las clases impartidas por AMINA, así como las capacidades físicas y experiencias con las que se me recomienda contar, manifestando que las mismas son idóneas para participar en las "Clases" y/o "Instalaciones". Debido a lo anterior, expresamente manifiesto que no cuento con un historial de enfermedades ni lesiones, ni estoy usando actualmente ninguna substancia, medicina, droga o alcohol, que pudiera limitar mis habilidades o perjudicar mi desempeño y/o salud al momento o después de realizar ejercicio físico. También reconozco que los riesgos específicos varían de una actividad a otra, mismos que podrían ser (a) lesiones menores como: (1) rasguños; y (2) golpes y torceduras; (b) lesiones mayores como (1) lesiones en las articulaciones o la espalda; (2) ataques cardíacos; y (3o) contusiones; y (c) lesiones graves, incluyendo parálisis, y muerte; conjuntamente "Los Riesgos", por lo que expresamente reconozco y acepto que dichos riesgos no pueden ser eliminados por AMINA. Los Riesgos pueden ser provocados por propia omisión, actividad o inactividad antes, durante o posterior a cualquiera de las clases impartidas en las instalaciones de AMINA, así como también por la omisión, actividad o inactividad de otros asistentes a las Clases y/o Instalaciones de AMINA, por el uso de los equipos o instalaciones sin la debida precaución o sin seguir las indicaciones impartidas. Reconozco y acepto expresamente que dichos riesgos son inherentes a las actividades físicas ofrecidas por AMINA y no pueden ser completamente eliminados, incluso cuando exista un nivel razonable y adecuado de cuidado y diligencia por parte de AMINA. Pueden existir otros riesgos no conocidos por AMINA, o que aún no son previsibles o que siendo previsibles son de mi conocimiento, lo reconozco y asumo, o aquellos que se deriven por caso fortuito o fuerza mayor. Las pérdidas económicas y/o daños directos o indirectos que puedan resultar de estos riesgos, pueden ser severos y modificar permanentemente mi futuro. Al reservar y/o tomar una clase de AMINA, usted reconoce y acepta que: (1) asume plena responsabilidad por su estado de salud así como todas y cada una de las lesiones físicas, daños o cualquier enfermedad (viral o bacterial) que pueda sufrir o adquirir al tomar alguna Clase presencial, o al hacer uso de las instalaciones y/o productos de AMINA; (2) libera de cualquier tipo de responsabilidad e indemnización a AMINA, sus entidades afiliadas y/o subsidiarias, y cada uno de sus respectivos representantes legales, directores, managers, miembros del staff, empleados, agentes incluyendo terceros prestadores de servicios y todos los demás aplicables, de cualquier demanda por daños y perjuicios, responsabilidad en otras materias incluyendo materia penal, procedimientos de arbitraje entre otros, costos, gastos, en la máxima medida permitida por la ley aplicable por tomar Clases presenciales, el uso de las instalaciones de AMINA y por la utilización de productos o servicios ofrecidos por AMINA, independientemente de la disciplina o tipo de actividad física realizada; y (3) Acepta y manifiesta que ni usted ni cualquier tercero que tome una clase de AMINA bajo una reservación a su nombre y/o invitación y/o o utilice un producto de AMINA (a) no tiene ninguna condición médica o física que le impida utilizar correctamente cualquiera de las Clases presenciales y/o instalaciones de AMINA, (b) no tiene una condición física o mental que lo ponga en peligro físico o médico a usted y a los demás participantes que se encuentran en las instalaciones de AMINA, y (c) no ha sido instruido o recomendado por un médico para no realizar ejercicio físico. Usted reconoce que, en caso de embarazo, recuperación postoperatoria, o padecimiento de enfermedades crónicas o degenerativas (tales como hipertensión, afecciones cardíacas, diabetes, epilepsia, cáncer, entre otras), la participación en las clases o el uso de las instalaciones de AMINA puede implicar un riesgo significativo para su integridad física y su salud. En consecuencia, declara haber evaluado dicha condición de manera consciente y voluntaria, asumiendo plena responsabilidad por los riesgos que ello conlleve, y eximiendo expresamente a AMINA de cualquier consecuencia o afectación derivada de su decisión de participar, incluso en aquellos casos en que haya recibido indicación médica de abstenerse, reconociendo que dicha participación ocurre por su exclusiva voluntad. He leído y entendido completamente el reglamento interno de AMINA que me fuer proporcionado de forma física por el personal de AMINA y en los medios visibles que se encuentran en las instalaciones. Me comprometo a llegar antes de que inicie la clase, ya que tengo 1 canción de tolerancia para poder entrar. Me comprometo a cumplir con todos los términos y condiciones establecidos en dichos documentos, así como las instrucciones que de tiempo en tiempo el personal de AMINA me proporcione durante el desarrollo de las Clases, o en su caso, con las instrucciones que AMINA ponga en el establecimiento donde se lleven a cabo las Clases. Asimismo, manifiesto que conozco el desarrollo y actividades que llevaré a cabo en cualquiera de las clases de AMINA, por lo que en caso de que el personal de AMINA considere que cualquiera de estas actividades pudiera resultar insegura o representar un riesgo, dicho personal de AMINA podrá prohibirme el acceso a la clase sin responsabilidad alguna para AMINA, pudiendo reagendar la clase para otra fecha. Asimismo, reconozco que el personal de AMINA está debidamente capacitado para emitir dicha opinión, por lo que entiendo y acepto que dicha opinión siempre será tomada en función del resguardo de mi bienestar físico y en atención a principios de prevención y cuidado de la salud. En caso de no tomar en consideración las instrucciones emitidas por el personal de AMINA reconozco y acepto expresamente que asumo las consecuencias que pudieran derivarse de mi omisión, a las instrucciones del personal de AMINA liberando de cualquier responsabilidad a AMINA y sus subsidiarias, y cada uno de sus socios, accionistas, consejeros, funcionarios, directores, empleados, representantes y agentes, y cada uno de sus respectivos sucesores y cesionarios de cualquier y toda responsabilidad, reclamaciones, acciones, demandas, procedimientos, costos, gastos, daños y pasivos, que pudiera originarse como consecuencia de mi incumplimiento a las indicaciones del personal autorizado. En relación con lo anterior, en caso que AMINA me permita tomar las Clases (i) asumo plena responsabilidad por cualquier y todas las lesiones o daños que sufra ((incluyendo, sin limitarse a, lesiones temporales, permanentes o incluso la muerte)) durante o derivado de las Clases, (ii) libero a AMINA y sus subsidiarias, y cada uno de sus socios, accionistas, consejeros, funcionarios, directores, empleados, representantes y agentes, contratistas independientes y cada uno de sus respectivos sucesores y cesionarios de cualquier y toda responsabilidad, reclamaciones, acciones, demandas, procedimientos, costos, gastos, daños y pasivos, ya sean presentes o futuros, conocidos o desconocidos, directos o indirectos; y (iii) manifiesto que al día de la presente (a) no tengo ningún impedimento médico o condición física que me impida tomar las clases o usar correctamente los aparatos mediante los cual se llevan a cabo las Clases; (b) no tengo una condición física o mental que me ponga peligro médico y físico; y (c) no tengo instrucciones médicas que me limiten o restrinjan realizar cualquier tipo de actividad física. Reconozco y acepto que, en caso de tener alguna discapacidad, enfermedad crónica, condición médica degenerativa o de reciente diagnóstico, mi participación en las Clases o uso de las instalaciones representa un riesgo para mi salud e integridad física, el cual asumo bajo mi entera responsabilidad, y que, bajo dichas circunstancias, no debería participar en ninguna Clase. He leído esta declaratoria de aceptación de riesgo, renuncia y liberación de responsabilidad, y deslindo de toda responsabilidad, obligándome a sacar en paz y a salvo a AMINA y/o a todas sus subsidiaras, y a cada uno de sus socios, accionistas, consejeros, funcionarios, directores, empleados representantes uy agentes respecto de toda acción, demanda, responsabilidad de carácter civil o penal derivado de cualquier contingencia, accidente, daño, o cualquier tipo de lesión, enfermedad, fracturas, incapacidad parcial o permanente y/o la muerte que pudiera sufrir el que suscribe por el uso de las Instalaciones de AMINA y/o por las Clases que tome. Reconozco que estoy firmando el presente de manera libre y voluntaria y que la vigencia de esta renuncia es indefinida por lo que continuará valida y vigente durante el tiempo que acuda a las Instalaciones y/o toma clases de AMINA.

VALORES Y BIENES PERSONALES

AMINA no se hará ni será responsable por la pérdida, robo, o daños a cualquier objeto, incluyendo artículos que se guarden en los casilleros, baños, estudios, o cualquier otro lugar en las instalaciones, sin importar si estos se encontraban bajo llave o no, por lo cual se recomienda no perder de vista ni guardar en los casilleros aquellos objetos que pudieran considerarse de valor, tales como, de forma enunciativa mas no limitativa: documentos personales, aparatos electrónicos, joyas o dinero en efectivo.. Asimismo, acepto y reconozco que AMINA se reserva el derecho a denegar el acceso a cualquier persona que AMINA considere que esté actuando de manera inadecuada, agresiva, riesgosa, bajo efectos de alcohol o sustancias prohibidas, o que pongan en riesgo su salud o la salud de los clientes, sin que ello genere responsabilidad ni obligación de reembolso por parte de AMINA. 

''';

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 35, vertical: 40),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Contrato de Registro de Usuario",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text("Datos del Usuario",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Text("Nombre Completo: ${user.name} ${user.lastname}"),
          pw.Text("Correo Electrónico: ${user.email}"),
          pw.Text("Cédula: ${user.ci}"),
          pw.Text("Teléfono: ${user.phone}"),
          pw.SizedBox(height: 25),
          pw.Text("Términos y Condiciones",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Paragraph(
            text: longText.trim(),
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 30),
          pw.Text("Firma del Usuario",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Image(image, width: 180, height: 90)),
          pw.SizedBox(height: 10),
          pw.Text(
              "Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}"),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/contrato_usuario.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
