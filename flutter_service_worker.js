'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/README.md": "62c5469960d21aafb2b31d7a5c746bdc",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "484e1657a1e29d3126181c5fa6fc0660",
"index.html": "03d892178b1c75fefd94a51c411031b5",
"/": "03d892178b1c75fefd94a51c411031b5",
"firebase-config.js": "984f040d3f0a7bbf37634d0f52e683ef",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "afa6c85711ae13726c49b2b1b25a850e",
"assets/assets/brush_strokes.png": "8dce0007ba6227fe826d588850a71a84",
"assets/assets/images/logo/artiq_logo.png": "5d1417e39bacb987d3a11fda4a2528c5",
"assets/assets/templates/instagram_post_business.png": "d42d2e713cf2cfd28ad608f522572317",
"assets/assets/templates/linkedin_post_hiring.png": "2b983aa9f60d178ff4d4366c727e2590",
"assets/assets/templates/flyer_real_estate.png": "3ca38ccff57c64fcfd081df1770d7b2d",
"assets/assets/templates/youtube_thumbnail_vlog.png": "fb7bac4ebb03a81186536fb1b238d259",
"assets/assets/templates/instagram_story_quote.png": "536818a6575a4171bc29d63d965c2a53",
"assets/assets/templates/youtube_thumbnail_tutorial.png": "87c99b6c8ac32ab6afbeb7ea7b79058f",
"assets/assets/templates/flyer_event.png": "9b521be8fb34a62218b264db102c3541",
"assets/assets/templates/instagram_post_motivational.png": "229ec294080082f843a30604cd82e3d5",
"assets/assets/templates/facebook_cover_business.png": "bd883ca4b55576e13e3f1adc3d495f22",
"assets/assets/templates/business_card_modern.png": "e86ac2900bc8f3165c2fe43d8dc7d17e",
"assets/assets/templates/data/youtube_thumbnail_tutorial.json": "5808389f2fe94436d88294951e154577",
"assets/assets/templates/data/instagram_story_quote.json": "5bdcb13fd4a0ce101e26c027ce8ef47a",
"assets/assets/templates/data/instagram_post_motivational.json": "9b83f4195c4f7b831cf77fa2ef7e8c4b",
"assets/assets/templates/data/flyer_event.json": "ee1f6c40ec120300d5d8532d2efe60e0",
"assets/assets/templates/data/instagram_post_sale.json": "342ac51330e8f21347e96cc05ca67391",
"assets/assets/templates/data/instagram_post_business.json": "1ca73d4f29b306b8367331da502216d1",
"assets/assets/templates/data/linkedin_post_hiring.json": "b7bb8b59396889cc60a329cf6b117fa4",
"assets/assets/templates/data/business_card_modern.json": "9322f53f002ad3e9eae0a9eaea5b9119",
"assets/assets/templates/instagram_story_announcement.png": "162d90c2a08d3526b56512ebe2d9af66",
"assets/assets/templates/instagram_post_sale.png": "7f952dd10a299daaac85f803479aaf71",
"assets/fonts/MaterialIcons-Regular.otf": "975cb9857403dde4bdf74821e2aca830",
"assets/NOTICES": "8425a8d16a2ab02426aed628f85ca6dd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "2156ab9cf1b963b98fde4ba224934c98",
"assets/AssetManifest.json": "948373f3208c54673b4e55560ac980ec",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.js": "9fa2ffe90a40d062dd2343c7b84caf01",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"CNAME": "e7b0e79f336465ceb0c2846b61d1fc0a",
"flutter_bootstrap.js": "55025f83437f1a571a303a2d2edf861d",
"version.json": "77fbb10126381369255c6882a52dffbd",
"main.dart.js": "70b533dd5d36f0048a31827bce2531dd"};
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
