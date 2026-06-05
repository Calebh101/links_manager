**If you're seeing this when you expected the actual website, please come back later.<br>The website is currently being deployed, and will be done soon.**

## CLinks

CLinks is a URL-shortening service, with a *twist*.

With each link you create, you can set up **advanced logic** for your links.
These are basically "paths" that use properties of the user's device for deciding the URL.

For example, you can create a link that by default goes to https://example.com/download, but if the user is on iOS the page will redirect to https://apps.apple.com/us/app/myapp.

You can also do more complex logic on this. For example, you can have your link set up so that:

- Defaults to https://example.com/download
- If on iOS, goes to https://apps.apple.com/us/app/myapp
- If on Linux, goes to https://flathub.org/en/apps/com.me.myapp
- If on Windows or macOS*, goes to https://example.com/download/desktop
- If on Android, using Chrome, goes to https://example.com/download/android/specialPageForChrome
- If on Android (without Chrome**), goes to https://example.com/download/android

*There's no "or" option in the UI, but you can make multiple paths go to the same URL.

\*\*Because the normal Android path is *below* the Android with Chrome, the Android with Chrome path will be checked first.

## Support

Discord: https://discord.gg/gbZyPuqZ6n