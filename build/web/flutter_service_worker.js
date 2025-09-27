'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "b25975cdabad09280e83d0520783dce7",
"assets/AssetManifest.bin.json": "6707c8040d586aa4d2385342710d724f",
"assets/AssetManifest.json": "6c43367b3d6b41132e3f7d8c95411fd5",
"assets/assets/about1.jpeg": "06ec1042bfa0fb2ebd3430907cad6fe5",
"assets/assets/about2.jpg": "200e9896565759f83ff34d58d6643f57",
"assets/assets/gallery/deluxe_room.jpg": "347ab5923eee3967a87b61f4e9b984f5",
"assets/assets/gallery/dining.jpg": "c4f4262a8ec27db1622f7bc8aea4a927",
"assets/assets/gallery/events.jpeg": "f1699dc117e0fe3d3b6eaf23072c4011",
"assets/assets/gallery/hero.jpeg": "b05dd3c312d0879003721bcd8055d44a",
"assets/assets/gallery/lobby.png": "5f9482faea3ff8e6ca29318d9ad8035d",
"assets/assets/gallery/pool.jpeg": "cded927e34bcfa84468c1ea4a28ce789",
"assets/assets/gallery/spa.jpeg": "8b2d5b2f4d94d0bc320fd1976ad82e56",
"assets/assets/hero1.jpg": "347ab5923eee3967a87b61f4e9b984f5",
"assets/assets/hero2.png": "95256823be94b917b5d1ac7b273d452d",
"assets/assets/hero3.png": "86c599453b5a9ae0b79c368035a2a698",
"assets/assets/hero4.png": "bad60312a2d8e0bc556537145053effa",
"assets/assets/hero5.png": "f2cb56bd86c43d4c1fb09da28f00a77f",
"assets/assets/hero6.png": "195d7edfa66e503af1fb0e209f02d770",
"assets/assets/logomf.png": "1dc5a13ca74c3c2e75a4d1cdbd976d45",
"assets/assets/rooms/hero.png": "ffa1a59f35b5f8b054eaefb3e35e071c",
"assets/assets/services/ballroom.png": "ff653cbb63f00e436594b6d85c7beb7d",
"assets/assets/services/gym.jpg": "b26919699506dcc68071c7929d2540dc",
"assets/assets/services/pool.jpeg": "cded927e34bcfa84468c1ea4a28ce789",
"assets/assets/services/retail.jpg": "82c753a86e32676d50bb8ef97ee6c43e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "44c7b8d6134a3d970a03881b5ec2e3b3",
"assets/NOTICES": "515ea80e1ae9fe48e307ddd826eea4d6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "c31820796bdc57ad7607b58e484b1154",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "f09bc527ffd73373363f5f31229d3012",
"icons/Icon-192.png": "c31820796bdc57ad7607b58e484b1154",
"icons/Icon-512.png": "c31820796bdc57ad7607b58e484b1154",
"icons/Icon-maskable-192.png": "c31820796bdc57ad7607b58e484b1154",
"icons/Icon-maskable-512.png": "c31820796bdc57ad7607b58e484b1154",
"index.html": "8a3e36e686b7cf4e508635c19ae0a841",
"/": "8a3e36e686b7cf4e508635c19ae0a841",
"main.dart.js": "b61a1c3a953d3e6964d3b21b2627635c",
"manifest.json": "90e6d4021a112ab16a0ddf1e8fe545ad",
"version.json": "9220cc2040f40f344b25ac2a6729853d"};
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
