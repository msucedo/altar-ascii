# Cómo publicar Altar

Lo de una sola vez va primero; después, cada versión es correr un script.

## Una sola vez

### 1. Certificados
En Xcode → *Settings → Accounts*, elige tu cuenta → *Manage Certificates…* → **+** y crea los tres:

- **Developer ID Application**: firma la app y el DMG de Releases.
- **Apple Distribution**: firma la app de la App Store.
- **Mac Installer Distribution**: firma el `.pkg` que se sube a la App Store.

Para comprobar que quedaron en el Llavero:

```sh
security find-identity -v -p codesigning   # Developer ID Application y Apple Distribution
security find-identity -v                   # además, 3rd Party Mac Developer Installer
```

### 2. App ID y perfil de la App Store
En [developer.apple.com → Certificates, IDs & Profiles](https://developer.apple.com/account/resources):

1. **Identifiers → +** → *App IDs* → *App* → plataforma macOS, Bundle ID *Explicit* `com.msucedo.altar`, sin capabilities.
2. **Profiles → +** → *Mac App Store Connect* (en Distribution) → el App ID `com.msucedo.altar` → el certificado Apple Distribution.
3. Descárgalo y guárdalo como `signing/Altar_AppStore.provisionprofile`. Está en `.gitignore`, así que no se sube al repo.

### 3. Credenciales para notarizar
1. En [account.apple.com](https://account.apple.com) → *Inicio de sesión y seguridad* → *Contraseñas de apps*, crea una que se llame "altar-notary".
2. Guárdala en el Llavero. Te la va a pedir este comando:
   ```sh
   xcrun notarytool store-credentials altar-notary --apple-id <tu correo> --team-id M6JLQVH4Y7
   ```

### 4. La app en App Store Connect
En [App Store Connect](https://appstoreconnect.apple.com) → *Apps* → **+** → *Nueva app*:

- Plataforma **macOS**, nombre **Mi Altar de Muertos** (ver LISTING.md), idioma principal **Español (México)**.
- Bundle ID `com.msucedo.altar`, SKU `altar`, acceso completo.

## Cada versión

1. Sube `CFBundleShortVersionString` y `CFBundleVersion` en `Info.plist`. La App Store rechaza un `CFBundleVersion` que ya se haya subido.
2. **DMG para Releases**:
   ```sh
   tools/package.sh
   ```
   Tarda unos minutos mientras Apple lo notariza. Al final debe decir `source=Notarized Developer ID`. Sube `dist/Altar-<versión>.dmg` al Release.
3. **App Store**:
   ```sh
   tools/package-appstore.sh
   ```
   Abre la app **Transporter** (gratis en la Mac App Store), inicia sesión, arrastra `dist/Altar-<versión>-AppStore.pkg` → *Verify* → *Deliver*.
4. En App Store Connect, la versión aparece en unos minutos en *TestFlight* y después se puede elegir en la página de la versión. Llena la ficha con `appstore/LISTING.md`, sube las capturas y elige **Enviar a revisión**.

## Si algo falla

- **Notarización `Invalid`**: `xcrun notarytool log <id> --keychain-profile altar-notary` dice qué archivo y por qué.
- **"No identity found"**: el certificado no está en el Llavero de esta Mac (paso 1).
- **Transporter: falta el perfil o los entitlements no coinciden**: vuelve a descargar el perfil (paso 2). Revisa que el certificado del perfil sea el mismo Apple Distribution del Llavero.
- **Probar el sandbox en esta Mac** antes de subir: `tools/build.sh --sandbox && open build/Altar.app`. La configuración queda en `~/Library/Containers/com.msucedo.altar/`.
