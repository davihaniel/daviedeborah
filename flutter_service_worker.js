'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "888483df48293866f9f41d3d9274a779",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "975d5cf408b0dcd3094df0645bb5a13c",
"index.html": "fb706c82d7b84d2021a676588bf86f12",
"/": "fb706c82d7b84d2021a676588bf86f12",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "52ac4fc506d2e2ea00062524ced87cec",
"assets/assets/images/foto_4.jpg": "d14697fbb46a0431bbcebeeac0db9390",
"assets/assets/images/foto_21.jpg": "c019d6fa9ce87f37eee561c1c2f4a73d",
"assets/assets/images/foto_28.jpg": "9c9ca220e2af2d4965d580aa2a9fd517",
"assets/assets/images/foto_25.jpg": "d97e6e422e56358ac934ea9f42b641c7",
"assets/assets/images/foto_19.jpg": "ae1e6f12c5c71891a96811edfe148dc3",
"assets/assets/images/foto_6.jpg": "87496142d24ce43698557ddc28765bc8",
"assets/assets/images/foto_8.jpg": "21b43eb68c0a12572ea4dea1b3618b87",
"assets/assets/images/foto_18.jpg": "1b71ac81c3ff76193470a031d9d8f810",
"assets/assets/images/foto_12.jpg": "dfbd61974746e5eb062fede4a17c422a",
"assets/assets/images/foto_13.jpg": "cc5c7371b5232865130d787ce3f81ba8",
"assets/assets/images/foto_24.jpg": "d18fea6983d019cef7f0f102a1da8780",
"assets/assets/images/foto_22.jpg": "4074a22c44ad3dcaa0192374972f3848",
"assets/assets/images/foto_14.jpg": "350af14ac4a01b4e983a97bb0f3c9ea3",
"assets/assets/images/fundo1.jpg": "645f0b1f96d4e720998aac1ed7335045",
"assets/assets/images/foto_23.jpg": "6bd1f7928dc5286faed97a1750df7e5a",
"assets/assets/images/foto_20.jpg": "00658252faa14b790f941ba9ea1a7da3",
"assets/assets/images/foto_7.jpg": "c9bc47befbe5a7c6fc4a499f853c0b19",
"assets/assets/images/foto_9.jpg": "f365881f0ed8c6e27e668ca07c746683",
"assets/assets/images/foto_17.jpg": "82094adc48981cba199774de08065ca8",
"assets/assets/images/foto_15.jpg": "0daa42ed1e7abc004af42db489a4197c",
"assets/assets/images/foto_10.jpg": "0273f5c9207aaa95eb22f6e7d9d5a71d",
"assets/assets/images/foto_27.jpg": "f0ea9f27810b95b33da6947b1988e84d",
"assets/assets/images/foto_3.jpg": "1fa168b4eb33e78e60ff713aba2e6d64",
"assets/assets/images/foto_2.jpg": "5f03abf56067517136495d19829e41f0",
"assets/assets/images/foto_5.jpg": "ad6dc68050b4d3b5b1a101f503fb380f",
"assets/assets/images/foto_11.jpg": "06ef485e3625f39d999fe2768af20c2b",
"assets/assets/images/foto_26.jpg": "b97d4f53edb5a258fa7fd2f4d475860e",
"assets/assets/images/foto_16.jpg": "4a8e0ba41b95b204984def96efa407cb",
"assets/assets/images/foto_1.jpg": "d757cb5d5dd4d98c857d124489768c8c",
"assets/fonts/MaterialIcons-Regular.otf": "692a8a13ed8ff84555298a3af760f74a",
"assets/NOTICES": "bed0f0815a9e17253987acf4f3783e51",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "b6067128f6f1069cae29a661e4c9ecad",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "d40c67ce9f52d4bf087e61453006393c",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "3fbd60f2127511193d1c9bfd816d4f62",
"assets/FontManifest.json": "c75f7af11fb9919e042ad2ee704db319",
"assets/AssetManifest.bin": "db211c607630795df21fcff1ff1b6ed5",
"assets/AssetManifest.json": "c2f57cb01eb5815be1bbca75e3c1ad68",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "4cbcf61043ccda64ee753421211c2b60",
"version.json": "159e208117b33e1a52f9f51ddf7f0e75",
"main.dart.js": "8a8bfec13a998df26d8a241ac8e0ef92"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
