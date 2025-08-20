import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';

void showTermsAndConditionsDialog({
  required BuildContext context,
  required VoidCallback onAccepted,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Términos y Condiciones',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 560,
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _termsText,
                style: TextStyle(fontSize: 14, color: almostBlack),
              ),
            ),
          ),
        ),
        actions: [
          FloatingActionButton.extended(
            backgroundColor: almostBlack,
            foregroundColor: whiteLight,
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el modal
              onAccepted(); // Ejecuta la función si acepta
            },
            icon: Icon(icon_signature),
            label: Text(
              'Aceptar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
    },
  );
}

const String _termsText = '''
Mediante la inscripción a AMINA y/o asistiendo a clases, eventos, actividades y otros programas, 
así como por el uso de las instalaciones y el equipo ("Clases” y/o “Instalaciones") de 
MARIA VERONICA NAVAS FLORES con RUC 1722856745001, por la presente reconozco que existen ciertos 
riesgos y peligros inherentes al uso y práctica de cualquier ejercicio físico y en específico 
en este caso, a la práctica de fuerza, cardio y flexibilidad. 

Conozco la naturaleza de las clases impartidas por AMINA, así como las capacidades físicas 
y experiencias con las que se me recomienda contar, manifestando que las mismas son idóneas 
para participar en las “Clases” y/o “Instalaciones”. 

Debido a lo anterior, expresamente manifiesto que no cuento con un historial de enfermedades 
ni lesiones, ni estoy usando actualmente ninguna substancia, medicina, droga o alcohol, 
que pudiera limitar mis habilidades o perjudicar mi desempeño y/o salud al momento o después 
de realizar ejercicio físico. 

También reconozco que los riesgos específicos varían de una actividad a otra, mismos que 
podrían ser:  
(a) lesiones menores como: 
   (1) rasguños; 
   (2) golpes y torceduras;  
(b) lesiones mayores como: 
   (1) lesiones en las articulaciones o la espalda; 
   (2) ataques cardíacos; 
   (3) contusiones;  
(c) lesiones graves, incluyendo parálisis y muerte;  

Conjuntamente “Los Riesgos”, por lo que expresamente reconozco y acepto que dichos riesgos 
no pueden ser eliminados por AMINA. 

---

Los Riesgos pueden ser provocados por mi propia omisión, actividad o inactividad antes, durante 
o posterior a cualquiera de las clases impartidas en las instalaciones de AMINA, así como también 
por la omisión, actividad o inactividad de otros asistentes a las Clases y/o Instalaciones, 
por el uso de los equipos o instalaciones sin la debida precaución o sin seguir las indicaciones impartidas. 

Reconozco y acepto expresamente que dichos riesgos son inherentes a las actividades físicas 
ofrecidas por AMINA y no pueden ser completamente eliminados, incluso cuando exista un nivel 
razonable y adecuado de cuidado y diligencia por parte de AMINA. 

Pueden existir otros riesgos no conocidos por AMINA, o que aún no son previsibles, o que siendo previsibles 
son de mi conocimiento, lo reconozco y asumo, o aquellos que se deriven por caso fortuito o fuerza mayor. 

---

Las pérdidas económicas y/o daños directos o indirectos que puedan resultar de estos riesgos, 
pueden ser severos y modificar permanentemente mi futuro. 

Al reservar y/o tomar una clase de AMINA, usted reconoce y acepta que:  
1. Asume plena responsabilidad por su estado de salud, así como todas y cada una de las lesiones físicas, 
   daños o cualquier enfermedad (viral o bacterial) que pueda sufrir o adquirir al tomar alguna Clase presencial, 
   o al hacer uso de las instalaciones y/o productos de AMINA.  
2. Libera de cualquier tipo de responsabilidad e indemnización a AMINA, sus entidades afiliadas y/o subsidiarias, 
   y cada uno de sus respectivos representantes legales, directores, managers, miembros del staff, empleados, 
   agentes incluyendo terceros prestadores de servicios y todos los demás aplicables, de cualquier demanda 
   por daños y perjuicios, responsabilidad en otras materias incluyendo materia penal, procedimientos de arbitraje, 
   costos, gastos, en la máxima medida permitida por la ley aplicable.  
3. Acepta y manifiesta que ni usted ni cualquier tercero que tome una clase de AMINA bajo su reservación y/o 
   invitación y/o utilice un producto de AMINA:  
   (a) no tiene ninguna condición médica o física que le impida utilizar correctamente las Clases e Instalaciones,  
   (b) no tiene una condición física o mental que lo ponga en peligro físico o médico a usted o a los demás,  
   (c) no ha sido instruido o recomendado por un médico para no realizar ejercicio físico.  

Usted reconoce que, en caso de embarazo, recuperación postoperatoria, o padecimiento de enfermedades crónicas 
o degenerativas (tales como hipertensión, afecciones cardíacas, diabetes, epilepsia, cáncer, entre otras), 
la participación en las clases o el uso de las instalaciones de AMINA puede implicar un riesgo significativo.  

En consecuencia, declara haber evaluado dicha condición de manera consciente y voluntaria, asumiendo plena 
responsabilidad y eximiendo expresamente a AMINA de cualquier consecuencia derivada de su decisión de participar.  

---

He leído y entendido completamente el reglamento interno de AMINA que me fue proporcionado 
de forma física por el personal y en los medios visibles en las instalaciones. 

Me comprometo a llegar antes de que inicie la clase (tengo 1 canción de tolerancia para entrar).  

Me comprometo a cumplir con todos los términos y condiciones, así como con las instrucciones 
que el personal de AMINA proporcione.  

En caso de no seguir las instrucciones emitidas por el personal, reconozco y acepto expresamente 
que asumo las consecuencias, liberando de cualquier responsabilidad a AMINA, sus subsidiarias 
y representantes.  

---

VALORES Y BIENES PERSONALES  

AMINA no se hará responsable por la pérdida, robo, o daños a cualquier objeto, incluyendo 
artículos en casilleros, baños, estudios, o cualquier otro lugar en las instalaciones, 
sin importar si estos estaban bajo llave o no.  

Se recomienda no guardar en los casilleros objetos de valor (documentos personales, electrónicos, 
joyas o dinero en efectivo).  

AMINA se reserva el derecho de denegar el acceso a cualquier persona que considere esté actuando 
de manera inadecuada, agresiva, riesgosa, bajo efectos de alcohol o sustancias prohibidas, 
o que ponga en riesgo su salud o la de los clientes, sin que ello genere responsabilidad 
ni obligación de reembolso.  

''';
