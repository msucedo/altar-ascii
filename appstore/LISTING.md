# Ficha para App Store Connect

Idioma principal: Español (México). Los límites de Apple van entre paréntesis.

**Nombre** (30): Mi Altar de Muertos

**Subtítulo** (30): Tu ofrenda en la barra de menú

**Categoría**: Estilo de vida (principal), Entretenimiento (secundaria)

**Texto promocional** (170):
Pon tu altar para el 1 y 2 de noviembre: velas que parpadean, copal, papel picado y los nombres de tus seres queridos, en ASCII, en la barra de menú o en el escritorio.

**Descripción** (4000):
Mi Altar de Muertos es un altar dibujado en arte ASCII que vive en la barra de menú de tu Mac, para honrar la memoria de tus seres queridos.

El Día de Muertos es una tradición mexicana que se celebra el 1 y 2 de noviembre, cuando se cree que las almas de los difuntos vuelven a visitar a sus familias. Para recibirlos, se pone un altar con sus retratos, su comida favorita, velas que alumbran el camino y flores de cempasúchil que los guían de regreso.

• Niveles: 2 (el cielo y la tierra), 3 (con el inframundo) o 7 (los siete pasos hacia el descanso).
• Ofrendas: papel picado, retratos con los nombres de tus seres queridos, velas, cempasúchil, pan de muerto, calaveritas, comida favorita, agua, sal y copal. Pon o quita cada una.
• Animado: las velas parpadean, el humo del copal sube y el papel picado se mueve con el viento. Se queda quieto si tienes activado "Reducir movimiento".
• En el escritorio: deja el altar pegado al fondo del escritorio, detrás de las ventanas, donde quieras.
• Cuenta regresiva al 1 y 2 de noviembre.

Sin cuentas, sin internet y sin anuncios. Los nombres que escribes se quedan en tu Mac.

**Palabras clave** (100): dia de muertos,ofrenda,ascii,barra de menu,cempasuchil,calavera,mexico,difuntos,velas

**URL de soporte**: https://github.com/msucedo/altar-ascii/issues
**URL de marketing**: https://github.com/msucedo/altar-ascii
**Política de privacidad**: https://github.com/msucedo/altar-ascii/blob/main/SECURITY.md#alcance
**Copyright**: 2026 Mario Saucedo

**Privacidad de la app**: "No se recopilan datos".
**Clasificación por edad**: todo en "Ninguno" → 4+.
**Exportación / cifrado**: no usa cifrado (ya está `ITSAppUsesNonExemptEncryption = NO` en Info.plist).

**Capturas**: `appstore/capturas/` (3, de 2880×1800, sin transparencia, en ese orden). Se arman a partir de las de `docs/` con `swiftc tools/make-screenshots.swift -o build/make-screenshots && build/make-screenshots appstore/capturas`.

**Notas para el revisor**:
La app vive en la barra de menú (no tiene ícono en el Dock). Haz clic en la flor 🌼 de la barra de menú para abrir el altar. La flecha debajo del altar abre las opciones: niveles, ofrendas y nombres. "Mostrar en el escritorio" deja el altar en el fondo del escritorio. No necesita cuenta ni conexión a internet.
